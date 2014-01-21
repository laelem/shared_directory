class ActiveValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.map{ |item| item.send("active?") }.include? false
      record.errors[attribute] << "can't contain inactive #{attribute}"
    end
  end
end
