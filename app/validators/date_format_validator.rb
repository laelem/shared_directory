class DateFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    attribute = attribute.to_s[0..-18].to_sym
    if defined? options[:presence] and options[:presence] and value.blank?
      record.errors[attribute] << "can't be blank"
    end
    unless value =~ /\A(\d{2}\/\d{2}\/\d{4})\z/ and \
    Date.valid_date? *value.split('/').reverse.map(&:to_i)
      record.errors[attribute] << "is not a valid date"
    end
  end
end
