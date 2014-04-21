require 'crack'
require 'mongo'
include Mongo

# connection
mongo_client = MongoClient.new("localhost", 27017)
db = mongo_client.db("ovms_db")
coll = db["oval"]

# read oval file
parsed_json = Crack::XML.parse(File.open('oval/oval.xml').read);
all_def = parsed_json['oval_definitions']['definitions']['definition']
def_count = 0

# extract items
all_def.each do |item|
  begin
  	id = item['metadata']['reference']['ref_id']
  	id = coll.insert({'_id'=>id,"item"=>item})
  rescue
  end
  puts "#{id}"
  def_count +=1
end

# print vulnerability number
puts def_count