import '../font_awesome_icons';
import '../reports';
import * as dataTablesInit from 'datatables.net';
import * as dataTablesBs5Init from 'datatables.net-bs5';
import Rails from 'rails-ujs';
import $ from 'jquery';

dataTablesInit(window, $);
dataTablesBs5Init(window, $);

Rails.start();

$.fn.DataTable.defaults.headerCallback = function(thead) {
  $(thead).find('th:not(.sort-arrows-added)').append('<i class="fas fa-sort"></i><i class="fas fa-sort-up"></i><i class="fas fa-sort-down"></i>');
  $(thead).find('th').addClass('sort-arrows-added');
};

$(document).ready(function(){
  $('table.table-data-tables').DataTable({
    pageLength: 50,
    order: [[3, 'desc']],
    columnDefs: [
      { targets: 3, type: 'string' },
      { targets: 4, type: 'string' },
      { targets: 5, orderable: false },
    ]
  });
});
