require 'crack'
require 'mongo'
require '~/Playground/ovms-rails/app/controllers/event_class.rb'
include Mongo

def update_from_file(filename)
  # connection
  mongo_client = MongoClient.new("localhost", 27017)
  db = mongo_client.db("ovms_db")
  coll = db["oval"]

  # read oval file
  parsed_json = Crack::XML.parse(File.open(filename).read);
  all_def = parsed_json['oval_definitions']['definitions']['definition']
  def_count = 0

  # extract items
  all_def.each do |item|
    begin
    	id = item['metadata']['reference']['ref_id']
    	id = coll.save({'_id'=>id, "item"=>item})
    rescue
      next
    end
    puts "#{id}"
    def_count +=1
  end

  # print vulnerability number
  puts def_count
  return def_count
end

# `curl -o '#{File.dirname(__FILE__)}/oval/#{year}.xml' http://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-#{year}.xml`

if ARGV[0] == "1"
  filename = "#{File.dirname(__FILE__)}/oval/oval-new.xml"
  url= "https://oval.mitre.org/repository/data/LatestDefinitionDownload?type=new&Range=DAY0_TO_7&Class=0"
  `curl -o '#{filename}' #{url}`
  count = update_from_file(filename)
  e = EventClass.new("sync","OVAL检测库同步","已添加 #{count} 个新OVAL检测条目，来自MITRE")
elsif ARGV[0]=="2"
  filename = "#{File.dirname(__FILE__)}/oval/oval-modify.xml"
  url= "https://oval.mitre.org/repository/data/LatestDefinitionDownload?type=modified&Range=DAY0_TO_7&Class=0"
  `curl -o '#{filename}' #{url}`
  count = update_from_file(filename)
  e = EventClass.new("sync","OVAL检测库同步","已修订 #{count} 个新OVAL检测条目，来自MITRE")
end