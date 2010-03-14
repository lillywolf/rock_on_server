class OwnedThinger < ActiveRecord::Base
  belongs_to :user
  belongs_to :thinger
end
