require "administrate/field/base"

class ActiveStorageField < Administrate::Field::Base
  def to_s
    data
  end
end
