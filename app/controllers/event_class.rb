class EventClass

  attr_accessor :name, :time, :desc, :type, :status, :infotype

  def initialize(infotype,name,desc)
    if infotype == "sync"
      @type = "stream-info"
      @status = "icon-warning-sign"
      @infotype = infotype
    end
    @type = type
    @status = status
    @name = name
    n = Time.now
    @time = "#{n.year}年#{n.month}月#{n.day}日 #{Time.now().strftime("%I:%M%p")}"
    @desc = desc
    mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("ovms_db")
    coll = db["events"]
    coll.insert({'infotype'=>@infotype, 'type'=>@type, 'status'=>@status, 'name'=>@name,'time'=>@time,'desc'=>@desc, 'read'=>0})
  end
end