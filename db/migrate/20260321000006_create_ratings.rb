class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.references :resume, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :score, null: false
      t.timestamps
    end

    add_index :ratings, [:resume_id, :user_id], unique: true
  end
end
