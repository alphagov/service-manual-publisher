## Disparity between the database and the publishing API

There is some disparity between the content as it appears in our own database
and the content as it appears in the publishing api.

If at any point we switch to using the publishing api's content history feature,
or we switch to using the publishing api as our main source of truth for
content, we'll need to address one or more of these issues.

### Orphaned Content Items

When we allowed the URL to be edited up until a content item was published we
were unwittingly creating a bunch of content items that no longer relate to
guides in our publisher.

The impact today is very little. They're just "lost" in the publishing api.

### Rewritten History

Initially the frontend did not present change notes for guides. Once this
feature was added, we reviewed the way that edition types (minor / major) and
change notes had been used, and discovered that they were inconsistent and not
always useful to the reader.

Therefore a number of rake tasks were run which updated the database.

The [first rake task][migrate-change-notes] modified past editions – updating
change notes, changing edition types, etc.

The [second][make-first-editions-major] made all first editions major, and set
their change note to 'Guidance first published' – the same change note that is
[hard coded in publisher][default-change-note] for any new guides.

Finally, the [third rake task][fix-how-to-host] rewrote the history of one guide
which had two published editions with version 1. This happened because of a bug
in the publisher where versions of the form opened in a browser could be saved 
'out of order' – no locking was implemented.

These rake tasks only updated the editions in the publishers own database. No
attempt was made to reconcile the history as it appears in the publishing
platform. This worked because when the guide history is collated within
publisher using the edition history from the database.


[migrate-change-notes]: https://github.com/alphagov/service-manual-publisher/blob/7bf9a71737354096ca7c3e32fe940a822c8933a8/lib/tasks/migrate_change_notes.rake
[make-first-editions-major]: https://github.com/alphagov/service-manual-publisher/blob/master/lib/tasks/make_first_editions_major.rake
[fix-how-to-host]: https://github.com/alphagov/service-manual-publisher/blob/master/lib/tasks/fix_how_to_host_your_service_history.rake
[default-change-note]: https://github.com/alphagov/service-manual-publisher/blob/afd3952158024445b53833a02f8a2f637bac7ac9/app/forms/base_guide_form.rb#L113-L115
