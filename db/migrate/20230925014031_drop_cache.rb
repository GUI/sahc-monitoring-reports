class DropCache < ActiveRecord::Migration[7.0]
  def change
    drop_table :moneta_cache
  end
end
