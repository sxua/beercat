class Beercat < Sinatra::Base
  before do
    require 'yaml'
    require 'google_spreadsheet'
    @google = YAML.load_file("google.yml")
    @session = GoogleSpreadsheet.login(@google['auth']['email'], @google['auth']['password'])
  end

  helpers do
    def sort_by_count number
      @table.rows.slice(1..-1).map {|row| row[number]}.group_by {|c| c}.map {|k, v| {:name => k, :count => v.count}}.sort {|a, b| b[:count] <=> a[:count]}
    end
    
    def get_countries
      sort_by_count 2
    end
    
    def get_breweries
      sort_by_count 0
    end
  end

  get '/' do
    @table = @session.spreadsheet_by_key(@google['doc']['key']).worksheets.first
    @countries, @breweries = get_countries, get_breweries
    erb :index, :layout => :application
  end
end