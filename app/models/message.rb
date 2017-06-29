class Message < ApplicationRecord
  # when a user or a room is deleted, so are the associated messages
  belongs_to :user, dependent: destroy
  belongs_to :room, dependent: destroy

end
