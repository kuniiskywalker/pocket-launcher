require "rubygems"
require "sinatra"
require "pocket"

require 'cgi'

require "faraday"

# URLにアクセスするためのライブラリの読み込み
require 'open-uri'

require './htmlstripper.rb'

enable :sessions

CALLBACK_URL = "#{ENV["HTTP_HOST"]}/oauth/callback"

Pocket.configure do |config|
  config.consumer_key = ENV["POCKET_CONSUMER_KEY"] 
end

get '/reset' do
  puts "GET /reset"
  session.clear
end

get "/" do
  puts "GET /"
  puts "session: #{session}"

  if session[:access_token]
    redirect '/retrieve'
  else
    '<a href="/oauth/connect">Connect with Pocket</a>'
  end
end

get "/oauth/connect" do
  puts "OAUTH CONNECT"
  session[:code] = Pocket.get_code(:redirect_uri => CALLBACK_URL)
  new_url = Pocket.authorize_url(:code => session[:code], :redirect_uri => CALLBACK_URL)
  puts "new_url: #{new_url}"
  puts "session: #{session}"
  redirect new_url
end

get "/oauth/callback" do
  puts "OAUTH CALLBACK"
  puts "request.url: #{request.url}"
  puts "request.body: #{request.body.read}"
  result = Pocket.get_result(session[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = result['access_token']
  puts result['access_token']
  puts result['username']	
  # Alternative method to get the access token directly
  #session[:access_token] = Pocket.get_access_token(session[:code])
  puts session[:access_token]
  puts "session: #{session}"
  redirect "/"
end

get '/add' do
  client = Pocket.client(:access_token => session[:access_token])
  info = client.add :url => 'http://getpocket.com'
  "<pre>#{info}</pre>"
end

get "/retrieve" do
  client = Pocket.client(:access_token => session[:access_token])
  info = client.retrieve(:state => :unread, :detailType => :complete, :count => 3, :sort => :newest)
  @list = info["list"].map{|item|
    item[1]
  }.select{|item|
    item if !item["given_url"].nil? && !item["given_url"].empty?
  }.map{|item|
    plain_text = get_plain_text_at_site item["given_url"]
    item["sentences"] = get_summary_sentences plain_text
    item
  }
  erb :"retrieve"
end

def get_plain_text_at_site(url)
  
  page = URI.parse("http://scraping:8080?url=" + ERB::Util.url_encode(url)).read
  # charset = page.charset
  # if charset == "iso-8859-1"
  #   charset = page.scan(/charset="?([^\s"]*)/i).first.join
  # end

  # html = open(url, "r:#{charset}").read

  HTMLStripper.strip(page)
end

def get_summary_sentences(plain_text)
  client = Faraday.new(:url => "http://summpy-api:8080")
  res = client.post "/summarize", { :text => plain_text, :sent_limit => 3 }
  body = JSON.parse res.body

  body["summary"].map{|sentence|
      sentence
  }
end
