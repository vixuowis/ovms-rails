require 'mongo'
require 'date'
include Mongo

class HomeController < ApplicationController
  def index
  	# 首页趋势图数据
  	get_trends_data
  end

  def get_trends_data
	mongo_client = MongoClient.new("localhost", 27017)
	db = mongo_client.db("ovms_db")
	coll = db["nvdcve"]
	
	# 获取日期列表
	date_list = []
	@simple_date_list = []
	Date.today
	(-29..0).each do |minus|
		date_item = Date.today + minus
		date_list.append(date_item.to_s)
		@simple_date_list.append(date_item.month.to_s+"."+date_item.day.to_s)
	end 

	# 构造数据
	layer1 = [] # 新漏洞
	date_list.each_with_index do |date_item,index|
		vuln_thisday_count = coll.find({"item.Notes.Note"=>date_item}).count()
		layer1.append(vuln_thisday_count)
	end

	# result = coll.find({"item.Notes.Note"=>"2014-04-25"}).count()

  	data = [
  		layer1,
  		[],
  		[],
  		[]
  	]
  	
  	@trends_data = data.to_s
  end
end
