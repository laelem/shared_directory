module ContactsHelper

  def current_filter(param, value)
    if session[:contacts][:filter].keys.include?(param) \
    && session[:contacts][:filter][param][:value] == value
      return ' current'
    else
      return ''
    end
  end
end