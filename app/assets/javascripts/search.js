$(function() {
  $(".js-search").focusin(function() {
    $(".js-search .js-advanced-search").show(0, function() {
      $(".select2").select2();
    });
  });
});
