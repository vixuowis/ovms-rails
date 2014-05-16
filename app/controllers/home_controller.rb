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
  		vuln_null_count = coll.find({'cvss'=>nil, 'publish'=>date_item}).count()
  		layer1.append(vuln_null_count)
  		vuln_low_count = coll.find({'cvss'=>{'$gte'=>0,'$lte'=>3.9}, 'modify'=>date_item}).count()
  		layer2.append(vuln_low_count)
  		vuln_mid_count = coll.find({'cvss'=>{'$gte'=>4.0,'$lte'=>6.9}, 'modify'=>date_item}).count()
  		layer3.append(vuln_mid_count)
  		vuln_high_count = coll.find({'cvss'=>{'$gte'=>7.0,'$lte'=>10.0}, 'modify'=>date_item}).count()
  		layer4.append(vuln_high_count)
  	end

  	data = [
  		layer1,
  		layer2,
  		layer3,
  		layer4
  	]

  	@trends_data = data.to_s

    # 4个统计盘数据
    data_panel = [
      layer1.sum,
      layer2.sum,
      layer3.sum,
      layer4.sum
    ]

    @panel_data = data_panel

  end

end
