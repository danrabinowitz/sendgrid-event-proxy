# bundle exec rake force_post
task :force_post => :environment do
  sendgrid_events = SendgridEvent.where(:category => 'RWJFstd', :sendgrid_event_type => 'open')
  puts "#{sendgrid_events.size}"
  sendgrid_events.each do |se|
    se.post
  end
end
