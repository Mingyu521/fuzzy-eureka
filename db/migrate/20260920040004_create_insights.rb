class CreateInsights < ActiveRecord::Migration[8.1]
  def change
    create_table :insights do |t|
      t.string :project_id, null: false
      t.string :title, null: false
      t.string :value, null: false
      t.string :icon

      t.timestamps
    end

    add_foreign_key :insights, :projects
    add_index :insights, [ :project_id, :title ], unique: true
  end
end
