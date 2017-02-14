task fix_how_to_host_your_service_history: :environment do
  dry_run = !ENV.key?('PERFORM_AGAINST_DATABASE_AND_PUBLISHING_API')
  migrator = ChangeNoteMigrator.new(dry_run: dry_run)

  # This guide has a funny history - we need to make it make sense
  # (retrospectively)

  # 1447 - v1 → v1 2016-08-25 11:19:53 UTC draft
  # 1450 - v1 → v1 2016-08-25 13:21:57 UTC draft
  # 1454 - v1 → v1 2016-08-25 13:57:41 UTC draft
  # 1455 - v1 → v1 2016-08-25 14:00:11 UTC draft
  # 1460 - v1 → v1 2016-08-25 14:05:16 UTC draft
  # 1461 - v1 → v1 2016-08-25 14:06:49 UTC draft
  # 1462 - v1 → v1 2016-08-25 16:43:56 UTC draft
  # 1463 - v1 → v1 2016-08-25 16:44:33 UTC draft
  # 1464 - v1 → v1 2016-08-25 16:45:49 UTC draft
  # 1465 - v1 → v1 2016-08-25 16:59:34 UTC draft
  # 1475 - v1 → v1 2016-08-26 14:08:39 UTC draft
  # 1476 - v1 → v1 2016-08-26 14:29:06 UTC draft
  # 1477 - v1 → v1 2016-08-26 14:31:04 UTC draft
  # 1478 - v1 → v1 2016-08-26 14:31:07 UTC review_requested
  # 1479 - v1 → v1 2016-08-26 14:37:58 UTC ready
  # 1480 - v1 → v1 2016-08-26 14:38:02 UTC published

  # Someone else who was already viewing the guide in its non published state
  # clicked save
  # 1481 - v1 → v2 2016-08-26 14:39:22 UTC draft
  # 1489 - v1 → v2 2016-08-26 14:48:31 UTC review_requested
  # 1490 - v1 → v2 2016-08-26 14:49:35 UTC draft
  # 1491 - v1 → v2 2016-08-26 14:49:56 UTC review_requested
  # 1492 - v1 → v2 2016-08-26 14:49:57 UTC ready
  # 1493 - v1 → v2 2016-08-26 14:50:01 UTC published

  def create_version_2(migrator)
    migrator.revise_version(1481, 2)
    migrator.revise_version(1489, 2)
    migrator.revise_version(1490, 2)
    migrator.revise_version(1491, 2)
    migrator.revise_version(1492, 2)
    migrator.revise_version(1493, 2)

    migrator.make_minor(1493)
  end

  # Legit new draft
  # 1698 - v2 → v3 2016-10-12 12:52:59 UTC draft
  # 1699 - v2 → v3 2016-10-12 12:53:17 UTC review_requested
  # 1700 - v2 → v3 2016-10-12 12:55:42 UTC ready
  # 1701 - v2 → v3 2016-10-12 12:55:54 UTC published

  # Someone else who was already viewing the guide in its review requested state
  # clicked approve
  # 1702 - v2 → v4 2016-10-12 12:56:07 UTC ready

  def create_version_3(migrator)
    migrator.revise_version(1698, 3)
    migrator.revise_version(1699, 3)
    migrator.revise_version(1700, 3)
    migrator.revise_version(1701, 3)

    migrator.revise_version(1702, 3)
  end

  # Legit new draft
  # 2464 - v2 → v4 2016-12-07 15:31:48 UTC draft
  # 2465 - v2 → v4 2016-12-07 15:31:49 UTC review_requested
  # 2466 - v2 → v4 2016-12-07 15:33:03 UTC ready
  # 2467 - v2 → v4 2016-12-07 15:33:07 UTC published

  def create_version_4(migrator)
    migrator.revise_version(2464, 4)
    migrator.revise_version(2465, 4)
    migrator.revise_version(2466, 4)
    migrator.revise_version(2467, 4)
  end

  # Legit new draft
  # 2715 - v3 → v5 2016-12-19 15:52:55 UTC draft
  # 2716 - v3 → v5 2016-12-19 15:52:56 UTC review_requested
  # 2721 - v3 → v5 2016-12-19 16:04:11 UTC ready
  # 2722 - v3 → v5 2016-12-19 16:04:49 UTC published

  def create_version_5(migrator)
    migrator.revise_version(2715, 5)
    migrator.revise_version(2716, 5)
    migrator.revise_version(2721, 5)
    migrator.revise_version(2722, 5)
  end

  # Legit new draft
  # 3000 - v4 → v6 2017-02-13 15:35:14 UTC draft
  # 3001 - v4 → v6 2017-02-13 15:35:37 UTC review_requested
  # 3011 - v4 → v6 2017-02-13 16:12:14 UTC ready
  # 3013 - v4 → v6 2017-02-13 16:12:24 UTC published

  def create_version_6(migrator)
    migrator.revise_version(3000, 6)
    migrator.revise_version(3001, 6)
    migrator.revise_version(3011, 6)
    migrator.revise_version(3013, 6)
  end

  # Work from highest version number backwards
  create_version_6(migrator)
  create_version_5(migrator)
  create_version_4(migrator)
  create_version_3(migrator)
  create_version_2(migrator)
end
