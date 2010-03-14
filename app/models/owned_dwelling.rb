class OwnedDwelling < ActiveRecord::Base
  belongs_to :user
  belongs_to :dwelling
  has_many :owned_structures
end
