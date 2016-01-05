$(function() {
  var $title = $(".js-guide-title");
  var $slug = $(".js-guide-slug");
  var autoGenerate = $slug.val() == "/service-manual/";

  $(document).on("input", ".js-guide-slug", function() {
    autoGenerate = false;
  });

  $(document).on("input", ".js-guide-title", function() {
    if (autoGenerate) {
      $slug.val("/service-manual/" + slugify($title.val()));
    }
  });

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
