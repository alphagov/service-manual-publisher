task migrate_change_notes: :environment do
  migrator = ChangeNoteMigrator.new(dry_run: !ENV.key?('PERFORM_AGAINST_DATABASE_AND_PUBLISHING_API'))

  # Agile methods: an introduction
  migrator.make_minor(1403)

  # Agile tools and techniques
  migrator.make_minor(143)
  migrator.make_minor(157)

  # Creating an agile working environment
  migrator.update_change_note(35, "Guidance first published")
  migrator.update_change_note(148, "Added details of collaborative tools, including Trello, Slack, Basecamp, Yammer, Hipchat, Confluence, and Google Drive.")

  # Planning in agile
  migrator.update_change_note(144, "Added further reading blog on making clear goals for complex agile programmes.")

  # Agile delivery community
  migrator.make_minor(228)
  migrator.update_change_note(1379, "Added guides to how the discovery, alpha, beta and live phases work, and 'Retiring your service'.")

  # Performance and data analysis community
  migrator.make_minor(332)
  migrator.make_major(1075, "Added link to the digital analysts UK government services (DAUGS) Basecamp.")

  # Technology community (technical architecture)
  migrator.make_minor(1047)
  migrator.update_change_note(1381, "Added guide to 'Moving away from legacy systems'.")

  # Technology community (web operations)
  migrator.make_minor(1044)
  migrator.update_change_note(1383, "Added guides to 'Deploying software regularly' and 'Deciding how to host your service'.")

  # User research community
  migrator.make_minor(178)
  migrator.make_minor(193)
  migrator.update_change_note(1031, "Added guides to getting users' consent for research, sharing findings and analysing research sessions.")
  migrator.make_major(2128, "Added guides for research in discovery, alpha, beta and live.")

  # Assisted digital support: an introduction
  migrator.update_change_note(4, "Guidance first published")

  # Designing assisted digital support
  migrator.update_change_note(3, "Guidance first published")
  migrator.update_change_note(1242, "Added details of the framework teams can use to buy assisted digital support.")

  # Making your service accessible: an introduction
  migrator.make_minor(265)

  # Check if you need to get your service assessed
  migrator.update_change_note(1246, "Added link to 'How your assisted digital support will be assessed'.")

  # How service assessments work
  migrator.update_change_note(1244, "Added link to 'How your assisted digital support will be assessed'.")

  # 12. Make sure users succeed first time
  migrator.update_change_note(1222, "Amended point title to state most users should be able to succeed the first time they use a service.")

  # Designing for different browsers and devices
  migrator.update_change_note(1509, "Updated the list of browsers to test in for public-facing and government-only services.")

  # Quality assurance: testing your service regularly
  migrator.update_change_note(947, "Guidance first published")

  # Vulnerability and penetration testing
  migrator.update_change_note(1427, "Updated the list of CREST-certified companies you can hire to test your service.")

  # Running more than one service team
  migrator.update_change_note(161, "Added agile working examples and case studies.")

  # Working with contractors or third parties
  migrator.update_change_note(1697, "Added link to 'Digital Marketplace buyers’ guide'.")

  # Understanding users who don't use digital services
  migrator.update_change_note(57, "Guidance first published")
end
