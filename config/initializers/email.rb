SendgridEventProxy::Application.configure do
  if File.exists?("#{Rails.root}/config/email.yml")
    email_settings = YAML::load(File.open("#{Rails.root}/config/email.yml"))
    config.action_mailer.smtp_settings = {
      :address => email_settings['address'],
      :port => email_settings['port'],
      :user_name => email_settings['user_name'],
      :password => email_settings['password']
    }
    config.action_mailer.delivery_method = :smtp
  else
    puts "No config/email.yml file found!"
    config.action_mailer.delivery_method = :test
  end
end
