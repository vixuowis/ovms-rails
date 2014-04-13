require 'hpricot'

doc = Hpricot.XML(open("../../oval.mitre.org/oval.xml"))

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

	# puts "[#{index}] #{_class[0..2]} ##{_id.split(":")[-1]}, #{_title.text()[0..100]+"..."}"
	# _criteria = (entry/'criteria')
	# _criteria.each do |c|
	# 	puts c['operator']
	# end
	puts vul,""
	sleep(0.5)
	vulner_count+=1
end

puts "\e[32mDone on getting vulnerabilities!\e[0m"
puts "\e[32mVulnerabilities: #{vulner_count}\e[0m"
