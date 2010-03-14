class Store < ActiveRecord::Base
  has_many :thingers, :through => :store_owned_thingers
  has_many :layerables, :through => :store_owned_thingers
end
