class FixRememberTokenName < ActiveRecord::Migration
  def change
    rename_column :users, :remember_token, :auth_token
  end
end
