# encoding=utf-8
import codecs
from pymongo import MongoClient

def tokenizer(_id,text):
  special_chars = ["(",")",".",",","-","/",":","\"","!","$","+","*","#",";","%","@","^","&","*","_","=","~","`","<",">","?","'","[","]","{","}","|"]
  result_token = []
  for c in special_chars:
    text = text.replace(c," ")
  result_token = text.split(" ")
  # print _id,text
  # print result_token
  return result_token

def classify_by_cvss(tokens,hash_current):
  for word in tokens:
    if word!='' and len(word)>3:
      if hash_current.has_key(word):
        hash_current[word] += 1
      else:
        hash_current[word] = 1
  return hash_current

def save_hash_to(hash_current,to_path):
  f = codecs.open(to_path,'w','utf-8')
  for (k,v) in sorted(hash_current.iteritems(), key=lambda (k,v): (v,k)):
    f.write(k+","+str(v)+"\n")
    # print k,v
  f.close()

def training():
  client = MongoClient('localhost', 27017)
  db = client['ovms_db']
  coll = db['nvdcve']
  i=0;i1=0;i2=0;i3=0;i4=0
  hash1 = {}
  hash2 = {}
  hash3 = {}
  hash4 = {}
  for item in coll.find({'publish':{'$lte':'2014-01-01'}}):
    if item['cvss'] is not None:
      _id = item['_id']
      cvss = float(item['cvss'])
      print _id,cvss
      text = item['item']['vuln:summary']
      tokens = tokenizer(_id,text)
      # 将训练集中的cvss分布到不同hash中
      if cvss == 10.0:
        hash1 = classify_by_cvss(tokens,hash1)
        i1+=1
      elif cvss>=7.0:
        hash2 = classify_by_cvss(tokens,hash2)
        i2+=1
      elif cvss>=4.0:
        hash3 = classify_by_cvss(tokens,hash3)
        i3+=1
      elif cvss>=0.0:
        hash4 = classify_by_cvss(tokens,hash4)
        i4+=1
      # print hash1,hash2,hash3,hash4
      i+=1
    # if i==10000:
    #   break

  save_hash_to(hash1,"1_stat_hash.txt")
  save_hash_to(hash2,"2_stat_hash.txt")
  save_hash_to(hash3,"3_stat_hash.txt")
  save_hash_to(hash4,"4_stat_hash.txt")

  print "total:",i,i1,i2,i3,i4
  return i1,i2,i3,i4

def merge_class(file_array,output_file,datascale):
  output_hash = {}
  # 读取每个文件，合并到hash表中
  for index,each_file in enumerate(file_array):
    f = codecs.open(each_file,'r','utf-8')
    for line in f:
      parts = line.split(',')
      key = parts[0]
      value = int(parts[-1])
      if output_hash.has_key(key):
        output_hash[key][index] = value*1.0/datascale[index]
      else:
        output_hash[key] = []
        for i in range(len(file_array)):
          output_hash[key].append(0.01/datascale[index])
        output_hash[key][index] = value*1.0/datascale[index]
  # 输出
  f = codecs.open(output_file,'w','utf-8')
  total = len(output_hash)
  skip = 50
  current = 0
  for (k,v) in sorted(output_hash.iteritems(), key=lambda (k,v): (v,k)):
    f.write(k)
    for i in range(len(file_array)):
      f.write(","+str(v[i]))
    f.write("\n")
    current += 1
    if current == (total-skip):
      break
  f.close()

def test_4class(features_file):
  # 哈希统计表
  features = {}
  f = codecs.open(features_file,'r','utf-8')
  for line in f:
    parts = line.split(',')
    features[parts[0]] = []
    for i in range(1,len(parts)):
      features[parts[0]].append(float(parts[i]))
    # print parts[0],features[parts[0]]

  class_number = len(parts) - 1

  client = MongoClient('localhost', 27017)
  db = client['ovms_db']
  coll = db['nvdcve']
  results = coll.find({'publish':{'$gte':'2014-01-01'}})

  total = 0
  correct = 0
  f_1 = open("test_1.txt",'w')
  f_2 = open("test_2.txt",'w')
  f_3 = open("test_3.txt",'w')
  f_4 = open("test_4.txt",'w')

  for index,item in enumerate(results):
    if item['cvss'] is not None:
      _id = item['_id']
      cvss = float(item['cvss'])
      print _id,cvss
      text = item['item']['vuln:summary']
      tokens = tokenizer(_id,text)

      # 分词，得到该样本特征
      cutresult = tokenizer(_id,text)
      # 对不同类别计算该文本特征所对应的后验概率
      ## 初始化
      bayes_result = {}
      bayes_result[index] = []
      ## 对于每个词 计算freq 直接乘回去
      for i in range(class_number):
        freq = 1
        for word in cutresult:
          if features.has_key(word):
            freq = freq * features[word][i]
          # print i,word,freq
        bayes_result[index].append(freq)
        
      # print bayes_result[index]
      maxval = max(bayes_result[index])

      if bayes_result[index][0] == maxval:
        print "very high!"
        f_1.write(str(bayes_result[index][0])+" "+text+"\n")
        if float(cvss)==10.0:
          correct+=1
          print "correct!"
      elif bayes_result[index][1] == maxval:
        print "high!"
        f_2.write(str(bayes_result[index][1])+" "+text+"\n")
        if float(cvss)>=7.0:
          correct+=1
          print "correct!"
      elif bayes_result[index][2] == maxval:
        print "medium!"
        f_3.write(str(bayes_result[index][2])+" "+text+"\n")
        if float(cvss)>=4.0:
          correct+=1
          print "correct!"
      elif bayes_result[index][3] == maxval:
        print "low!"
        f_4.write(str(bayes_result[index][3])+" "+text+"\n")
        if float(cvss)>=0:
          correct+=1
          print "correct!"
      total+=1
      # if total==1000:
      #   break

  f_1.close()
  f_2.close()
  f_3.close()
  f_4.close()

  return correct,total

i1,i2,i3,i4 = training()
merge_class(["1_stat_hash.txt","2_stat_hash.txt","3_stat_hash.txt","4_stat_hash.txt"],"merge_features.txt",[i1,i2,i3,i4])
correct_all = 0
total_all = 0
for i in range(1):
  correct,total = test_4class("merge_features.txt")
  correct_all += correct
  total_all += total
print "correct=",correct_all,"total=",total_all,"correct_rate=",(correct_all*1.0/total_all)



