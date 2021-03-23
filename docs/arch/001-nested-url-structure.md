# Nested URL structure

## Context

The service manual guide URLs are nested under their topic. There are benefits and drawbacks to the nested URL in the context of GOV.UK, which we discuss retrospectively here for posterity and hopefully to aid any decision making if we'd like to change it to a flat URL structure in the future.

## Benefits

### Navigation by editing the URL

We saw in user testing that users navigated the prototype by editing the URL in the address bar. This benefit isn't applicable if the address bar isn't visible, as is the case on mobile or on desktop Safari. However, service manual users don't tend to use mobile or desktop Safari.

### SEO

There are two potential SEO benefits.

The first is that having the topic in the URL increases the keyword density.

The second is that the nesting reveals the site's hierarchy which google can potentially use when deducing relevancy. A page nested under a category, eg. /agile/scrum, provides slightly different, hierarchical context than if the URL were /agile-scrum.

### Performance analysis

When viewing the standard reports in Google Analytics it is only possible to segment by two dimensions. For example, you might segment by page URL and platform (eg. mobile, desktop, device).

To segment by a third dimension a custom report is needed.

With a nested URL, the topic is in the page URL so it's possilble to filter a standard report to a topic without using up an additional dimension.

Therefore, with a nested URL structure, standard reporting is still possible which is simpler and more pleasant to use than custom reports.

## Drawbacks

We need to know the topic when creating a guide. This is because it is not possible to save a guide draft without a URL and we include the topic in the URL.

This has the following effects.

* People don't want to commit to a topic before they start writing which contributes to the behaviour of avoiding the publisher in favour of Google Docs.
* The UI for creating a guide is slightly more complicated because a topic needs to be chosen.
* Changing topic is complex. To do so requires recreating the guide, and unpublishing and redirecting the old one. While this application still has it's own database, it would be technically possible to create a "clone" feature in order to reduce the UX complexity and preserve the history. However, once we move to phase 2 of the migration, the history on both the frontend and publisher will be lost when recreating a guide.
* Because incorrect URLs are more likely we are permanently maintaining more redirects than we would otherwise need to.
