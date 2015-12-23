$(function() {
  $("form").each(function() {
    var form = $(this);
    if (form.find(".disable-when-dirty").length > 0) {
      $(form).on('input change', function() {
        var elements = form.find(".disable-when-dirty");
        elements.prop("disabled", true);
        elements.attr("title", "Your form has unsaved changes");
      });
    }
  });
});
