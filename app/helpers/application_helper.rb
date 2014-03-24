module ApplicationHelper
  def title(page_title, options={})
    content_for(:title, page_title.to_s)
    return content_tag(:h1, page_title, options)
  end

  def resource_filter(name, current_value)
    names = name.pluralize.downcase
    select_tag 'filter', options_for_select(
        [['All ' << names, 'all'], ['Active '<< names << ' only', 'active']], current_value
    )
  end

  def ellipsis(string, options={delimiter: '...', length: 200})
    result = ""
    if string.length > options[:length]
      result << string[0, options[:length]]
      result << options[:delimiter]
    else
      result << string
    end
    result
  end
end
