require 'RMagick'
include Magick
require 'securerandom'

class Contact < ActiveRecord::Base
  before_validation :strip_attributes
  before_save :update_upload
  before_save :format_data, :process_upload
  before_destroy :delete_upload
  after_find :format_date

  validates :active,      inclusion: [true, false]
  validates :civility,    presence: true, inclusion: CIV.keys
  validates :first_name,  presence: true,
                          length: { minimum: MIN_SIZE_CONTACT_FIRST_NAME,
                                    maximum: MAX_SIZE_CONTACT_FIRST_NAME },
                          format: { with: DEFAULT_NAME_REGEX }
  validates :last_name,   presence: true,
                          length: { minimum: MIN_SIZE_CONTACT_LAST_NAME,
                                    maximum: MAX_SIZE_CONTACT_LAST_NAME },
                          format: { with: DEFAULT_NAME_REGEX }
  validates :date_of_birth_before_type_cast, date_format: {presence: true}

  has_and_belongs_to_many :jobs
  validates_associated :jobs
  validates :jobs, presence: true, active: true

  validates :address,     length: { maximum: MAX_SIZE_DEFAULT_INPUT_TEXT }
  validates :zip_code,    allow_blank: true, format: { with: /\A(\d{#{SIZE_ZIP_CODE}})\z/ }
  validates :city,        length: { maximum: MAX_SIZE_DEFAULT_INPUT_TEXT }
  belongs_to :country
  validates_associated :country

  validates :phone_number, allow_blank: true, format: { with: /\A(\d{#{MIN_SIZE_TEL},#{MAX_SIZE_TEL}})\z/ }
  validates :mobile_number, allow_blank: true, format: { with: /\A(\d{#{MIN_SIZE_TEL},#{MAX_SIZE_TEL}})\z/ }
  validates :email,       presence: true,
                          length: { maximum: MAX_SIZE_DEFAULT_INPUT_TEXT },
                          format: { with: VALID_EMAIL_REGEX },
                          uniqueness: { case_sensitive: false }

  validates :upload_photo, allow_blank: true, file: {
                            extension: { inclusion: %w(jpg jpeg gif png), content_type: true},
                            size: { maximum: MAX_SIZE_CONTACT_PHOTO }
                          }

  validates :website,     allow_blank: true, format: { with: URI::regexp(%w(http https)) }
  validates :comment,     length: { maximum: MAX_SIZE_CONTACT_COMMENT }

  def upload_photo
    @upload_photo
  end

  def upload_photo=(value)
    @upload_photo = value
    if defined? value.tempfile.path and File.file? value.tempfile.path
      filename = "image_" + SecureRandom.uuid + File.extname(value.original_filename).downcase
      self.photo = File.join(UPLOAD_PATH_CONTACT_PHOTO, filename).to_s
    else
      self.photo = nil
    end
  end

  private

    def strip_attributes
      %w(address zip_code city email website comment date_of_birth_before_type_cast).each do |attr|
        self.send("#{attr}").strip! unless self.send("#{attr}").nil?
      end
      %w(first_name last_name).each do |attr|
        self.send("#{attr}=", self.send("#{attr}").squish) unless self.send("#{attr}").nil?
      end
      %w(phone_number mobile_number).each do |attr|
        self.send("#{attr}").gsub!(/\s/, '') unless self.send("#{attr}").nil?
      end
    end

    def format_data
      self.first_name = first_name.downcase.titleize
      self.last_name = last_name.downcase.titleize
      self.city[0] = city[0].upcase unless city.blank?
      self.email.downcase!

      # Replace blank by nil for string attributes
      %w(address zip_code city website comment phone_number mobile_number).each do |attr|
        self.send("#{attr}=", nil) if self.send("#{attr}").blank?
      end
    end

    def format_date
      self.date_of_birth = self.date_of_birth.strftime("%d/%m/%Y")
    end

    def process_upload
      unless upload_photo.nil?
        img = Image.read(upload_photo.tempfile.path).first.resize_to_fit(ROWS_IMG_CONTACT_PHOTO, COLS_IMG_CONTACT_PHOTO)
        img.write(Rails.root.join('public', photo).to_s)
      end
    end

    def update_upload
      existing = Contact.find_by_id(self.id)
      if existing
        if upload_photo.nil?
          self.photo = existing.photo
        else
          unless photo.nil?
            existing_file = Rails.root.join('public', photo).to_s
            if File.file? existing_file then File.unlink existing_file end
          end
        end
      end
    end

    def delete_upload
      unless photo.nil? then File.unlink Rails.root.join('public', photo).to_s end
    end
end
