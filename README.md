ovms-rails
===========

`OVMS` is my master graduation project. the full name is OVAL-based vulnerabilities management system. Now it's closed.

###Software requirements
	
	ruby 2.1.1
	rails 4.0.3
	MongoDB 2.4.9

###Getting Started
	
####Rails
`bundle install`

`rails s`

or

`rvmsudo rails s -p 1234`

####Database
`mongo`

`use ovms_db`

update cve or oval entries, at /ovaljob:

`ruby update_nvdcve.rb`

and 

`ruby oval_to_mongo.rb`

####Learning
We use naive bayes to classify new vulnerability's CVSS.

Training and testing are in one file, at /ovaljob/exp3_0612:

`python bayes.py`

Then, you can see new vulnerabilities already have a CVSS value in predict page.
