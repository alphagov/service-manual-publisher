$(function() {
  var $form = $(".js-autogenerate-slug");

  if (!$form.length) {
    return;
  }

  var $title = $(".js-title");
  var $slug = $(".js-slug");
  var $titleSlug = $(".js-title-slug");
  var $topicSection = $(".js-topic-section");

  var hasBeenPublished = $form.data("has-been-published");
  var titleSlugManuallyChanged = titleSlugPreviouslyChanged();

  $(document).on("input", ".js-title-slug", function() {
    titleSlugManuallyChanged = true;
    generateSlug();
  });

  $title.on("input", generateSlug);
  $topicSection.on("change", generateSlug);

  function generateSlug() {
    // Slug can't be changed if the thing has ever been published.
    if (hasBeenPublished) {
      return;
    }

    // Update the title slug field as long as it hasn't been manually edited yet
    if (!titleSlugManuallyChanged) {
      $titleSlug.val(slugifiedTitle());
    }

    var slug = "";
    slug += slugPrefix();
    slug += topicSectionPathIfPresent();
    slug += "/" + slugifiedSlugTitle();

    $slug.val(slug);
  }

  function topicSectionPathIfPresent() {
    var $topicSection = $(".js-topic-section");

    if ($topicSection.length) {
      var selectedParent = $topicSection.find(":selected").parent('optgroup');

      if (selectedParent.length) {
        return selectedParent.data("path");
      }
    }

    return "";
  }

  function slugPrefix() {
    return $form.data("slug-prefix");
  }

  function slugifiedTitle() {
    return slugify($title.val());
  }

  function slugifiedSlugTitle() {
    return slugify($titleSlug.val());
  }

  function titleSlugPreviouslyChanged() {
    return $titleSlug.val() != slugifiedTitle();
  }

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
