class SendgridEvent < ActiveRecord::Base
  
  before_save  :normalize_email
  after_create :post
  
  SENDGRID_ATTRIBUTES = ['event',
                         'email',
                         'category',
                         'reason',
                         'response',
                         'attempt',
                         'event_type',
                         'status',
                         'url',
                         'timestamp']
  
  def to_ampersand_separated_s
     sendgrid_data = SENDGRID_ATTRIBUTES.map do |variable|
       sendgrid_value = self.send(variable)
       "#{variable}=#{sendgrid_value}" if sendgrid_value
     end.compact.join('&')
     URI.escape(sendgrid_data)
  end
  
  def normalize_email
    self.email = self.email.gsub(/[\<\>]/,'').strip
  end

  def url_to_post
    return nil if category.nil?
    client,* = category.split('#') # "client1#campaign1#a"
    return nil if client.nil? or client.downcase=='test'
    return nil if ["sendgrid-event-proxy"].includes? client.downcase  # This avoids a circular reference, where warning emails generate warning emails!
    url = SendgridEventProxy::Application.config.destination_urls[client.downcase]
    begin
      WarningMailer.unknown_client_email(category,client).deliver if url.nil?
    rescue
      logger.warn("Unable to send email: #{$!}")
      raise
    end
    logger.debug("x1b")
    return url
  end
  
  def post
    logger.debug("x1")
    return true if self.url_to_post.nil?
    logger.debug("x2")
    begin
      logger.debug("x3")
      Curl::Easy::http_post(self.url_to_post,self.to_ampersand_separated_s)
    rescue
      logger.warn("Unable to post to #{self.url_to_post}: #{$!}")
      raise
    end
    return true
  end

end
