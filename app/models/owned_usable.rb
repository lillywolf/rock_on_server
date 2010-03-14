class OwnedUsable < ActiveRecord::Base
  belongs_to :user
  belongs_to :usable
end
