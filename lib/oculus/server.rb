require 'rubygems'
require 'sinatra/base'
require 'sinatra_warden'
require 'oculus'
require 'oculus/presenters'
require 'json'

module Oculus
  class Server < Sinatra::Base

    use Rack::Auth::Basic, "Avant Credit Oculus" do |username, password|
      [username, password] == [(ENV['admin_name'] || 'admin'), (ENV['admin_password'] || 'dev')]
    end

#    register Sinatra::Warden

    set :root, File.dirname(File.expand_path(__FILE__))

    set :static, true

    set :public_folder, Proc.new { File.join(root, "server", "public") }
    set :views,         Proc.new { File.join(root, "server", "views")  }

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    get '/' do
      #authorize!
      erb :index
    end

    get '/starred' do
      #authorize!
      @queries = Oculus.data_store.starred_queries.map { |q| Oculus::Presenters::QueryPresenter.new(q) }

      erb :starred
    end

    get '/history' do
      #authorize!
      @queries = Oculus.data_store.all_queries.map { |q| Oculus::Presenters::QueryPresenter.new(q) }

      erb :history
    end

    post '/queries/:id/cancel' do
      #authorize!
      query = Oculus::Query.find(params[:id])
      connection = Oculus::Connection.connect(Oculus.connection_options)
      connection.kill(query.thread_id)
      [200, "OK"]
    end

    post '/queries' do
      #authorize!
      query = Oculus::Query.create(:query => params[:query])

      pid = fork do
        query = Oculus::Query.find(query.id)
        connection = Oculus::Connection.connect(Oculus.connection_options)
        query.execute(connection)
      end

      Process.detach(pid)

      [201, { :id => query.id }.to_json]
    end

    get '/queries/:id.json' do
      #authorize!
      query = Oculus::Query.find(params[:id])

      if query.error
        { :error => query.error }
      else
        { :results => query.results }
      end.to_json
    end

    get '/queries/:id' do
      #authorize!
      @query = Oculus::Presenters::QueryPresenter.new(Oculus::Query.find(params[:id]))

      @headers, *@results = @query.results

      erb :show
    end

    get '/queries/:id/download' do
      #authorize!
      query = Oculus::Query.find(params[:id])
      timestamp = query.started_at.strftime('%Y%m%d%H%M')

      attachment    "#{timestamp}-query-#{query.id}-results.csv"
      content_type  "text/csv"
      last_modified query.finished_at

      query.to_csv
    end

    get '/queries/:id/status' do
      #authorize!
      Oculus::Presenters::QueryPresenter.new(Oculus::Query.find(params[:id])).status
    end

    put '/queries/:id' do
      #authorize!
      @query = Oculus::Query.find(params[:id])
      @query.name    = params[:name]              if params[:name]
      @query.author  = params[:author]            if params[:author]
      @query.starred = params[:starred] == "true" if params[:starred]
      @query.save

      puts "true"
    end

    delete '/queries/:id' do
      #authorize!
      Oculus.data_store.delete_query(params[:id])
      puts "true"
    end
  end
end
