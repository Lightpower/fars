class Master < ActiveRecord::Base
  has_many :slaves
end
