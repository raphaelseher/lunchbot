#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'

require_relative 'database'
require_relative 'weekly_menu'
require_relative 'scraper/uniwirtscraper.rb'
require_relative 'scraper/mittagstischscraper.rb'
require_relative 'scraper/unipizzeriascraper.rb'

DBNAME = "lunchdata.sqlite3"

def scrape_websites(scrapers)
  menus = []
  scrapers.each do |scraper|
    scraper.scrape
    menus.push(scraper.weeklyMenu)
  end

  puts "Scraped from #{menus.length} sites"
  menus.each do |weeklyMenu|
    puts ""
    puts "#{weeklyMenu.name}"
    weeklyMenu.menu_items.each do |menu_item|
      puts "## #{menu_item.date} #{menu_item.meal}"
    end
  end

  return menus
end

def save_to_database(menus)
  dbconnector = Databaseconnector.new(DBNAME)

  menus.each do |weeklyMenu|
    place_id = nil

    # get and insert place
    places = dbconnector.get_place(weeklyMenu.name)
    if places.length > 0
      place_id = places[0][0]
    else
      place_id = dbconnector.save_place(weeklyMenu.name)
    end

    weeklyMenu.menu_items.each do |menu_item|
      # set old entries to hidden
      results = dbconnector.get_menu(place_id, menu_item.date)
      results.each do |row|
        dbconnector.update_menu(row[0], 1)
      end
    end

    weeklyMenu.menu_items.each do |menu_item|
      dbconnector.save_menu(place_id, menu_item)
    end
  end
end

if __FILE__ == $0
  scrapers = []
  scrapers.push(UniwirtScraper.new)
  scrapers.push(MittagstischScraper.new)
  scrapers.push(UniPizzeriaScraper.new)

  menus = scrape_websites(scrapers)
  save_to_database(menus)
end