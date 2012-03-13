class WarningMailer < ActionMailer::Base
  default from: "sendgrid-event-proxy@vanheyst.com"

  def unknown_client_email(category,client)
    @category = category
    @client = client
    headers["category"] = "sendgrid-event-proxy#unknown_client_email"
    mail(:to => 'dan@vanheyst.com', :subject => "WARNING: Invalid Sendgrid category")
  end
end
