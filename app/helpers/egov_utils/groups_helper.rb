module EgovUtils
  module GroupsHelper

    def principals_check_box_tags(name, principals)
      s = ''
      principals.each do |principal|
        s << "<label>#{ check_box_tag name, principal.id, false, :id => nil } #{h principal}</label>\n"
      end
      s.html_safe
    end

  end
end
