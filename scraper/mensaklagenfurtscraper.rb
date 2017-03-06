require_relative 'scraper'

class MensaKlagenfurtScraper < Scraper
  NAME = "Mensa Klagenfurt"

  def initialize
    @weekly_menu = WeeklyMenu.new(NAME)
  end

  def scrape
    page = Nokogiri::HTML(open("http://menu.mensen.at/index/index/locid/45"))

    dates = []
    days = page.css('div#speiseplan div#week div#days div.day')
    days.each do |day|
    	date_string = day.css('span.date').text
    	date = DateTime.strptime(date_string, "%d.%m.%Y")
    	dates.push(date)
   	end

		content = []
	  categories = page.css('div.category div.category-content')
	  categories.each do |categorie|
	  	if !categorie.text.include? 'Grillcorner'
	   		content.push(categorie)
	  	end
	  end

	  meals = []
		content.each do |menu|
			meal = ''
			
			menu.css('p').each do |p|
				if p.text.include? '€'
					meals.push(meal)
					break
				end

				meal = meal + p.text + " "
			end
		end

		index = 0
		dates.each do |date|
			day_meals = meals[index..index+2]
			day_meals.each do |meal|
				@weekly_menu.addMenuItem(MenuItem.new(date, meal))
			end
			index = index + 3
		end
	end
end
