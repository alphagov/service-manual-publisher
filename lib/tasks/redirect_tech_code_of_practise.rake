desc "This is a one off task to redirect tech code of practise"
task redirect_tech_code_of_practise: :environment do
  old_paths = [
    "/service-manual/technology/code-of-practice.html",
    "/service-manual/technology/code-of-practice",
  ]
  new_path = "/government/publications/technology-code-of-practice/technology-code-of-practice"

  old_paths.each do |old_path|
    payload = {
      format: "redirect",
      base_path: old_path,
      publishing_app: "service-manual-publisher",
      redirects: [
        {
          path: old_path,
          type: "exact",
          destination: new_path,
        }
      ]
    }

    content_id = SecureRandom.uuid

    PUBLISHING_API.put_content(content_id, payload)
    PUBLISHING_API.publish(content_id, "major")
  end
end
