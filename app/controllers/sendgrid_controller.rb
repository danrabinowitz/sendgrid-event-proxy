class SendgridController < ActionController::Base
  def event
    begin
      logger.debug("Remote IP: #{request.remote_ip}")
      @sendgrid_params = request.request_parameters
      @sendgrid_params.merge!({"event_type" => @sendgrid_params.delete("type")}) if @sendgrid_params["type"]
      @sendgrid_params.delete_if{|key,value| not SendgridEvent::SENDGRID_ATTRIBUTES.include?(key) }
      @sendgrid_event = SendgridEvent.create(@sendgrid_params)
    rescue
      @sendgrid_event = nil
    end
    render :nothing => true
  end
  
  # Curl:
  # curl -D - -d "event=processed&email=test" http://localhost:3000/sendgrid_event
  # curl -D - -d "event=processed&email=test&category=client1#campaign2#g" http://localhost:3000/sendgrid_event
  #
  # Curb:   
  # Curl::Easy::http_post("http://localhost:3000/sendgrid_event","event=processed&email=test")
end