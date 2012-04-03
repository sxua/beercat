class Beercat < Sinatra::Base
  before do
    require 'google_spreadsheet'
    @session = GoogleSpreadsheet.login(ENV['G_MAIL'], ENV['G_PASSWORD'])
  end

  helpers do
    def sort_by_count number
      @table.rows.slice(1..-1).map {|row| row[number]}.group_by {|c| c}.map {|k, v| {name: k, count: v.count}}.sort {|a, b| b[:count] <=> a[:count]}
    end
    
    def get_countries
      sort_by_count 2
    end
    
    def get_breweries
      sort_by_count 0
    end
  end

  get '/' do
    @table = @session.spreadsheet_by_key(ENV['G_KEY']).worksheets.first
    @countries, @breweries = get_countries, get_breweries
    erb :index, layout: :application
  end
end