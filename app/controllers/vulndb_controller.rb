class VulndbController < ApplicationController
	def index
    # connection
		mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("ovms_db")
    coll = db["nvdcve"]
    @cve_count = coll.find.count

    # paging
    n_per_page = 5
    @this_page = 1
    if !params[:p].nil? and params[:p].to_i > 0 and params[:p].to_i <= (@cve_count*1.0/n_per_page).ceil
      n_skip = (params[:p].to_i - 1) * n_per_page
      @this_page = params[:p].to_i
    else 
      n_skip = 0
    end
    cursor = coll.find.skip(n_skip).limit(n_per_page)
    @first_page = 1
    @last_page = (@cve_count*1.0/n_per_page).ceil
    if @last_page > 5
      if @this_page < 4
        @paging_list =[1,2,3,4,5]
      elsif @this_page > @last_page -3
        t = @last_page
        @paging_list = [t-4,t-3,t-2,t-1,t]
      else
        t = @this_page
        @paging_list = [t-2,t-1,t,t+1,t+2]
      end
    else
      @paging_list = []
      (1..@last_page).each do |tp|
        @paging_list.append(tp)
      end
    end
    # get list
    @vuln_list = []
    cursor.each do |item|
      cwe_id = item['item']['vuln:cwe']['id'] rescue ""
      cwe_number = cwe_id.split('-')[1] rescue ""
      @vuln_list.append([
        item['_id'],
        cwe_id,
        item['cvss'],
        item['item']['vuln:summary'],
        item['publish'],
        item['modify'],
        "http://cve.scap.org.cn/#{item['_id']}.html",
        "http://wiki.scap.org.cn/cwe/cn/definition/#{cwe_number}"
        ])
    end
	end
end
