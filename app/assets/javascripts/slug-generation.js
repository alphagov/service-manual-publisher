$(function() {
  var $form = $(".js-guide-form");

  if (!$form.length) {
    return;
  }

  var $title = $(".js-guide-title");
  var $slug = $(".js-slug");
  var $titleSlug = $(".js-title-slug");
  var $topicSection = $(".js-topic-section");

  var hasBeenPublished = $form.data("has-been-published");
  var titleSlugManuallyChanged = false;

  $(document).on("input", ".js-title-slug", function() {
    titleSlugManuallyChanged = true;
    generateSlug();
  });

  $(document).on("input", ".js-guide-title", generateSlug);
  $(document).on("change", ".js-topic-section", generateSlug);

  function generateSlug() {
    if (hasBeenPublished) {
      return;
    }

    if (!titleSlugManuallyChanged) {
      $titleSlug.val(slugify($title.val()));
    }

    var slug = "";

    var topicPath = $topicSection.find(":selected").parent().data("path");
    if (!topicPath) { return }
    slug += topicPath + "/";

    if (!$titleSlug.val()) { return }
    slug += slugify($titleSlug.val())

    $slug.val(slug);
  }

  generateSlug();

  function slugify(text) {
    // https://gist.github.com/mathewbyrne/1280286
    return text.toString().toLowerCase()
      .replace(/\s+/g, '-')        // Replace spaces with -
      .replace(/[^\w\-]+/g, '')    // Remove all non-word chars
      .replace(/\-\-+/g, '-')      // Replace multiple - with single -
      .replace(/^[-_]+/, '')       // Trim - and _ from start
      .replace(/[-_]+$/, '');      // Trim - and _ from end
  }
});
