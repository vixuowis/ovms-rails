class VulndbController < ApplicationController
	def index
    # connection
		mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("ovms_db")
    coll = db["nvdcve"]
    @cve_count = coll.find.count

    # paging
    n_per_page = 10
    @this_page = 1
    if !params[:p].nil? and params[:p].to_i > 0 and params[:p].to_i <= (@cve_count*1.0/n_per_page).ceil
      n_skip = (params[:p].to_i - 1) * n_per_page
      @this_page = params[:p].to_i
    else 
      n_skip = 0
    end

    sort_by = 'publish'
    direct = -1
    if params[:sort]=='publishup'
      sort_by = 'publish'
      direct = 1
    elsif params[:sort]=='publishdown'
      sort_by = 'publish'
      direct = -1
    elsif params[:sort]=='modifyup'
      sort_by = 'modify'
      direct = 1
    elsif params[:sort]=='modifydown'
      sort_by = 'modify'
      direct = -1
    elsif params[:sort]=='cvssup'
      sort_by = 'cvss'
      direct = 1
    elsif params[:sort]=='cvssdown'
      sort_by = 'cvss'
      direct = -1
    elsif params[:sort]=='cweup'
      sort_by = 'item.vuln:cwe.id'
      direct = 1
    elsif params[:sort]=='cwedown'
      sort_by = 'item.vuln:cwe.id'
      direct = -1
    elsif params[:sort]=='cveup'
      sort_by = '_id'
      direct = 1
    elsif params[:sort]=='cvedown'
      sort_by = '_id'
      direct = -1
    end

    cursor = coll.find.sort({sort_by=>direct}).skip(n_skip).limit(n_per_page)
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

  def sync_vuln
    begin
      if params[:step] == "1"
        rs= `cd ~/Playground/ovms-rails/ovaljob/ && ruby update_nvdcve.rb 1`
        puts rs
      elsif params[:step] == "2"
        rs= `cd ~/Playground/ovms-rails/ovaljob/ && ruby update_nvdcve.rb 2`
        puts rs
      end
      respond_to do |format|
        format.json{render :json=>{"success"=>true}}
      end
    rescue
      respond_to do |format|
        format.json{render :json=>{"success"=>false}}
      end
    end
  end
end
