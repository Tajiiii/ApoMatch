class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :services, dependent: :destroy
  attachment :image
  has_many :likes
  has_many :like_services, through: :likes, source: :service

  validates :name, :email, :phonenumber, :postcode, :address, presence: true
  validates :phonenumber, numericality: {only_integer: true}
  validates :postcode, length: {is: 7}, numericality: {only_integer: true}

  has_many :user_rooms
  has_many :chats

  def liked_by?(service_id)
    likes.where(service_id: service_id).exists?
  end
  has_many :comments, dependent: :destroy
#フォローしているユーザーを取り出す(user.followingsが使えるように)
  has_many :following_relationships, foreign_key: "follower_id", class_name: "Relationship", dependent: :destroy
  has_many :followings, through: :following_relationships
#フォローされているユーザーを取り出す(user.followersが使えるように)
  has_many :follower_relationships, foreign_key: 'following_id', class_name: "Relationship", dependent: :destroy
  has_many :followers, through: :follower_relationships
#フォローする
  def follow!(other_user)
  		following_relationships.create!(following_id: other_user.id)
  end
#フォロー外す
  def unfollow!(other_user)
    following_relationships.find_by(following_id: other_user.id).destroy
  end
#フォローしているか調べる
  def following?(other_user)
  	following_relationships.find_by(following_id: other_user.id)
  end

  has_many :active_notifications, class_name: "Notification", foreign_key: "visiter_id", dependent: :destroy
  has_many :passive_notifications, class_name: "Notification", foreign_key: "visited_id", dependent: :destroy

  def create_notification_follow!(current_user)
    temp = Notification.where(["visiter_id = ? and visited_id = ? and action = ?", current_user.id, id, 'follow'])
    if temp.blank?
      notification = current_user.active_notifications.new(
        visited_id: id,
        action: 'follow'
        )
      notification.save if notification.valid?
    end
  end

  def self.guest
    find_or_create_by!(email: 'guest@guest.com', name: 'ゲスト', phonenumber: '09012341234', address: '大阪市ゲスト1-1-1', postcode: '5767777', company: '株式会社ゲスト') do |user|
      user.password = SecureRandom.urlsafe_base64
    end
  end
  
end
