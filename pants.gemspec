Gem::Specification.new do |s|
	s.name     = "pants"
	s.version  = "0.2"
	s.date     = "2009-02-18"
	s.summary  = "Command-line Ruby application to transform an RSS or Atom feed (or JSON document!) into a chunk of HTML via ERB"
	s.email    = "adam.mckaig@gmail.com"
	s.homepage = "http://github.com/adammck/pants"
	s.authors  = ["Adam Mckaig"]
	s.has_rdoc = true
	
	s.files = [
		"pants.gemspec",
		"lib/pants.rb",
		"bin/pants"
	]
	
	s.executables = [
		"pants"
	]
	
	s.add_dependency("simple-rss")
	s.add_dependency("json")
end
