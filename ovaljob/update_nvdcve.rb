require 'crack'
require 'mongo'
require '~/Playground/ovms-rails/app/controllers/event_class.rb'
include Mongo

def update_from_file(filename)
  # connection
  mongo_client = MongoClient.new("localhost", 27017)
  db = mongo_client.db("ovms_db")
  coll = db["nvdcve"]

  # read cve file
  parsed_json = Crack::XML.parse(File.open(filename).read);
  all_vuln = parsed_json['nvd']['entry']
  valid_vul_count = 0

  # extract items
  all_vuln.each do |item|
    # puts item
    title = item['vuln:cve_id']
    publish = item['vuln:published_datetime'].split('T')[0] if item['vuln:published_datetime']
    modify = item['vuln:last_modified_datetime'].split('T')[0] if item['vuln:last_modified_datetime']
    cvss = item['vuln:cvss']['cvss:base_metrics']['cvss:score'].to_f if item['vuln:cvss']

    puts "#{title},#{publish},#{modify},#{cvss}"
    # note = item['Notes']['Note']
    # desc = note[0]
    # create = note[1]
    # modify = note[2]
    # find item has created
    # id = coll.insert({"_id"=>title,"publish"=>publish,"modify"=>modify,"cvss"=>cvss,"item"=>item})
    id = coll.save({'_id'=>title, "publish"=>publish,"modify"=>modify,"cvss"=>cvss,"item"=>item})
    puts "#{id}"
    # if modify.to_s.strip!=""
    #   puts "#{id}=>{t'#{title}',c'#{create}',m'#{modify}'}"
    #   valid_vul_count+=1
    # end
    valid_vul_count+=1
  end

  # print vulnerability number
  puts valid_vul_count
  return valid_vul_count
end

# (2014..2014).each do |year|
#   `curl -o 'nvdcve/#{year}.xml' http://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-#{year}.xml`
#   update_from_file("nvdcve/#{year}.xml")
# end

if ARGV[0] == "1"
  year = "modified"
  `curl -o '#{File.dirname(__FILE__)}/nvdcve/#{year}.xml' http://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-#{year}.xml`
  count = update_from_file("#{File.dirname(__FILE__)}/nvdcve/#{year}.xml")
  e = EventClass.new("sync","漏洞同步","已添加/修订 #{count} 个漏洞，来自NVD")
  p e.time
elsif ARGV[0]=="2"
  year = "recent"
  `curl -o '#{File.dirname(__FILE__)}/nvdcve/#{year}.xml' http://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-#{year}.xml`
  count =  update_from_file("#{File.dirname(__FILE__)}/nvdcve/#{year}.xml")
end
