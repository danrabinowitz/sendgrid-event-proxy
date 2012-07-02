class SendgridEvent < ActiveRecord::Base
  
  before_save  :normalize_email
  after_create :post
  
  SENDGRID_ATTRIBUTES = ['sendgrid_event_type',
                         'email',
                         'category',
                         'reason',
                         'response',
                         'attempt',
                         'bounce_type',
                         'status',
                         'url',
                         'timestamp']
  
  def to_ampersand_separated_s
     sendgrid_data = SENDGRID_ATTRIBUTES.map do |variable|
       sendgrid_value = self.send(variable)
       "#{variable}=#{sendgrid_value}" if sendgrid_value
     end.compact.join('&')
     URI.escape(sendgrid_data).gsub(/\+/,'%2B')
  end

  def normalize_email
    self.email = self.email.gsub(/[\<\>]/,'').strip
  end

  def url_to_post
    case category
    when 'RWJFstd', 'RWJF_STD'
      client = 'rwjf'
    else
      client,* = category.split('#') # "client1#campaign1#a"
    end
    return nil if client.nil? or client.downcase=='test'
    return nil if ["sendgrid-event-proxy"].include? client.downcase  # This avoids a circular reference, where warning emails generate warning emails!
    url = SendgridEventProxy::Application.config.destination_urls[client.downcase]
    begin
      WarningMailer.unknown_client_email(category,client).deliver if url.nil? && false
    rescue
      logger.warn("Unable to send email: #{$!}")
      raise
    end
    return url
  end
  
  def post
    return true if category.nil?
    return true if SendgridEventProxy::Application.config.allowed_nonstandard_categories.include? category

    return true if self.url_to_post.nil?
    begin
      Curl::Easy::http_post(self.url_to_post,self.to_ampersand_separated_s)
    rescue
      logger.warn("Unable to post to #{self.url_to_post}: #{$!}")
    end
    return true
  end

end
