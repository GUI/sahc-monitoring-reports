class AddMonetaCacheTable < ActiveRecord::Migration[7.0]
  def change
    create_table("moneta_cache", id: :string, primary_key: "key") do |t|
      t.binary :value, null: false
      t.virtual :value_size, null: false, type: :bigint, as: "length(value)", stored: true
      t.timestamptz :created_at, null: false, default: -> { "transaction_timestamp()" }
      t.index :created_at, order: "DESC"
    end

    reversible do |dir|
      dir.up do
        execute "ALTER TABLE moneta_cache SET UNLOGGED"
      end
    end
  end
end
