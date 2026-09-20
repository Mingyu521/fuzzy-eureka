class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :project_id, null: false
      t.string :channel, null: false
      t.string :title, null: false
      t.text :description
      t.string :icon
      t.jsonb :tags, default: {}
      t.string :url
      t.string :user_id
      t.boolean :notify, default: false, null: false
      t.boolean :favorited, default: false, null: false

      t.timestamps
    end

    add_foreign_key :events, :projects
    add_index :events, [ :project_id, :channel ]
    add_index :events, [ :project_id, :created_at ]
    add_index :events, :created_at
    add_index :events, :tags, using: :gin
  end
end
