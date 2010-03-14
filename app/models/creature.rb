class Creature < ActiveRecord::Base
  belongs_to :user
  has_many :owned_layerables
  has_many :owned_thingers
end
