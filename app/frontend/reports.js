import 'jquery.dirtyforms';
import $ from 'jquery';
import qq from 'fine-uploader'
import Rails from 'rails-ujs';

window.setupUploader = function setupUploader(name, uuidInputName, overrides) {
  const $container = $('#' + name + '_container');
  const $toggle = $('#' + name + '_toggle');
  const $uuids = $('#' + name + '_uuids');

  $toggle.find('a').click(function(event) {
    $container.show();
    $toggle.hide();
    event.preventDefault();
  });

  const options = {
    element: document.getElementById(name),
    template: 'qq-simple-thumbnails-template',
    request: {
      endpoint: '/uploads',
      uuidName: 'uuid',
      inputName: 'file',
      customHeaders: {
        'X-CSRF-Token': Rails.csrfToken(),
      },
    },
    deleteFile: {
      enabled: true,
      endpoint: '/uploads',
      customHeaders: {
        'X-CSRF-Token': Rails.csrfToken(),
      },
    },
    validation: {
      allowedExtensions: ['jpg', 'jpeg', 'kmz'],
    },
    callbacks: {
      onStatusChange: function() {
        const uploads = this.getUploads();
        const uuids = [];
        for(let i = 0; i < uploads.length; i++) {
          const upload = uploads[i];
          if(upload.status === qq.status.UPLOAD_SUCCESSFUL) {
            uuids.push(upload.uuid);
          } else if(upload.status !== qq.status.CANCELED && upload.status !== qq.status.REJECTED && upload.status !== qq.status.DELETED) {
            $('button[type=submit]').attr('disabled', 'disabled');
            $('form').bind('submit', function(e) { e.preventDefault(); });
            return;
          }
        }

        $uuids.empty();
        for(let i = 0; i < uuids.length; i++) {
          $('<input>').attr({
            type: 'hidden',
            name: uuidInputName,
            value: uuids[i],
          }).appendTo($uuids);
        }

        $('button[type=submit]').removeAttr('disabled', 'disabled');
        $('form').unbind('submit');
      },
    },
  };

  const existingUuids = $uuids.find('input').map(function() { return $(this).val(); }).get();
  if(existingUuids.length > 0) {
    $container.show();
    $.extend(options, {
      session: {
        endpoint: '/uploads',
        params: {
          uuids: existingUuids.join(','),
        },
      },
    });
  }

  if(overrides) {
    $.extend(options, overrides);
  }

  new qq.FineUploader(options);
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

  const $arrayContainer = $('.report-form .form-group.array .array-inputs-container')
  function appendArrayElement() {
    if($arrayContainer.find('input:last-child').val() !== '') {
      const $newElement = $('.form-group.array input:last-child').clone();
      $newElement.val('');
      $arrayContainer.append($newElement);
    }
  }
  appendArrayElement();
  $arrayContainer.on('keyup', 'input', appendArrayElement);
});
