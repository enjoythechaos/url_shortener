require_relative 'user'

class ShortenedUrl < ActiveRecord::Base
  validates :short_url, uniqueness: true, presence: true
  validates :submitter_id, presence: true
  validates :long_url, presence: true

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :submitter_id,
    class_name: "User"

  has_many :visits,
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: "Visit"

  has_many :visitors,
    through: :visits,
    source: :visitor

  def self.random_code
    include SecureRandom
    new_code = nil
    loop do
      new_code = SecureRandom::urlsafe_base64
      if !ShortenedUrl.exists?(:short_url => new_code)
        break
      end
    end

    new_code
  end

  def self.create_for_user_and_long_url!(user, long_url)
    create!(:submitter_id => user.id, :long_url => long_url, :short_url => ShortenedUrl.random_code)
  end

  def num_clicks
    self.visitors.count
  end

  def num_uniques
    self.visitors.distinct.count
  end

  def num_recent_uniques
    visits.select('user_id').where("created_at > ?", 10.minutes.ago).distinct.count
  end
end
