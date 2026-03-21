module AdminHelper
  def admin_nav_link(label, path, section)
    active = request.path.start_with?("/admin/#{section}") || (section == "dashboard" && request.path == "/admin")
    css = if active
      "block px-3 py-2 rounded-md text-sm font-medium bg-gray-200 text-gray-900"
    else
      "block px-3 py-2 rounded-md text-sm font-medium text-gray-600 hover:bg-gray-200 hover:text-gray-900"
    end
    link_to label, path, class: css
  end
end
