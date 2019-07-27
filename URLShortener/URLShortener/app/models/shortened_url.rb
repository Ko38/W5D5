# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint           not null, primary key
#  long_url   :string           not null
#  short_url  :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedUrl < ApplicationRecord
  validates :short_url, presence: true, uniqueness: true
  validates :long_url, :user_id, presence: true 

  def self.random_code
    random = SecureRandom.urlsafe_base64 
    while ShortenedUrl.exists?(:short_url => random)
      random = SecureRandom.urlsafe_base64
    end
    return random
  end

  # FACTORY METHOD
  def self.create_shorten(user, long_url)
    ShortenedUrl.create(short_url: ShortenedUrl.random_code,
    long_url: long_url, user_id: user.id)
  end

  has_many :visits,
    primary_key: :id,  
    foreign_key: :short_url_id,   
    class_name: :Visit  

  has_many :visitors,
  through: :visits,
  source: :user

   has_many :distinct_visitors,
   Proc.new { distinct },
   through: :visits,
   source: :user


  def num_clicks
    self.visits.count
  end

  # def num_uniques 
  #   self.visits.uniq { |v| v.user_id}.count
  # end

  def num_uniques 
    self.visits.select(:user_id).distinct.count
  end

  def num_recent_uniques
    self.visits.select(:user_id).where({created_at: (Time.now - 10.minutes )..Time.now} ).distinct.count
  end

end
