# app/controllers/home_controller.rb
class HomeController < ApplicationController
    def index
      @today = Date.today
      @weekends = Scraper.fetch_weekends(@today)
  
      @grouped_results = {}
      @weekends.each do |date|
        formatted_date = date.strftime("%Y-%m-%d")
        @grouped_results[formatted_date] = Scraper.fetch_reservation_data(formatted_date)
      end
    end
  end
  