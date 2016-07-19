$(function() {
  var $topics = $(".js-topic-section-list");

  $topics.on("click", ".js-delete-list-group-item", function() {
    $item = $(this).parents(".list-group-item");
    $item.find(".js-destroy").val("1");
    $item.hide();
  });

  // Set up dragula on the overall section list
  var sectionList = dragula($('.js-topic-section-list').get(), {
    moves: function (el, source, handle, sibling) {
      return $(handle).hasClass("js-topic-section-handle");
    }
  });

  sectionList.on('dragend', function () {
    $('.js-section-position').each(function (index) {
      $(this).val(index);
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
