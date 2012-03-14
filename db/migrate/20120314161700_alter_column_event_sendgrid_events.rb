class AlterColumnEventSendgridEvents < ActiveRecord::Migration
  def change
    rename_column :sendgrid_events, :event_type, :bounce_type
    rename_column :sendgrid_events, :event, :sendgrid_event_type
  end
end
