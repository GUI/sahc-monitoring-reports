// A workaround for @rails/ujs trying to call start() whenever the package is
// imported. This prevents Rails from trying to call start() initially.
//
// We're specifically pulling in a newer version of @rails/ujs from git (via
// gitpkg.now.sh because it's a nested subfolder in git), in order to get these
// improvements: https://github.com/rails/rails/pull/45546 This should no
// longer be necessary in Rails 7.1+.
//
// This newer version partially solves the issue, but it can still cause issues
// if multiple different apps are including the @rails/ujs library separately,
// since in development mode, it still still try to call start on import. So to
// prevent this, if you import this file before importing @rails/ujs, this can
// prevent the initial start() call:
// https://github.com/rails/rails/blob/0eaa58ef3f1690538e0efc672e931824479d15c6/actionview/app/assets/javascripts/rails-ujs.esm.js#L663-L665
//
// https://github.com/ElMassimo/vite_ruby/issues/246#issuecomment-1235743299
// https://github.com/ElMassimo/jumpstart-vite/commit/f25668a989c3bfd50b9063ee99645771c7a56101#r84399950
document.addEventListener('rails:attachBindings', function(event) {
  event.preventDefault();
});
