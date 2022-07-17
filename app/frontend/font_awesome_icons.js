import { library, dom } from '@fortawesome/fontawesome-svg-core';
import { faFile } from '@fortawesome/free-solid-svg-icons/faFile';
import { faPencilAlt } from '@fortawesome/free-solid-svg-icons/faPencilAlt';
import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
import { faSort } from '@fortawesome/free-solid-svg-icons/faSort';
import { faSortDown } from '@fortawesome/free-solid-svg-icons/faSortDown';
import { faSortUp } from '@fortawesome/free-solid-svg-icons/faSortUp';
import { faSyncAlt } from '@fortawesome/free-solid-svg-icons/faSyncAlt';
import { faTimes } from '@fortawesome/free-solid-svg-icons/faTimes';

library.add(
  faFile,
  faPencilAlt,
  faPlus,
  faSort,
  faSortDown,
  faSortUp,
  faSyncAlt,
  faTimes,
);

dom.watch();
