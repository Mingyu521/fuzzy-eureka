class Project < ApplicationRecord
  has_many :channels, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :insights, dependent: :destroy

  validates :name, presence: true

  before_create :generate_id, :generate_api_key

  private

  def generate_id
    self.id ||= loop do
      candidate = SecureRandom.alphanumeric(12)
      break candidate unless Project.exists?(candidate)
    end
  end

  def generate_api_key
    self.api_key ||= "ev_#{SecureRandom.hex(20)}"
  end
end
