class WarningMailer < ActionMailer::Base
  default from: "sendgrid-event-proxy@vanheyst.com"

  def unknown_client_email(category,client)
    @category = category
    @client = client
    headers['X-SMTPAPI'] = {"category" => "sendgrid-event-proxy#unknown_client_email"}.to_json
    mail(:to => 'dan@vanheyst.com', :subject => "WARNING: Invalid Sendgrid category")
  end
end
