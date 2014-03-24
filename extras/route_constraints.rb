module RouteConstraints
  class JsEnabled
    def matches?(request)
      not (request.env["HTTP_USER_AGENT"] =~ /bot/ or
          request.path_parameters[:format] == 'json' or
          (Rails.env == 'test' and not request.path_parameters[:test])
      ) and request.query_parameters[:simple].nil?
    end
  end
end