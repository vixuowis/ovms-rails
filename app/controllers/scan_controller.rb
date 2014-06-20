# require 'open-uri'
require 'socket'
require 'timeout'
class ScanController < ApplicationController
  def index
    mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("ovms_db")
    coll = db["client"]
    @client_list = coll.find()
    
    @current_report = "1"
    if !params[:c].nil?
      @current_report = params[:c]
    end

    @current_item = coll.find({"_id"=>@current_report}).first
    if @current_item.nil?
      @current_item = coll.find.first
      @current_report = @current_item['_id']
    end
    
    # begin
    #   res = open("http://#{@current_item['address']}:3000/")
    #   @status = "success"
    # rescue
    #   @status = "failed"
    # end

    begin 
       Timeout.timeout(1) do
          begin
            TCPSocket.new("#{@current_item['address']}", 3000)
            @status = "success"
          rescue Errno::ENETUNREACH
             retry # or do something on network timeout
          end
       end
    rescue Timeout::Error
       puts "timed out"
       @status = "failed"
       # do something on timeout
    end

    coll_rep = db['report']
    @report_list = coll_rep.find().sort("id"=>-1)
  end

  def scan_client
    begin
      mongo_client = MongoClient.new("localhost", 27017)
      db = mongo_client.db("ovms_db")
      coll = db["report"]
      if params[:status] == "start"
        address = params[:address]
        maxitem = coll.find().sort("id"=>-1).first
        if !maxitem.nil?
          id = maxitem['id'].to_i+1
        else
          id = 1
        end
        coll.save({"id"=>id,"oval"=>params[:oval],"start"=>Time.now().to_s,"status"=>"正在检测","address"=>address})
        e = EventClass.new("scan","漏洞扫描","#{params[:address]}开始漏洞扫描，OVAL定义集为#{params[:oval]}。")
      else params[:status] == "stop"
        coll.update({"id"=>params[:id].to_i},{"$set"=>{"stop"=>Time.now().to_s,"status"=>"检测结束"}})
        e = EventClass.new("scan","漏洞扫描","#{params[:address]}结束漏洞扫描，请在漏洞扫描页面查看。")
      end
      respond_to do |format|
        # format.html do
        #   redirect_to '/scan'
        # end
        format.json{render :json=>{"success"=>true,"id"=>id}}
      end
    rescue
      respond_to do |format|
        # format.html do
        #   redirect_to '/scan'
        # end
        format.json{render :json=>{"success"=>false}}
      end
    end
  end

  def add_client
    begin
      mongo_client = MongoClient.new("localhost", 27017)
      db = mongo_client.db("ovms_db")
      coll = db["client"]
      maxitem = coll.find().sort("_id"=>-1).first
      if !maxitem.nil?
        id = maxitem['_id'].to_i+1
      else
        id = 1
      end
      coll.save({"_id"=>id.to_s,"name"=>params[:name],"address"=>params[:address]})
      respond_to do |format|
        format.json{render :json=>{"success"=>true}}
      end
    rescue
      respond_to do |format|
        format.json{render :json=>{"success"=>false}}
      end
    end
  end

  def edit_client
    begin
      mongo_client = MongoClient.new("localhost", 27017)
      db = mongo_client.db("ovms_db")
      coll = db["client"]
      coll.update({"_id"=>params[:id].to_s},{"name"=>params[:name],"address"=>params[:address]})
      respond_to do |format|
        format.json{render :json=>{"success"=>true}}
      end
    rescue
      respond_to do |format|
        format.json{render :json=>{"success"=>false}}
      end
    end
  end

  def delete_client
    begin
      mongo_client = MongoClient.new("localhost", 27017)
      db = mongo_client.db("ovms_db")
      coll = db["client"]
      coll.remove({"_id"=>params[:id].to_s})
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
