class Job < ActiveRecord::Base
  # has_and_belongs_to_many :contacts

  before_validation :strip_attributes
  before_save :format_data

  validates :name,    presence: true,
                      length: { minimum: MIN_SIZE_JOB_NAME,
                                maximum: MAX_SIZE_DEFAULT_INPUT_TEXT },
                      format: { with: DEFAULT_NAME_REGEX },
                      uniqueness: { case_sensitive: false }
  validates :active,  inclusion: [true, false]

  def Job.simple_valid_record
    Job.new(name: "Developer")
  end

  private

    def strip_attributes
      self.name = name.squish unless name.nil?
    end

    def format_data
      self.name = name.capitalize
    end

end
