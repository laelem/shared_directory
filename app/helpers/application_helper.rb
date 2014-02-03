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

  def display_sort(item, field)
    if defined? session[item][:sort][:field] and session[item][:sort][:field] == field
      if session[item][:sort][:type] == 'asc'
        '<span>&darr;</span> '
      else
        '<span>&uarr;</span> '
      end
    else
      ''
    end
  end
end
