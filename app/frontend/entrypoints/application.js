import '../font_awesome_icons';
import '../reports';
import dataTablesInit from 'datatables.net';
import dataTablesBs5Init from 'datatables.net-bs5';
import Rails from 'rails-ujs';
import $ from 'jquery';

dataTablesInit(window, $);
dataTablesBs5Init(window, $);

// Conditional needed:
// https://github.com/ElMassimo/vite_ruby/issues/246#issuecomment-1235743299
// https://github.com/ElMassimo/jumpstart-vite/commit/f25668a989c3bfd50b9063ee99645771c7a56101#r84399950
if (!window.Rails) {
  Rails.start();
}

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
