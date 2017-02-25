require_relative 'scraper'

class MittagstischScraper < Scraper
  NAME = "Mittagstisch"

  def initialize
    @weekly_menu = WeeklyMenu.new(NAME)
  end

  def scrape
    page = Nokogiri::HTML(open("http://www.lakeside-scitec.com/services/gastronomie/mittagstisch/"))

    title = page.css('div.companyinfo h1')
    date_span_string =  title.text.split('|')[1]
    dates_span = date_span_string.strip.split('-')
    last_date_string = dates_span[1]
    first_date_string = dates_span[0]
    first_date_string += last_date_string.split('.')[2]

    dates = Array.new(5)
    dates[0] = DateTime.strptime(first_date_string, '%d.%m.%Y')
    dates[1] = dates[0] + 1
    dates[2] = dates[0] + 2
    dates[3] = dates[0] + 3
    dates[4] = dates[0] + 4

    day_data_table_row = page.css('table.daydata tr .td1')
    day_index = 0

    day_data_table_row.each_with_index do |row, index|
      if (row.text == "Suppe")
        @weekly_menu.menu_items.push(MenuItem.new(dates[day_index], day_data_table_row[index + 1].text))
        @weekly_menu.menu_items.push(MenuItem.new(dates[day_index], day_data_table_row[index + 2].text))
      end

      if (row.text == "Hauptspeise")
        if (day_data_table_row[index + 1].text.length > 1)
          @weekly_menu.menu_items.push(MenuItem.new(dates[day_index], day_data_table_row[index + 1].text))
        end

        if (day_data_table_row[index + 2].text.length > 1)
          @weekly_menu.menu_items.push(MenuItem.new(dates[day_index], day_data_table_row[index + 2].text))
        end

        if (day_data_table_row[index + 3].text.length > 1)
          @weekly_menu.menu_items.push(MenuItem.new(dates[day_index], day_data_table_row[index + 3].text))
        end

        day_index += 1
      end
    end
  end
end
