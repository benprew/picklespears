class AddPasswordToPlayer < ActiveRecord::Migration
  def self.up
    add_column :users, :password, :string, :limit => 32
  end

  def self.down
    remove_column :users, :password
  end
end
