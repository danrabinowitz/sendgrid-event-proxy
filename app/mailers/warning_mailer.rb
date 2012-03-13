class WarningMailer < ActionMailer::Base
  default from: "sendgrid-event-proxy@vanheyst.com"

  def unknown_client_email(category,client)
    mail(:to => 'dan@vanheyst.com', :subject => "WARNING: Invalid Sendgrid category")
  end
end
