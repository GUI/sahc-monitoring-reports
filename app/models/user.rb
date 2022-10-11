class User < ApplicationRecord
  acts_as_paranoid
  # model_stamper
  # stampable(:optional => true)

  devise :omniauthable, :trackable, :omniauth_providers => [:google_oauth2]

  # Validations
  validates :provider, :presence => true
  validates :uid, :presence => true

  def self.from_omniauth(auth)
    info = auth.info
    email = info["email"]
    email_domain = email.split("@").last
    if((ENV["ALLOWED_EMAIL_DOMAIN"].present? && email_domain == ENV["ALLOWED_EMAIL_DOMAIN"]) || (ENV["ALLOWED_EMAIL_ADDRESSES"].present? && ENV["ALLOWED_EMAIL_ADDRESSES"].split(",").map { |e| e.strip.presence }.compact.include?(email)))
      user = User.find_by(:provider => auth.provider, :uid => auth.uid)
      if(!user)
        user = User.create!({
          :provider => auth.provider,
          :uid => auth.uid,
          :email => info["email"],
          :first_name => info["first_name"],
          :last_name => info["last_name"],
          :name => info["name"],
        })
      end
    end

    user
  end
end
