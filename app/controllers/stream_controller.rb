class StreamController < ApplicationController
  def index

    mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("ovms_db")
    coll = db["events"]

    # 设置已读
    coll.update({},{'$set'=>{:read=>1}},{:multi=>true})

    # 同步信息
    sync_info_num = coll.find({'infotype'=>'sync'}).count
    predict_info_num = coll.find({'infotype'=>'predict'}).count
    sys_info_num = coll.find({'infotype'=>'sys'}).count

    @events_list = []
    
    if params['predict'].nil? or params['predict']=="1"
      is_predict = true
      get_events_list('predict')
    else
      is_predict = false
    end

    if params['sync'].nil? or params['sync']=="1"
      is_sync = true
      get_events_list('sync')
    else
      is_sync = false
    end

    if params['sys'].nil? or params['sys']=="1"
      is_sys = true
      get_events_list('sys')
    else
      is_sys = false
    end

    @events_list = @events_list.sort{|a,b| a[:id].to_s <=> b[:id].to_s}.reverse

    @filter_list = [
      [predict_info_num,is_predict], #态势评估
      [sync_info_num,is_sync], #漏洞同步
      [sys_info_num,is_sys], #系统

      [12,true], #严重
      [4,true], #中等
      [21,true], #轻微

      [sync_info_num,true], #同步信息
      [2,true] #高危漏洞
    ]
    
    # @events_list = [
    #   {:type=>"stream-danger", :status=>"icon-warning-sign", :name=>"态势评估", :time=>"2014 五月 20", :desc=>"CVE-2014-3790的CVSS值可能为“高危”。
    #         漏洞描述：Ruby vSphere Console (RVC) in VMware vCenter Server Appliance allows remote authenticated users to execute arbitrary commands as root by escaping from a chroot jail."},
    #   {:type=>"stream-success", :status=>"icon-off", :name=>"系统", :time=>"2014 五月 24", :desc=>"Server is up."},
    #   {:type=>"stream-info", :status=>"icon-warning-sign", :name=>"漏洞同步", :time=>"2014 五月 02", :desc=>"上月高危漏洞平台：Windows（234），Red Hat（53）"},
    #   {:type=>"stream-danger", :status=>"icon-warning-sign", :name=>"态势评估", :time=>"2014 五月 01", :desc=>"CVE-2014-0075的CVSS值可能为“高危”。
    #         漏洞描述：Integer overflow in the parseChunkHeader function in java/org/apache/coyote/http11/filters/ChunkedInputFilter.java in Apache Tomcat before 6.0.40, 7.x before 7.0.53, and 8.x before 8.0.4 allows remote attackers to cause a denial of service (resource consumption) via a malformed chunk size in chunked transfer coding of a request during the streaming of data."},
    #   {:type=>"stream-danger", :status=>"icon-warning-sign", :name=>"态势评估", :time=>"2014 四月 30", :desc=>"CVE-2014-3793的CVSS值可能为“高危”。
    #         漏洞描述：VMware Tools in VMware Workstation 10.x before 10.0.2, VMware Player 6.x before 6.0.2, VMware Fusion 6.x before 6.0.3, and VMware ESXi 5.0 through 5.5, when a Windows 8.1 guest OS is used, allows guest OS users to gain guest OS privileges or cause a denial of service (kernel NULL pointer dereference and guest OS crash) via unspecified vectors."},
    # ]
  end
end

def get_events_list(type)
  mongo_client = MongoClient.new("localhost", 27017)
  db = mongo_client.db("ovms_db")
  coll = db["events"]
  cursor = coll.find({'infotype'=>type}).sort({'_id'=>-1})

  cursor.each do |item|
    @events_list.append({
      :id=>item['_id'],
      :type=>item['type'],
      :status=>item['status'],
      :name=>item['name'],
      :desc=>item['desc'],
      :time=>item['time']
      })
  end
end