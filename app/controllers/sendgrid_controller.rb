class SendgridController < ActionController::Base
  def event
    begin
      @sendgrid_params = request.request_parameters
      @sendgrid_params.merge!({"bounce_type" => @sendgrid_params.delete("type")}) if @sendgrid_params["type"]
      @sendgrid_params.merge!({"sendgrid_event_type" => @sendgrid_params.delete("event")}) if @sendgrid_params["event"]
      @sendgrid_params.delete_if{|key,value| not SendgridEvent::SENDGRID_ATTRIBUTES.include?(key) }
      unless ["sendgrid-event-proxy#unknown_client_email"].include? @sendgrid_params["category"] # No need to save these
        @sendgrid_event = SendgridEvent.create(@sendgrid_params.merge({"remote_ip" => request.remote_ip}))
      end
    rescue
      @sendgrid_event = nil
    end
    render :nothing => true
  end
  
  # Curl:
  # curl -D - -d "event=processed&email=test" http://localhost:3000/sendgrid_event
  # curl -D - -d "event=processed&email=test&category=client1#client_specific_info" http://localhost:3000/sendgrid_event
  #
  # Curb:   
  # Curl::Easy::http_post("http://localhost:3000/sendgrid_event","event=processed&email=test")
end