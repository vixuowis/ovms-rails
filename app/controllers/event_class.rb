class EventClass

  attr_accessor :name, :time, :desc, :type, :status

  def initialize(type,status,name,desc)
    @type = type
    @status = status
    @name = name
    n = Time.now
    @time = "#{n.year}年#{n.month}月#{n.day}日 #{n.hour}:#{n.min}:#{n.sec}"
    @desc = desc
    mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("ovms_db")
    coll = db["events"]
    coll.insert({'type'=>@type, 'status'=>@status, 'name'=>@name,'time'=>@time,'desc'=>@desc})
  end
end