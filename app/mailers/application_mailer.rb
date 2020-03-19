class ApplicationMailer < Mail::Notify::Mailer
  def self.no_reply_email_address
    name = "(Service Manual) DON'T REPLY"
    if GovukAdminTemplate.environment_label !~ /production/i
      name.prepend("[GOV.UK #{GovukAdminTemplate.environment_label}] ")
    end

    address = Mail::Address.new("inside-government@digital.cabinet-office.gov.uk")
    address.display_name = name
    address.format
  end

  default from: no_reply_email_address
  layout "mailer"

private

  def user_email(user)
    address = Mail::Address.new(user.email)
    address.display_name = user.name
    address.format
  end

  def template_id
    @template_id ||= ENV.fetch("GOVUK_NOTIFY_TEMPLATE_ID", "fake-test-template-id")
  end
end
