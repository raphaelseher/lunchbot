# Lunchbot

Scripts to scrape lunch meals from websites near Lakeside Park in Klagenfurt (Carinthia) and send them to Slack.

# Install

1. Clone repo
2. Run `bundle install`
3. Run `scape_meals.rb` for scraping and saving to sqlite3 database
4. Run `eat.rb` to send __todays__ meals to Slack
5. (optional but useful) setup cron jobs for both scripts

# Write a new Scraper

Contribute a scraper with these steps:

1. Fork project
2. Create a new scraper in the scraper folder
3. Inherit from Scraper
4. Implement a scrape method
5. Save scraped data in `@weekly_menu` variable
6. Add scraper in `scrape_meals.rb`
7. Make a pull request

# Contributing

If you have ideas to add to this project feel free to open an issue, start a discussion, and implement it. If there are bugs or things I can do better, please let me know! Contribute code by forking the project, create a branch, make changes and then submit a pull request.