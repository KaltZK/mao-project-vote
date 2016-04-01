#!/usr/bin/env ruby
#encoding=utf-8
require 'sinatra'
require 'yaml'
require 'json'
require 'erb'
require 'time'
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
    res["time"]=DateTime.now
    db[:vote].insert_one res
    "Succeed"
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
get "/correlation" do
    @qdata=YAML.load_file("questions")
    erb :correlation
end
get "/correlation_data" do
    qdata=YAML.load_file("questions")
    get_ques_opt=lambda do |qn|
        params[qn]=="无" ? Array.new :
        qdata.detect{|x| x["ques"]==params[qn]}["options"]
    end
    get_ques_data= lambda do |qn|
        {
            "ques"=> qn=="无" ? "" : params[qn],
            "options"=>get_ques_opt.call(qn),
        }
    end
                q1s=get_ques_opt.call("q1")
                q2s=get_ques_opt.call("q2")
    JSON.dump({
        "axis"=>get_ques_data.call("axis"),
        "q1"=>get_ques_data.call("q1"),
        "q2"=>get_ques_data.call("q2"),
        "data"=>["总计"].concat(get_ques_opt.call "axis").map{|o|
                q1s=get_ques_opt.call("q1")
                q2s=get_ques_opt.call("q2")
                {
                    "name"=>o,
                    "data"=>q1s.zip(0...q1s.length).map{|q1o,q1i|
                        q2s.zip(0...q2s.length).map{|q2o,q2i|
                            {
                                :q1o=>q1o,
                                :q1i=>q1i,
                                :q2o=>q2o,
                                :q2i=>q2i,
                            }
                        }
                    }.flatten.map{|q|
                        dbs={
                            params["q1"]=>q[:q1o],
                            params["q2"]=>q[:q2o]
                        }
                        dbs[params["axis"]]=o unless o=="总计"
                        [q[:q1i],q[:q2i],db[:vote].find(dbs).count]
                    }.sort_by{|n| n[2]}
                }
            },
        })
end
