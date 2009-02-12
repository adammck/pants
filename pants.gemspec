Gem::Specification.new do |s|
	s.name     = "pants"
	s.version  = "0.1"
	s.date     = "2009-02-12"
	s.summary  = "Command-line application to transform an RSS or Atom feed into a chunk of HTML via ERB"
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
end
