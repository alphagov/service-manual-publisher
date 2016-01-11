$(function() {
  var $topics = $(".topics");
  if ($topics.length == 0) {
    return;
  }

  function createNewEdition(value) {
    var $edition = $topics.find(".topics-templates .js-edition-template").clone();
    $edition.find(".js-topic-edition").val(value);
    $edition.removeClass("js-edition-template");
    $edition.removeClass("hidden");
    $topics.find(".js-sortable-topic-list").append($edition);
  }

  function createNewHeading(title, description) {
    $(".js-add-edition").attr("disabled", false);

    var heading = $topics.find(".topics-templates .js-heading-template").clone();
    heading.find(".js-topic-title").val(title);
    heading.find(".js-topic-description").val(description);
    $topics.find(".js-sortable-topic-list").append(heading);
    heading.removeClass("js-title-template");
    heading.removeClass("hidden");
  }

  $topics.on("click", ".js-add-edition", function(){createNewEdition("")});
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
	currentTopic = {title: topicInput.val(), editions: []};
      } else if (topicInput.hasClass("js-topic-description")) {
	currentTopic["description"] = topicInput.val();
      } else if (topicInput.hasClass("js-topic-edition")) {
	currentTopic["editions"].push(topicInput.children(":selected").val());
      }
    });

    $(".js-topic-tree").val(JSON.stringify(topics));
  });

  var json = $topics.find(".js-topic-tree").val();
  json = JSON.parse(json);
  for (topicIndex = 0; topicIndex < json.length; topicIndex++) {
    var topic = json[topicIndex];
    createNewHeading(topic.title, topic.description);
    for (editionIndex = 0; editionIndex < topic.editions.length; editionIndex++) {
      createNewEdition(topic.editions[editionIndex]);
    }
  }
});
