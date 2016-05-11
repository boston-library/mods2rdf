class Upload < ActiveRecord::Base
  mount_uploader :attachment, ModsXmlUploader # Tells rails to use this uploader for this model.
  validates :institution, presence: true # Make sure the owner's name is present.
end
