include ContactsHelper
require 'RMagick'
include Magick
require 'securerandom'

class Contact < ActiveRecord::Base
  before_validation :strip_attributes
  before_update :update_upload
  before_save :format_data, :process_upload
  before_destroy :delete_upload

  validates :active,      inclusion: [true, false]
  validates :civility,    inclusion: civ.keys
  validates :first_name,  presence: true,
                          length: { minimum: MIN_SIZE_CONTACT_FIRST_NAME,
                                    maximum: MAX_SIZE_CONTACT_FIRST_NAME },
                          format: { with: DEFAULT_NAME_REGEX }
  validates :last_name,   presence: true,
                          length: { minimum: MIN_SIZE_CONTACT_LAST_NAME,
                                    maximum: MAX_SIZE_CONTACT_LAST_NAME },
                          format: { with: DEFAULT_NAME_REGEX }
  validates :date_of_birth_before_type_cast, presence: true, date_format: true

  has_and_belongs_to_many :jobs
  validates_associated :jobs
  validates :jobs, presence: true, active: true

  validates :address,     length: { maximum: MAX_SIZE_DEFAULT_INPUT_TEXT }
  validates :zip_code,    allow_blank: true, format: { with: /\A(\d{5})\z/ }
  validates :city,        length: { maximum: MAX_SIZE_DEFAULT_INPUT_TEXT }
  belongs_to :country
  validates_associated :country

  validates :phone_number, allow_blank: true, format: { with: /\A(\d{10})\z/ }
  validates :mobile_number, allow_blank: true, format: { with: /\A(\d{10})\z/ }
  validates :email,       presence: true,
                          length: { maximum: MAX_SIZE_DEFAULT_INPUT_TEXT },
                          format: { with: VALID_EMAIL_REGEX },
                          uniqueness: { case_sensitive: false }

  validates :photo,       allow_blank: true, file: {
                            extension: { inclusion: %w(jpg jpeg gif png), content_type: true},
                            size: { maximum: MAX_SIZE_CONTACT_PHOTO }
                          }
  validates :website,     allow_blank: true, format: { with: URI::regexp(%w(http https)) }
  validates :comment,     length: { maximum: MAX_SIZE_CONTACT_COMMENT }

  def upload_photo
    File.open(photo) if File.file? photo and File.readable_real? photo
  end

  def upload_photo=(value)
    if value.is_a? File
      self.photo = value.path
    else
      self.photo = value
    end
  end

  def Contact.simple_valid_record
    Contact.new(civility: "M", first_name: "John", last_name: "Doe", date_of_birth: "19/06/1988",
      email: "user@example.com", jobs: [Job.simple_valid_record])
  end

  private

    def strip_attributes
      %w(address zip_code city email website comment date_of_birth_before_type_cast).each do |attr|
        self.send("#{attr}").strip! unless self.send("#{attr}").nil?
      end
      %w(first_name last_name phone_number mobile_number).each do |attr|
        self.send("#{attr}=", self.send("#{attr}").squish) unless self.send("#{attr}").nil?
      end
    end

    def format_data
      self.first_name = first_name.downcase.titleize
      self.last_name = last_name.downcase.titleize
      self.city[0] = city[0].upcase unless city.blank?
      self.email.downcase!

      # Replace blank by nil for string attributes
      %w(address zip_code city website comment phone_number mobile_number photo).each do |attr|
        self.send("#{attr}=", nil) if self.send("#{attr}").blank?
      end
    end

    def process_upload
      unless photo.nil?
        img = Image.read(photo).first.resize_to_fit(ROWS_IMG_CONTACT_PHOTO, COLS_IMG_CONTACT_PHOTO)
        filename = "image_" + SecureRandom.uuid + File.extname(photo).downcase
        self.photo = Rails.root.join(UPLOAD_PATH_CONTACT_PHOTO, filename).to_s
        img.write(photo)
      end
    end

    def update_upload
      existing = Contact.find_by_id(self.id)
      if File.file? existing.photo.to_s then File.unlink existing.photo end
    end

    def delete_upload
      unless photo.nil? then File.unlink photo end
    end
end
