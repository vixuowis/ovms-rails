class PredictController < ApplicationController
  def index
    # puts `ruby ~/Playground/ovms-rails/ovaljob/update_nvdcve.rb`
    # File.open(File.dirname(__FILE__)+"/out.txt", 'w') {|f| f.write("write your stuff here") }
    mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("ovms_db")
    coll = db["nvdcve"]
    # cursor = coll.find({'cvss'=>nil,'publish'=>{'$gte'=>"2014-01-01"}}).sort({'publish'=>-1})
    # cursor = coll.find({'cvss'=>nil,'item.vuln:summary'=>{'$not'=>/REJECT/}}).sort({'publish'=>-1})

    date_str = (Time.now()-29*24*3600).to_s.split(" ")[0]
    cursor = coll.find({'cvss'=>nil,'publish'=>{'$gte'=>date_str}}).sort({'publish'=>-1})

    @vuln_list = []
    cursor.each do |item|
      cwe_id = item['item']['vuln:cwe']['id'] rescue ""
      cwe_number = cwe_id.split('-')[1] rescue ""
      @vuln_list.append([
        item['_id'],
        item['predict_cvss'],
        item['item']['vuln:summary'],
        item['publish'],
        item['modify'],
        "http://cve.scap.org.cn/#{item['_id']}.html",
        "http://wiki.scap.org.cn/cwe/cn/definition/#{cwe_number}"
        ])
    end
  end

  def learning_caller
    begin
      rs= `cd ~/Playground/ovms-rails/ovaljob/learning/exp3_0612 && python bayes.py`
      puts rs
      e = EventClass.new("predict","态势评估","完成本次态势评估，请在态势评估页面查看。")
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