class SimplifyUserstamping < ActiveRecord::Migration[7.0]
  def change
    add_column :photos, :created_by, :string
    add_column :photos, :updated_by, :string

    add_column :reports, :created_by, :string
    add_column :reports, :updated_by, :string

    add_column :uploads, :created_by, :string
    add_column :uploads, :updated_by, :string

    add_column :users, :created_by, :string
    add_column :users, :updated_by, :string
    add_column :users, :deleted_by, :string

    reversible do |dir|
      dir.up do
        execute "UPDATE photos SET created_by = u.email FROM users AS u WHERE photos.creator_id = u.id"
        execute "UPDATE photos SET updated_by = u.email FROM users AS u WHERE photos.updater_id = u.id"

        execute "UPDATE reports SET created_by = u.email FROM users AS u WHERE reports.creator_id = u.id"
        execute "UPDATE reports SET updated_by = u.email FROM users AS u WHERE reports.updater_id = u.id"

        execute "UPDATE uploads SET created_by = u.email FROM users AS u WHERE uploads.creator_id = u.id"
        execute "UPDATE uploads SET updated_by = u.email FROM users AS u WHERE uploads.updater_id = u.id"

        execute "UPDATE users SET created_by = u.email FROM users AS u WHERE users.creator_id = u.id"
        execute "UPDATE users SET updated_by = u.email FROM users AS u WHERE users.updater_id = u.id"
        execute "UPDATE users SET deleted_by = u.email FROM users AS u WHERE users.deleter_id = u.id"
      end

      dir.down do
        execute "UPDATE photos SET creator_id = u.id FROM users AS u WHERE photos.created_by = u.email"
        execute "UPDATE photos SET updater_id = u.id FROM users AS u WHERE photos.updated_by = u.email"

        execute "UPDATE reports SET creator_id = u.id FROM users AS u WHERE reports.created_by = u.email"
        execute "UPDATE reports SET updater_id = u.id FROM users AS u WHERE reports.updated_by = u.email"

        execute "UPDATE uploads SET creator_id = u.id FROM users AS u WHERE uploads.created_by = u.email"
        execute "UPDATE uploads SET updater_id = u.id FROM users AS u WHERE uploads.updated_by = u.email"

        execute "UPDATE users SET creator_id = u.id FROM users AS u WHERE users.created_by = u.email"
        execute "UPDATE users SET updater_id = u.id FROM users AS u WHERE users.updated_by = u.email"
        execute "UPDATE users SET deleter_id = u.id FROM users AS u WHERE users.deleted_by = u.email"
      end
    end

    remove_column :photos, :creator_id, :integer
    remove_column :photos, :updater_id, :integer

    remove_column :reports, :creator_id, :integer
    remove_column :reports, :updater_id, :integer

    remove_column :uploads, :creator_id, :integer
    remove_column :uploads, :updater_id, :integer

    remove_column :users, :creator_id, :integer
    remove_column :users, :updater_id, :integer
    remove_column :users, :deleter_id, :integer
  end
end
