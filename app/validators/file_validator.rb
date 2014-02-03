class FileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless File.file? value
      record.errors[attribute] << "is not a file"
      return
    end

    unless File.readable_real? value
      record.errors[attribute] << "is not readable"
      return
    end

    if options[:extension]
      if options[:extension][:inclusion]
        ext = File.extname(value).downcase.split('.').last
        permitted_ext = options[:extension][:inclusion].join(", ")
        unless options[:extension][:inclusion].include? ext
          error_msg = "has a wrong type (permitted extensions : #{permitted_ext})"
          record.errors[attribute] << error_msg
          return
        end

        if options[:extension][:content_type]
          File.open(value) do |f|
            unless MimeMagic.by_magic(f) != nil and \
            options[:extension][:inclusion].include? MimeMagic.by_magic(f).subtype
              error_msg = "has a wrong content (permitted content : #{permitted_ext})"
              record.errors[attribute] << error_msg
              return
            end
          end
        end
      end
    end

    if options[:size] and options[:size][:maximum]
      File.open(value) do |f|
        if f.size > options[:size][:maximum]
          record.errors[attribute] << "is too large, maximum is #{MAX_SIZE_CONTACT_PHOTO/1.megabytes}Mb (#{MAX_SIZE_CONTACT_PHOTO})"
          return
        end
      end
    end
  end
end
