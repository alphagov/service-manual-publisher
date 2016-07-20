$(function() {
  var $topics = $(".js-topic-section-list");

  $topics.on("click", ".js-delete-list-group-item", function() {
    $item = $(this).parents(".list-group-item");
    $item.find(".js-destroy").val("1");
    $item.hide();
  });

  $(".js-topic-section-list").each(function() {
    dragula([this], {
      moves: function (el, source, handle, sibling) {
        return $(handle).hasClass("js-topic-section-handle");
      }
    });
  });

  $(".js-guide-list").each(function() {
    dragula([this], {
      moves: function (el, source, handle, sibling) {
        return $(handle).hasClass("js-guide-handle");
      }
    });
  });
});
