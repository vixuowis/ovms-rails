class PredictController < ApplicationController
  def index
    # puts `ruby ~/Playground/ovms-rails/ovaljob/update_nvdcve.rb`
    # File.open(File.dirname(__FILE__)+"/out.txt", 'w') {|f| f.write("write your stuff here") }
    mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("ovms_db")
    coll = db["nvdcve"]
    cursor = coll.find({'cvss'=>nil,'publish'=>{'$gte'=>"2014-01-01"}}).sort({'publish'=>-1})
    @vuln_list = []
    cursor.each do |item|
      cwe_id = item['item']['vuln:cwe']['id'] rescue ""
      cwe_number = cwe_id.split('-')[1] rescue ""
      @vuln_list.append([
        item['_id'],
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