class AddReminderToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :reminder_sent, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :games, :reminder_sent
  end
end
