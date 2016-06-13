class AddNoteType < ActiveRecord::Migration
    def change
      add_column :uploads, :note_type, :string
    end
end
