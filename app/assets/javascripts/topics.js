$(function() {
  var $topics = $(".topics");
  if ($topics.length == 0) {
    return;
  }

  var dragger = dragula({
    accepts: function (el, target, source, sibling) {
      console.log(target);
      var $el = $(el);
      if ($el.hasClass("js-heading")) {
        return $(target).hasClass("js-headings");
      } else if ($el.hasClass("js-guide")) {
        return $(target).hasClass("js-guides");
      }
    }
  });

  $(".js-guides, .js-headings").each(function() {
    dragger.containers.push(this);
  });

  $topics.on("click", ".js-add-heading", function() {
    var $heading = $topics.find(".topics-templates .js-heading").clone();
    $topics.find(".js-grouped-list").append($heading);
    dragger.containers.push($heading.find(".js-guides")[0]);
  });

  $topics.on("click", ".js-delete-list-group-item", function() {
    var $listGroupItem = $(this).closest(".list-group-item");
    var $parent = $listGroupItem.parent();
    if ($listGroupItem.hasClass("js-heading")) {
      $listGroupItem.remove();
      $listGroupItem.find("ul li.js-guide").each(function() {
        var $guide = $(this);
        $guide.appendTo(".js-ungrouped-list");
      });
    } else {
      $listGroupItem.appendTo(".js-ungrouped-list");
    }
  });

  $(document).on("click", ".btn-save", function(e) {
    var topics = [];

    $(".js-grouped-list .js-heading").each(function() {
      var $item = $(this);
      var topic = {
        title: $item.find(".js-topic-title").val(),
        description: $item.find(".js-topic-description").val(),
        guides: []
      }
      $item.find(".js-guide").each(function() {
        topic.guides.push($(this).data("guide-id"));
      });

      topics.push(topic);
    });

    $(".js-topic-tree").val(JSON.stringify(topics));
  });

});
