class OwnedLayerable < ActiveRecord::Base
  belongs_to :layerable
  belongs_to :user
  belongs_to :creature
end
