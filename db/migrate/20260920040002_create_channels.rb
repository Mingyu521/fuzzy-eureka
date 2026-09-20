class CreateChannels < ActiveRecord::Migration[8.1]
  def change
    create_table :channels do |t|
      t.string :project_id, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_foreign_key :channels, :projects
    add_index :channels, [ :project_id, :name ], unique: true
  end
end
