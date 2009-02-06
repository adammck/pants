#!/usr/bin/env ruby
# vim: noet


require "open-uri"
require "rss"
require "erb"


class Pants
	def initialize(args, stdin)
		if args.length == 2
			@tmpl = File.get_contents(args[1])
			@feed = args[0]

		elsif args.length == 1
			@feed = args[0]
			@tmpl = TMPL

		else
			puts "Usage: pants.rb FEED [TEMPLATE]"
			exit 1
		end
	end

	def run
		puts begin
			@rss = open(@feed) { |s| s.read }
			@data = RSS::Parser.parse(@rss)
			ERB.new(@tmpl).result(binding)

		rescue OpenURI::HTTPError => err
			fail "Error fetching RSS feed"

		rescue RSS::NotWellFormedError
			fail "Malformed RSS feed"
		end
	end
	
	private
	
	def fail(text)
		"<div class='feed-error'>#{text}</div>"
	end
end


Pants::TMPL = <<EOT
<div class="feed">
	<h2><%= @data.channel.title %></h2>
	<ul><% @data.items.each do |item| %>
		<li>
			<h3><a href="<%= item.link %>"><%= item.title %></a></h3>
			<div class="date"><%= item.date %></div>
			<p><%= item.description %></p>
		</li><% end %>
	</ul>
</div>
EOT


Pants.new(ARGV, STDIN).run
