#!/usr/bin/env ruby
#encoding=utf-8
require 'sinatra'
require 'yaml'
require 'json'
require 'erb'
require 'mongo'

db=Mongo::Client.new ["127.0.0.1:27017"],:database=>"mao_vote"

set :public_folder, 'public'
get "/" do
    erb :vote
end
get "/questions" do
    JSON.dump YAML.load_file "questions"
end
get "/thank_you" do
    erb :thank_you
end
post "/submit_res" do
    res=params
    res["source"]="network"
    db[:vote].insert_one res
end
get "/analysis" do
    erb :analysis
end
get "/vote_analysis" do
    JSON.dump(YAML.load_file("questions").map do |q|
        {
            "ques"=>q["ques"],
            "options"=>q["options"].map do |o|
                {
                    "option"=>o,
                    "count"=>db[:vote].find( q["ques"] => o ).count,
                }
            end,
        }
    end)
end
