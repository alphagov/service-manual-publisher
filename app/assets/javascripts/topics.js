$(function() {
  var $topics = $(".topics");
  if ($topics.length == 0) {
    return;
  }

  function createNewGuide(value) {
    var $guide = $topics.find(".topics-templates .js-guide-template").clone();
    $guide.find(".js-topic-guide").val(value);
    $guide.removeClass("js-guide-template");
    $guide.removeClass("hidden");
    $guide.addClass("draggable-guide");
    $topics.find(".js-sortable-topic-list").append($guide);
  }

  function createNewHeading(title, description) {
    $(".js-add-guide").attr("disabled", false);

    var heading = $topics.find(".topics-templates .js-heading-template").clone();
    heading.find(".js-topic-title").val(title);
    heading.find(".js-topic-description").val(description);
    $topics.find(".js-sortable-topic-list").append(heading);
    heading.removeClass("js-title-template");
    heading.removeClass("hidden");
  }

  $topics.on("click", ".js-add-guide", function(){createNewGuide("")});
  $topics.on("click", ".js-add-heading", function(){createNewHeading("","")});

  $topics.on("click", ".js-delete-list-group-item", function() {
    $(this).parents(".list-group-item").remove();
  });

  // Wrap this in a try because Sortable crashes poltergeist.
  try {
    Sortable.create(document.getElementsByClassName("js-sortable-topic-list")[0], {
      animation: 150
    });
  } catch (e) {
  }

  $(document).on("click", ".btn-save", function(e) {
    var topics = [];
    var currentTopic = null;

    $(".js-topic-input").each(function() {
      var topicInput = $(this);
      if (topicInput.hasClass("js-topic-title")) {
        if (currentTopic != null) {
          topics.push(currentTopic);
        }
        currentTopic = {title: topicInput.val(), guides: []};
      } else if (topicInput.hasClass("js-topic-description")) {
        currentTopic["description"] = topicInput.val();
      } else if (topicInput.hasClass("js-topic-guide")) {
        currentTopic["guides"].push(topicInput.children(":selected").val());
      }
    });

    $(".js-topic-tree").val(JSON.stringify(topics));
  });

  var json = $topics.find(".js-topic-tree").val();
  json = JSON.parse(json);
  for (topicIndex = 0; topicIndex < json.length; topicIndex++) {
    var topic = json[topicIndex];
    createNewHeading(topic.title, topic.description);
    for (guideIndex = 0; guideIndex < topic.guides.length; guideIndex++) {
      createNewGuide(topic.guides[guideIndex]);
    }
  }
});
