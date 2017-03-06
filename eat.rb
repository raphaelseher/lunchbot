#!/usr/bin/env ruby
require 'rubygems'
require 'slack-notifier'

require_relative 'database'
require_relative 'weekly_menu'


PATH = "/opt/lunchbot/"
DBNAME = PATH + "lunchdata.sqlite3"
WEBHOOK = PATH + "slack-webhook"

def generate_weekly_menu(menus, places_data)
	places = Hash.new()
	places_data.each do |row|
		places[row[0]] = row[1]
	end

	weekly_menus = []
	menus.each do |row|
	 	menu = WeeklyMenu.new(places[row[1]])
	 	menu.addMenuItem(MenuItem.new(DateTime.iso8601(row[3]), row[2]))
	 	weekly_menus.push(menu)
	 end

	 return weekly_menus
end

def send_to_slack(todays_menu)
	notifier = nil
	File.foreach(WEBHOOK) {|hook| 
		notifier = Slack::Notifier.new URI.encode(hook)
	}

	menus_hash = Hash.new
	todays_menu.each do |menu|
		menu.menu_items.each do |item|
			meals = menus_hash[menu.name]
			if meals == nil
				meals = []
			end
			meals.push(item.meal)
			menus_hash[menu.name] = meals
		end
	end

	message = ""
	menus_hash.each do |place_name, meals|
		message = message + "*" + place_name + "* \n"
		meals.each do |meal|
			message = message + meal + "\n"
		end
		message = message + "\n"
	end

	puts message
	notifier.post text: message, icon_emoji: ":robot_face:", username: "Lunchbot"
end

if __FILE__ == $0
	 dbconnector = Databaseconnector.new(DBNAME)

	 today = DateTime.now
	 query_date = DateTime.new(today.year, today.mon, today.mday)
	 
	 menus = dbconnector.get_menus_with_date(query_date)
	 places = dbconnector.get_places()
	 todays_menu = generate_weekly_menu(menus, places)
	 send_to_slack(todays_menu)
end
