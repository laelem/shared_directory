module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Shared directory"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def display_sort(item, field, model)
    str = eval(model).human_attribute_name(field.to_sym)
    if defined? session[item][:sort][:field] and session[item][:sort][:field] == field
      if session[item][:sort][:type] == 'asc'
        str = '<span>&darr;</span> ' + str
      else
        str = '<span>&uarr;</span> ' + str
      end
    end
    return str.html_safe
  end
end
