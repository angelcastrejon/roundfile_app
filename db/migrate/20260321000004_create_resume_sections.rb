class CreateResumeSections < ActiveRecord::Migration[8.0]
  def change
    create_table :resume_sections do |t|
      t.references :resume, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :resume_sections, [:resume_id, :section_id], unique: true
  end
end
