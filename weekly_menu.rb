class WeeklyMenu
  attr_accessor :menu_items, :name

  def initialize(name)
    @name = name
    @menu_items = Array.new
  end

  def addMenuItem(item)
    @menu_items.push(item)
  end
end

class MenuItem
  attr_accessor :date, :meal

  def initialize(date, meal)
    @date = date
    @meal = meal
  end
end
