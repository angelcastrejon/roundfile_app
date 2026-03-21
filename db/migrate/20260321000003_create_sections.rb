class CreateSections < ActiveRecord::Migration[8.0]
  def change
    create_table :sections do |t|
      t.string :section_type, null: false
      t.string :title, null: false
      t.text :content, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
