#!/usr/bin/env ruby
require 'rubygems'
require 'slack-notifier'

require_relative 'database'
require_relative 'weekly_menu'

DBNAME = "lunchdata.sqlite3"

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
	File.foreach('slack-webhook') {|hook| 
		notifier = Slack::Notifier.new hook
	}
	
	if notifier == nil
		raise "No slack-webhook connection. Have you created a slack-webhook file?"
	end

	menus_hash = Hash.new
	todays_menu.each do |menu|
		menu.menu_items.each do |item|
			value = menus_hash[menu.name]
			if value == nil
				value = []
			end
			value.push(item.meal)
			menus_hash[menu.name] = value
		end
	end

	message = ""
	menus_hash.each do |key, value|
		message = message + "*" + key + "* \n"
		value.each do |meal|
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