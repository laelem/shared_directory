class Country < ActiveRecord::Base
  before_validation :strip_attributes
  before_save :format_data

  has_many :contacts
  validates :code,  presence: true,
                    length: { is: SIZE_COUNTRY_CODE },
                    uniqueness: { case_sensitive: false },
                    format: { with: /\A[a-zA-Z]+\z/ }
  validates :name,  presence: true,
                    length: { minimum: MIN_SIZE_COUNTRY_NAME,
                              maximum: MAX_SIZE_DEFAULT_INPUT_TEXT },
                    uniqueness: { case_sensitive: false }

  def Country.simple_valid_record
    Country.new(code: "XY", name: "New Country")
  end

  private

    def strip_attributes
      self.code = code.squish unless code.nil?
      self.name = name.squish unless name.nil?
    end

    def format_data
      self.code.upcase!
      self.name[0] = name[0].upcase
    end

end
