class WebsiteLoader

  def initialize(url)
    @url = url
  end

  def load
    return Nokogiri::HTML(open(@url))
  end

end
