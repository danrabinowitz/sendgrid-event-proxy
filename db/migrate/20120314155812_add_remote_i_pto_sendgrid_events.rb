class AddRemoteIPtoSendgridEvents < ActiveRecord::Migration
  def change
    add_column :sendgrid_events, :remote_ip, :string
  end
end
