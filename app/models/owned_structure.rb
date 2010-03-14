class OwnedStructure < ActiveRecord::Base
  belongs_to :user
  belongs_to :structure
  belongs_to :dwelling
end
