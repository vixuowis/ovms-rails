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
  	# Date.today
  	(-29..0).each do |minus|
  		date_item = Date.today + minus
  		date_list.append(date_item.to_s)
  		@simple_date_list.append(date_item.month.to_s+"."+date_item.day.to_s)
  	end

    vuln_all_count = coll.find().count

    # 判断是否重新计算
    if cookies[:trends].nil? or vuln_all_count!=cookies[:vuln_count].to_i or cookies[:cal_date]!=Time.now().day.to_s
      cookies[:vuln_count] = vuln_all_count

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
      cookies[:trends] = data.to_json

      # 4个统计盘数据
      data_panel = [
        layer1.sum,
        layer2.sum,
        layer3.sum,
        layer4.sum
      ]

      @panel_data = data_panel
      cookies[:panel_data] = @panel_data.to_json
      cookies[:cal_date] = Time.now().day.to_s
      e = EventClass.new("sys","系统启动","完成本日漏洞趋势计算，请查看首页。")
    else
      @trends_data = JSON.parse(cookies[:trends]).to_s
      @panel_data = JSON.parse(cookies[:panel_data])
    end

    coll_oval = db['oval']
    @unix_count = coll_oval.find({'item.metadata.affected.family'=>'unix'}).count
    @windows_count = coll_oval.find({'item.metadata.affected.family'=>'windows'}).count
    @apple_count = coll_oval.find({'item.metadata.affected.family'=>'macos'}).count
    @cisco_count = coll_oval.find({'item.metadata.affected.family'=>'pixos'}).count
    @ios_count = coll_oval.find({'item.metadata.affected.family'=>'ios'}).count
    total_count = @unix_count + @windows_count + @apple_count + @cisco_count + @ios_count
    
    @unix_rate = (@unix_count *1.0 / total_count)*100
    @windows_rate = (@windows_count *1.0 / total_count)*100
    @apple_rate = (@apple_count *1.0 / total_count)*100
    @cisco_rate = (@cisco_count *1.0 / total_count)*100
    @ios_rate = (@ios_count *1.0 / total_count)*100
    # @other_rate = 100 - @unix_rate - @windows_rate - @apple_rate - @cisco_rate - @ios_rate
  
    @platform_list = []
    rs = coll_oval.aggregate([{'$group'=>{_id:"$item.metadata.affected.platform",num_family:{'$sum'=>1}}},{'$sort'=>{'num_family'=>-1}}])   
    platform_dict = {}
    rs.each_with_index do |item,index|
      next if item['_id'].nil?
      if item['_id'].is_a?(String)
        if platform_dict.has_key?(item['_id'])
          platform_dict[item['_id']] += item['num_family'].to_i
        else 
          platform_dict[item['_id']] = item['num_family'].to_i
        end
        # @platform_list.append([item['_id'],item['num_family'].to_i])
      else
        item['_id'].each do |each_platform|
          if platform_dict.has_key?(each_platform)
            platform_dict[each_platform] += item['num_family'].to_i
          else 
            platform_dict[each_platform] = item['num_family'].to_i
          end
        end
        # @platform_list.append([item['_id'].join(", "),item['num_family'].to_i])
      end
    end
    @platform_list = Hash[platform_dict.sort_by{|k, v| v}.reverse].first(20)
    # @platform_list.append([platform_dict.to_json,1])
  
  end

end
