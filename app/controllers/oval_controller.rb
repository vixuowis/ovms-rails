class OvalController < ApplicationController
    def index
    # connection
    mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("ovms_db")
    coll = db["oval"]
    @cve_count = coll.find({'_id'=>{'$exists'=>true}}).count

    # paging
    n_per_page = 10
    @this_page = 1
    if !params[:p].nil? and params[:p].to_i > 0 and params[:p].to_i <= (@cve_count*1.0/n_per_page).ceil
      n_skip = (params[:p].to_i - 1) * n_per_page
      @this_page = params[:p].to_i
    else 
      n_skip = 0
    end

    sort_by = 'item.metadata.oval_repository.dates.submitted.date'
    direct = -1
    if params[:sort]=='publishup'
      sort_by = 'item.metadata.oval_repository.dates.submitted.date'
      direct = 1
    elsif params[:sort]=='publishdown'
      sort_by = 'item.metadata.oval_repository.dates.submitted.date'
      direct = -1
    elsif params[:sort]=='modifyup'
      sort_by = 'item.metadata.oval_repository.dates.modified.date'
      direct = 1
    elsif params[:sort]=='modifydown'
      sort_by = 'item.metadata.oval_repository.dates.modified.date'
      direct = -1
    elsif params[:sort]=='classup'
      sort_by = 'item.class'
      direct = 1
    elsif params[:sort]=='classdown'
      sort_by = 'item.class'
      direct = -1
    elsif params[:sort]=='familyup'
      sort_by = 'item.metadata.affected.family'
      direct = 1
    elsif params[:sort]=='familydown'
      sort_by = 'item.metadata.affected.family'
      direct = -1
    elsif params[:sort]=='ovalup'
      sort_by = 'item.id'
      direct = 1
    elsif params[:sort]=='ovaldown'
      sort_by = 'item.id'
      direct = -1
    end

    # cursor = coll.find.sort({sort_by=>direct}).skip(n_skip).limit(n_per_page)
    cursor = coll.find({'_id'=>{'$exists'=>true}}).sort({sort_by=>direct}).skip(n_skip).limit(n_per_page)

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
      family = item['item']['metadata']['affected']['family'] rescue ""
      desc = item['item']['metadata']['description'] rescue ""
      modify = item['item']['metadata']['oval_repository']['dates']['modified']['date'].split("T")[0] rescue ""
      publish = item['item']['metadata']['oval_repository']['dates']['submitted']['date'].split("T")[0] rescue ""
      # cwe_id = item['item']['vuln:cwe']['id'] rescue ""
      # cwe_number = cwe_id.split('-')[1] rescue ""
      @vuln_list.append({
        :id => item['item']['id'],
        :class => item['item']['class'],
        :family => family,
        # cwe_id,
        # item['cvss'],
        :desc => desc,
        :modify => modify,
        :publish => publish,
        :oval_url => "http://oval.scap.org.cn/oval_org.mitre.oval_def_#{item['_id'].split(":")[-1]}.html",
        # "http://wiki.scap.org.cn/cwe/cn/definition/#{cwe_number}"
        # 
        })
    end
  end

  def sync_oval
    begin
      if params[:step] == "1"
        rs= `cd ~/Playground/ovms-rails/ovaljob/ && ruby oval_to_mongo.rb 1`
        puts rs
        respond_to do |format|
          format.json{render :json=>{"success"=>true}}
        end
      elsif params[:step] == "2"
        rs= `cd ~/Playground/ovms-rails/ovaljob/ && ruby oval_to_mongo.rb 2`
        puts rs
        respond_to do |format|
          format.json{render :json=>{"success"=>true}}
        end
      else
        respond_to do |format|
          format.json{render :json=>{"success"=>false}}
        end
      end
    rescue
      respond_to do |format|
        format.json{render :json=>{"success"=>false}}
      end
    end
  end
end
