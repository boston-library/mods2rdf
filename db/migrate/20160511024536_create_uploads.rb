class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :institution
      t.string :attachment
      t.string :noid
      t.string :title_type
      t.string :name_type

      t.timestamps null: false
    end
  end
end
