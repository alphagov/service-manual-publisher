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
    // Slug can't be changed if the guide has ever been published.
    if (hasBeenPublished) {
      return;
    }

    // If a user has manually changed the slug, then we don't generate
    // it from the title anymore.
    if (!titleSlugManuallyChanged) {
      $titleSlug.val(slugify($title.val()));
    }

    var slug = "";

    // We get the first part of the full from the chosen topic sections' topic.
    // This will be in the format /service-manual/topic-path
    var topicPath = $topicSection.find(":selected").parent().data("path");
    if (!topicPath) { return }
    slug += topicPath + "/";

    // Now add whatever title slug was generated (or manually entered by user)
    // to the full slug.
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
