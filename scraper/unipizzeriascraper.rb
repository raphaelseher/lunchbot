require_relative 'scraper'

class UniPizzeriaScraper < Scraper
  NAME = "Uni Pizzeria"

  def initialize
    @weekly_menu = WeeklyMenu.new(NAME)
  end

  def scrape
    page = Nokogiri::HTML(open("http://www.uni-pizzeria.at/speisen/mittagsteller.html"))

    lines = page.css("div[itemprop='articleBody'] p")

    title = lines[0].text
    date_index = title =~ Regexp.new('[0-3]?[0-9].[0-3]?[0-9].(?:[0-9]{2})?[0-9]{2}')
    date_string = title[date_index..-1]

    dates = Array.new(5)
    dates[4] = DateTime.strptime(date_string, '%d.%m.%Y')
    dates[3] = dates[4] - 1
    dates[2] = dates[4] - 2
    dates[1] = dates[4] - 3
    dates[0] = dates[4] - 4

    weekday = []
    meals = []

    lines.each_with_index do |line, index|
      # skip title
      if line.to_s.include? "Mittagsteller"
        next
      end

      # skip seperators
      if line.text.include? "**"
        next
      end

      # find weekdays - the are always strong
      if line.to_s.include? "<strong>"
        if meals.length > 0
          weekday.push(meals)
          meals = []
        end

        # some weedays have the first meal in there p-tag
        # split by <br><br>
        if line.to_s.include? "<br><br>"
          splitted_lines = line.to_s.split('<br><br>')

          html = Nokogiri::HTML(splitted_lines[1])
          meals.push(html.text)
        end
      else
        if line.text.length > 2
          meals.push(line.text)
        end
      end
    end

    # push last meals
    weekday.push(meals)

    weekday.each_with_index do |meals, index|
      meals.each do |meal|
        @weekly_menu.menu_items.push(MenuItem.new(dates[index], meal))
      end
    end

  end
end
