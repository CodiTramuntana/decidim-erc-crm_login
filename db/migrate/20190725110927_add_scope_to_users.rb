# frozen_string_literal: true

class AddScopeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :decidim_scope_id, :integer
  end
end
