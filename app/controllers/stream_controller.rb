class StreamController < ApplicationController
  def index
    @filter_list = [
      [37,false], #态势评估
      [53,true], #漏洞同步
      [10,false], #系统

      [12,true], #严重
      [4,false], #中等
      [21,false], #轻微

      [51,true], #新高危漏洞
      [2,true] #上月频繁发生平台
    ]

    get_events_list()
    # @events_list = [
    #   {:type=>"stream-danger", :status=>"icon-warning-sign", :name=>"态势评估", :time=>"2014 五月 20", :desc=>"CVE-2014-3790的CVSS值可能为“高危”。
    #         漏洞描述：Ruby vSphere Console (RVC) in VMware vCenter Server Appliance allows remote authenticated users to execute arbitrary commands as root by escaping from a chroot jail."},
    #   {:type=>"stream-success", :status=>"icon-off", :name=>"系统", :time=>"2014 五月 24", :desc=>"Server is up."},
    #   {:type=>"stream-info", :status=>"icon-off", :name=>"漏洞同步", :time=>"2014 五月 02", :desc=>"上月高危漏洞平台：Windows（234），Red Hat（53）"},
    #   {:type=>"stream-danger", :status=>"icon-warning-sign", :name=>"态势评估", :time=>"2014 五月 01", :desc=>"CVE-2014-0075的CVSS值可能为“高危”。
    #         漏洞描述：Integer overflow in the parseChunkHeader function in java/org/apache/coyote/http11/filters/ChunkedInputFilter.java in Apache Tomcat before 6.0.40, 7.x before 7.0.53, and 8.x before 8.0.4 allows remote attackers to cause a denial of service (resource consumption) via a malformed chunk size in chunked transfer coding of a request during the streaming of data."},
    #   {:type=>"stream-danger", :status=>"icon-warning-sign", :name=>"态势评估", :time=>"2014 四月 30", :desc=>"CVE-2014-3793的CVSS值可能为“高危”。
    #         漏洞描述：VMware Tools in VMware Workstation 10.x before 10.0.2, VMware Player 6.x before 6.0.2, VMware Fusion 6.x before 6.0.3, and VMware ESXi 5.0 through 5.5, when a Windows 8.1 guest OS is used, allows guest OS users to gain guest OS privileges or cause a denial of service (kernel NULL pointer dereference and guest OS crash) via unspecified vectors."},
    # ]
  end
end

def get_events_list
  mongo_client = MongoClient.new("localhost", 27017)
  db = mongo_client.db("ovms_db")
  coll = db["events"]
  cursor = coll.find
  @events_list = []
  cursor.each do |item|
    @events_list.append({
      :type=>item['type'],
      :status=>item['status'],
      :name=>item['name'],
      :desc=>item['desc'],
      :time=>item['time']
      })
  end
end