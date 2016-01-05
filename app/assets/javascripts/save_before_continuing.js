$(function() {
  $(document).on("click", ".js-save-before-continuing", function(event){
    var link = $(event.currentTarget);
    var form = link.closest('form');
    var serialisedForm = form.serialize();

    $.ajax({
      async: false, // wait for this to finish proceeding with the event
      type: form.attr('method').toUpperCase(),
      url: form.attr('action'),
      data: form.serialize(),
      complete: function(response) {
        if (response.status == 200){
          return true;
        } else {
          event.preventDefault();
          form.submit(); // submit the form (not via ajax) so the user can see the errors
          return false;
        }
      }
    });
  });
});
