require_relative 'scraper'

class UniwirtScraper < Scraper
  NAME = "Uniwirt"

  def initialize
    @weekly_menu = WeeklyMenu.new(NAME)
  end

  def scrape
    page = Nokogiri::HTML(open("http://www.uniwirt.at/wp/"))
    div_mittag = page.css('div#mittag')

    all_menu_items = []

    mittag_items = div_mittag.css('div.wpb_column.vc_column_container.vc_col-sm-2')
    mittag_items.each do |item|
      date = nil
      meals = []
      item.css('p').each_with_index do |p, index|
        if index == 0
          date = DateTime.strptime(p.text, '%d.%m.%y')
        else
          meals.push(p.text)
        end
      end

      meals.each do |meal|
        all_menu_items.push(MenuItem.new(date, meal))
      end
    end

    @weekly_menu.menu_items = all_menu_items
  end
end
