class Collection < ApplicationRecord
  belongs_to :account

  enum visibility: {
    private: 0,
    public: 1
  }, _prefix: true

  validates :name, presence: true
end
