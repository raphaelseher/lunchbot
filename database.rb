require 'rubygems'
require 'sqlite3'

class Databaseconnector

	def initialize(dbname)
		@db = SQLite3::Database.new(dbname)
		setup()
	end

	def setup()
	  @db.execute("CREATE TABLE IF NOT EXISTS place(id INTEGER PRIMARY KEY, 
	    name TEXT, 
	    address TEXT, 
	    city TEXT,
	    created TEXT)")
	  @db.execute("CREATE TABLE IF NOT EXISTS menu(id INTEGER PRIMARY KEY, 
	    place_id INTEGER, 
	    item TEXT,
	    date TEXT,
	    hidden INTEGER, 
	    created TEXT,
	    FOREIGN KEY(place_id) REFERENCES place(id))")
	end

	def save_place(name)
		results = get_place(name)
		if (results.length > 0) 
			return results[0][0]
		end

		query = "INSERT INTO place(name, created) VALUES(?, ?)"
		@db.execute(query, name.to_s, DateTime.now.iso8601())
		id = @db.last_insert_row_id()
		return id
	end

	def save_menu(place_id, menu_item)
		query = "INSERT INTO menu(place_id, item, date, hidden, created) VALUES(?, ?, ?, ?, ?)"
		@db.execute(query, place_id, menu_item.meal, menu_item.date.iso8601(), 0, DateTime.now.iso8601())
	end

	def update_menu(id, hidden)
		query = "UPDATE menu SET hidden = ? WHERE id = ?"
		@db.execute(query, hidden, id)
	end

	def get_menu(place_id, date)
		query = "SELECT * FROM menu WHERE place_id = ? 
			AND date = ? AND hidden = 0"
		results = @db.execute(query, place_id, date.iso8601())

		return results
	end

	def get_menus_with_date(date)
		query = "SELECT * FROM menu WHERE 
			date = ? AND hidden = 0"
		results = @db.execute(query, date.iso8601())
		return results
	end

	def get_place(name)
		query = "SELECT * FROM place WHERE name LIKE ?"
		results = @db.execute(query, name.to_s)
		return results
	end

	def get_places()
		query = "SELECT id, name from place"
		results = @db.execute(query)
		return results
	end
end