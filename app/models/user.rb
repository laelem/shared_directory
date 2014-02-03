class User < ActiveRecord::Base
  before_create :create_remember_token
  before_validation :strip_attributes
  before_save :format_data

  validates :first_name,  presence: true,
                          length: { maximum: MAX_SIZE_USER_FIRST_NAME },
                          format: { with: DEFAULT_NAME_REGEX }

  validates :last_name,   presence: true,
                          length: { maximum: MAX_SIZE_USER_LAST_NAME },
                          format: { with: DEFAULT_NAME_REGEX }

  validates :email,       presence: true,
                          length: { maximum: MAX_SIZE_DEFAULT_INPUT_TEXT },
                          format: { with: VALID_EMAIL_REGEX },
                          uniqueness: { case_sensitive: false },
                          confirmation: true,
                          on: :create
  validates :email_confirmation, presence: true, on: :create

  has_secure_password
  validates :password,    length: { minimum: MIN_SIZE_USER_PASSWORD,
                                    maximum: MAX_SIZE_USER_PASSWORD },
                          on: :create

  validates :active,      inclusion: [true, false]
  validates :admin,       inclusion: [true, false]

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

    def strip_attributes
      %w(email email_confirmation password password_confirmation).each do |attr|
        self.send("#{attr}").strip! unless self.send("#{attr}").nil?
      end
      %w(first_name last_name).each do |attr|
        self.send("#{attr}=", self.send("#{attr}").squish) unless self.send("#{attr}").nil?
      end
    end

    def format_data
      self.first_name = first_name.downcase.titleize
      self.last_name = last_name.downcase.titleize
      self.email.downcase!
    end

end
