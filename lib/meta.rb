module GenerateMeta
  GenerateError = Class.new(StandardError)

  def meta_description
    if (desc = @item[:meta_description] || (@item[:subtitle] unless @item[:kind] == 'article'))
      "<meta name=\"description\" content=\"#{strip_html(desc)}\""
    end
  end
end
