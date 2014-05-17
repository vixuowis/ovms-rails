require 'Date'

class CalendarController < ApplicationController
  def index
    # connection
    mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("ovms_db")
    coll = db["nvdcve"]
    @high_cvss_list = []
    now = Date.today
    startDate = Date.new(now.year, now.month, 1).to_s
    cursor = coll.find({'cvss'=>{'$gte'=>7.0,'$lte'=>10.0}, 'publish'=>{'$gte'=>startDate}}).sort({'publish'=>-1})
    cursor.each do |item|
      @high_cvss_list.append({
        date: Date.parse(item['publish']).day,
        month: "#{Date.parse(item['publish']).month}月",
        id: item['_id'],
        url: "http://cve.scap.org.cn/#{item['_id']}.html",
        summary: item['item']['vuln:summary'],
        cvss: item['cvss']
      })
    end
  end

  def getcalendar
    # connection
    mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("ovms_db")
    coll = db["nvdcve"]
    startDate = Time.at(params['start'].to_i).strftime("%F")
    endDate = Time.at(params['end'].to_i).strftime("%F")
    cursor = coll.find({'publish'=>{'$gte'=>startDate,'$lte'=>endDate}})
    @data = []
    cursor.each do |item|
      if item['cvss'].nil?
        color = "#999"
      else
        if item['cvss'].to_f>=7.0
          color = "rgb(204, 0, 0)"
        elsif item['cvss'].to_f>=4.0
          color = "rgb(234, 73, 74)"
        elsif item['cvss'].to_f>=0
          color = "rgb(245, 121, 67)"
        end
      end
      @data.append({
        color: color,
        title: item['_id'],
        start: item['publish'],
        url: "http://cve.scap.org.cn/#{item['_id']}.html"
      })
    end

    respond_to do |format|
      format.json{render :json=>@data}
    end
  end
end
