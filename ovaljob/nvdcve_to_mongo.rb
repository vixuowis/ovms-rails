require 'crack'
require 'mongo'
include Mongo

# connection
mongo_client = MongoClient.new("localhost", 27017)
db = mongo_client.db("ovms_db")
coll = db["nvdcve"]

# read cve file
parsed_json = Crack::XML.parse(File.open('nvdcve/2014.xml').read);
all_vuln = parsed_json['cvrfdoc']['Vulnerability']
valid_vul_count = 0

# extract items
all_vuln.each do |item|
  title = item['Title']
  note = item['Notes']['Note']
  desc = note[0]
  create = note[1]
  modify = note[2]
  # find item has created
  id = coll.insert({"_id"=>title,"item"=>item})
  if modify.to_s.strip!=""
    puts "#{id}=>{t'#{title}',c'#{create}',m'#{modify}'}"
    valid_vul_count+=1
  end
end

# print vulnerability number
puts valid_vul_count