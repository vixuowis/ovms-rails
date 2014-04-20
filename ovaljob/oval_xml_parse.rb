require 'hpricot'

doc = Hpricot.XML(open("oval/oval.xml"))

defs = (doc/'oval_definitions definitions definition')

puts "\e[32mDefinitions: #{defs.length}\e[0m"

vulner_count = 0

defs.each_with_index do |entry,index|
	vul = {}
	vul[:id] = _id = entry['id']
	vul[:version] = _version = entry['version']
	vul[:class] = _class = entry['class']
	next if _class != "vulnerability"

	_metadata = (entry/'metadata')
	vul[:title] = _title = (_metadata/'title').text()
	
	_affected = []
	(_metadata/'affected').each do |a|
		affect_entry = {}
		affect_entry[a['family'].to_s] = []
		(a/'platform').each do |p|
			affect_entry[a['family']] << p.inner_html
		end
		_affected << affect_entry
	end
	vul[:affected] = _affected
	
	_reference = []
	(entry/'metadata reference').each do |r|
		reference_entry = {}
		reference_entry['source'] = r['source']
		reference_entry['ref_id'] = r['ref_id']
		reference_entry['ref_url'] = r['ref_url']
		_reference << reference_entry
	end
	vul[:reference] = _reference

	vul[:description] = (_metadata/'description').text()

	(entry/'oval_repository/dates/status_change').each do |d|
		if d.inner_html == "ACCEPTED"
			vul[:date_accpeted] = d['date']
		end
	end

	(entry/'oval_repository/dates/submitted').each do |d|
		vul[:date_submitted] = d['date']
	end

	vul[:status] = (entry/'oval_repository status')[0].inner_html

	_criteria = (entry/'criteria')
	_criteria.each do |c|
		vul[:criteria] = c
	end
	puts vul,""
	# sleep(0.5)
	vulner_count+=1
end

puts "\e[32mDone on getting vulnerabilities!\e[0m"
puts "\e[32mVulnerabilities: #{vulner_count}\e[0m"
