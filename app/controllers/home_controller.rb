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
	layer2 = []
	layer3 = []
	layer4 = []
	date_list.each_with_index do |date_item,index|
		vuln_null_count = coll.find('$and'=>[{'cvss'=>nil},{'modifify'=>date_item}]).count()
		layer1.append(vuln_null_count)
		# vuln_low_count = coll.find("this.cvss>=0 && this.cvss<=3.9").count()
		layer2.append(1)
		# vuln_mid_count = coll.find("this.cvss>=4.0 && this.cvss<=6.9").count()
		layer3.append(1)
		# vuln_high_count = coll.find("this.cvss>=7.0 && this.cvss<=10.0").count()
		layer4.append(1)
	end

	# result = coll.find({"item.Notes.Note"=>"2014-04-25"}).count()

  	data = [
  		layer1,
  		layer2,
  		layer3,
  		layer4
  	]
  	
  	@trends_data = data.to_s
  end
end
