import 'jquery.dirtyforms';
import $ from 'jquery';
import XHRUpload from '@uppy/xhr-upload';
import Dashboard from '@uppy/dashboard';
import Uppy from '@uppy/core';
import Rails from '@rails/ujs';
import ky from 'ky';
import rollbar from '@/lib/rollbar';

async function setupUploader(element) {
  const name = element.id;
  const uuidInputName = element.dataset.uploader;
  const replaceMode = element.dataset.uploaderReplace === 'true';

  const containerEl = document.getElementById(`${name}_container`);
  const toggleEl = document.getElementById(`${name}_toggle`)?.querySelector('a');
  const uuidsEl = document.getElementById(`${name}_uuids`);
  const formEl = document.querySelector('form');
  const submitEl = document.querySelector('button[type=submit]');

  // Hook up a "show" link to show the uploader.
  if (toggleEl) {
    toggleEl.addEventListener('click', (event) => {
      containerEl.hidden = false;
      toggleEl.hidden = true;
      event.preventDefault();
    });
  }

  // Allowed file types only includes kmz files for new uploads, since kmz can
  // contain multiple files, so that doesn't make sense when replacing a single
  // file.
  const allowedFileTypes = [
    'image/jpeg',
    'image/heic',
  ];
  if (!replaceMode) {
    allowedFileTypes.push('.kmz');
  }

  // Instantiate the basic uploader.
  const uppy = new Uppy({
    // Must be disabled until after pre-populating with any existing uploads
    // (when validation errors have occurred), since otherwise Uppy will try
    // uploading the programatically added files.
    autoProceed: false,

    restrictions: {
      allowedFileTypes,
      // When in replacement mode, only 1 file be be uploaded.
      maxNumberOfFiles: (replaceMode) ? 1 : null,
    },
  });

  // If there are any existing upload UUIDs on the page, that indicates this
  // the page being re-rendered after a form submission that had validation
  // errors. In that case, we can still retain the original uploads, but we
  // need to make it look like those were uploaded.
  const existingUuids = Array.from(uuidsEl.querySelectorAll('input')).map((input) => input.value);
  if (existingUuids.length > 0) {
    containerEl.hidden = false;

    try {
      // Fetch the info of the uploads from the endpoint given the UUIDs we
      // have.
      const existingUploads = await ky.get('/uploads', {
        headers: {
          'X-CSRF-Token': Rails.csrfToken(),
        },
        searchParams: {
          uuids: existingUuids.join(','),
        },
      }).json();

      // Loop over all of the uploads and pre-populate Uppy with these file
      // uploads.
      for (const existingUpload of existingUploads) {
        uppy.addFile({
          name: existingUpload.name,
          type: existingUpload.type,
          meta: {
            uuid: existingUpload.uuid,
          },
          data: new Blob(),
          isRemote: true,
        });
      }

      // Force Uppy to think these were already uploaded, so it doesn't try to
      // upload them again.
      for (const file of uppy.getFiles()) {
        uppy.setFileState(file.id, {
          progress: { uploadComplete: true, uploadStarted: true }
        })
      }
    } catch (error) {
      rollbar.error('Error retreiving uploads', error);
      alert('Error retreiving uploaded files.');
    }
  }

  // For normal uploads, we want them to happen immediately.
  uppy.setOptions({
    autoProceed: true,
  });

  // This helper populates a hidden element filled with the UUIDs of all of the
  // file uploads.
  const setHiddenInputUuids = () => {
    uuidsEl.innerHTML = '';
    for (const file of uppy.getFiles()) {
      const uuidInputEl = document.createElement('input');
      uuidInputEl.type = 'hidden';
      uuidInputEl.name = uuidInputName;
      uuidInputEl.value = file.meta.uuid;
      uuidsEl.appendChild(uuidInputEl);
    }
  };

  // Use the default Uppy UI.
  uppy.use(Dashboard, {
    inline: true,
    target: element,
    doneButtonHandler: null,
    proudlyDisplayPoweredByUppy: false,
    showRemoveButtonAfterComplete: true,
    height: 300,
  });

  // Upload the individual files to the uploads endpoint.
  uppy.use(XHRUpload, {
    endpoint: '/uploads',
    headers: {
      'X-CSRF-Token': Rails.csrfToken(),
    },
    bundle: false,
    fieldName: 'file',
  });

  // Before uploading, come up with a unique UUID for each file so the file can
  // be tracked across submissions (this also comes from how FineUploader used
  // to perform uploads).
  uppy.on('file-added', (file) => {
    uppy.setFileMeta(file.id, {
      uuid: crypto.randomUUID(),
    });
  });

  // When files are removed, attempt to cleanup the backend upload. Although,
  // other server-side rake tasks will also cleanup orphaned files on a
  // regular, so this isn't a huge deal if it fails.
  uppy.on('file-removed', async (file) => {
    try {
      await ky.delete(`/uploads/${file.meta.uuid}`, {
        headers: {
          'X-CSRF-Token': Rails.csrfToken(),
        }
      });
    } catch (error) {
      console.error('Error deleting upload: ', error);
      rollbar.error('Error deleting upload', error);
    }

    setHiddenInputUuids();
  });

  // Disable the form on upload so the form can't be submitted during a partial
  // upload.
  uppy.on('upload', () => {
    formEl.onsubmit = (e) => { e.preventDefault() };
    submitEl.disabled = true;
  });

  // Re-enable the form after uploads complete and sync the hidden UUID list.
  uppy.on('complete', () => {
    setHiddenInputUuids();
    formEl.onsubmit = null;
    submitEl.disabled = false;
  });
}

window.pollReportUploads = function(reportId) {
  let redirected = false;
  $.ajax({
    url: `/reports/${reportId}.json`,
  }).done(function(data) {
    if(data && data.upload_progress !== 'pending') {
      let params = '';
      if(data.upload_progress === null) {
        params = '?new_uploads=true';
      }
      redirected = true;
      window.location.href = `/reports/${reportId}/edit${params}`;
    }
  }).always(function() {
    if(!redirected) {
      setTimeout(window.pollReportUploads, 500, reportId);
    }
  });
}

window.pollReportPdf = function(reportId) {
  let redirected = false;
  $.ajax({
    url: `/reports/${reportId}.json`,
  }).done(function(data) {
    if(data && data.pdf_progress !== 'pending') {
      let params = '';
      if(data.pdf_progress === null) {
        params = '?download_redirect=true';
      }
      redirected = true;
      window.location.href = `/reports/${reportId}${params}`;
    }
  }).always(function() {
    if(!redirected) {
      setTimeout(window.pollReportPdf, 500, reportId);
    }
  });
}

window.downloadReport = function(path) {
  $(window).on('load', function() {
    window.location.href = path;

    // Remove the '?download_redirect=true' params from the current URL (but
    // without triggering a real page reload) so that if the user reloads this
    // page, they don't trigger another download.
    if(window.history && window.history.replaceState) {
      setTimeout(function() {
        window.history.replaceState({}, '', window.location.pathname);
      }, 0);
    }
  });
}

$(document).ready(function() {
  $('form.report-form').dirtyForms();

  const uploaders = document.querySelectorAll('[data-uploader]');
  for (const uploader of uploaders) {
    setupUploader(uploader);
  }

  $(document).on('submit', 'form.report-form', function() {
    const $form = $(this);
    $form.find(':submit').each(function() {
      const $button = $(this);
      const label = $button.data('after-submit-text');
      if(label) {
        $button.html(label).prop('disabled', true);
      }
    });
  });

  const $arrayContainer = $('.report-form .row.array .array-inputs-container')
  function appendArrayElement() {
    if($arrayContainer.find('input:last-child').val() !== '') {
      const $newElement = $('.row.array input:last-child').clone();
      $newElement.val('');
      $arrayContainer.append($newElement);
    }
  }
  appendArrayElement();
  $arrayContainer.on('keyup', 'input', appendArrayElement);
});
