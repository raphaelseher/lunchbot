require_relative '../scraper/mensaklagenfurtscraper'

require 'nokogiri'
require 'test/unit'


class MensaKlagenfurtScraperTest < Test::Unit::TestCase

	def setup
		@mock_loader = MockLoader.new()
		@scraper = MensaKlagenfurtScraper.new(@mock_loader)
	end

	def test_scrape
			@scraper.scrape()

			assert(@scraper.weekly_menu != nil, "Menu should be set")
			assert(@scraper.weekly_menu.name == "Mensa Klagenfurt",
				"Name should be set")

			assert(@scraper.weekly_menu.menu_items[0].date == 
				Date.strptime("19.06.2017", "%d.%m.%Y"))
			assert(@scraper.weekly_menu.menu_items[0].meal ==
				"Linguini (A, C) Bärlauch Pesto (G) frisch geriebener Grana Padano (G)", "")

			assert(@scraper.weekly_menu.menu_items[1].date == 
				Date.strptime("19.06.2017", "%d.%m.%Y"))
			assert(@scraper.weekly_menu.menu_items[1].meal ==
				"Tomatencremesuppe (G, L) Vegane Eblygemüsepfanne (A) dazu Menüsalat (M, O)", "")

			assert(@scraper.weekly_menu.menu_items[2].date == 
				Date.strptime("19.06.2017", "%d.%m.%Y"))
			assert(@scraper.weekly_menu.menu_items[2].meal ==
				"Tomatencremesuppe (G, L) Putengeschnetzeltes Züricher Art (G, L, O) Butterreis (G) dazu  Menüsalat (M, O)", "")
	end

end

class MockLoader

	def load
		html_string = File.read(File.join(File.dirname(__FILE__), 'mensadata.html'))
		return Nokogiri::HTML(html_string)
	end

end
