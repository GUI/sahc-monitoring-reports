import '@/font_awesome_icons';
import '@/reports';
import DataTable from 'datatables.net-bs5';
import Rails from '@rails/ujs';
import $ from 'jquery';

Rails.start();

Object.assign(DataTable.defaults, {
  headerCallback: function(thead) {
    $(thead).find('th:not(.sort-arrows-added)').append('<i class="fas fa-sort"></i><i class="fas fa-sort-up"></i><i class="fas fa-sort-down"></i>');
    $(thead).find('th').addClass('sort-arrows-added');
  },
});

$(document).ready(function(){
  new DataTable('table.table-data-tables', {
    pageLength: 50,
    order: [[3, 'desc']],
    columnDefs: [
      { targets: 3, type: 'string' },
      { targets: 4, type: 'string' },
      { targets: 5, orderable: false },
    ]
  });
});
