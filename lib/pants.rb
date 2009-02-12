#!/usr/bin/env ruby
# vim: noet


require "rubygems"
require "open-uri"
require "simple-rss"
require "erb"


class Pants
	def initialize(args, stdin)
		if args.length == 2
			@tmpl = IO.read(args[1])
			@uri = args[0]

		elsif args.length == 1
			@uri = args[0]
			@tmpl = TMPL

		else
			puts "Usage: pants.rb FEED [TEMPLATE]"
			exit 1
		end
	end

	def run
		puts begin
			@xml = open(@uri){ |s| s.read }
			@data = SimpleRSS.parse(@xml)
			ERB.new(@tmpl).result(binding)

		rescue OpenURI::HTTPError => err
			fail "fetching", err

		rescue SimpleRSSError => err
			fail "parsing", err
		end
	end

	private

	def fail(doing, text)
		"<div class='feed-error'>Error while #{doing} feed: <span>#{text}</span></div>"
	end
end


Pants::TMPL = <<EOT
<div class="feed">
	<h2><%= @data.channel.title %></h2>
	<ul><% @data.items.each do |item| %>
		<li>
			<h3><a href="<%= item.link %>"><%= item.title %></a></h3>
			<div class="date"><%= item.date %></div>
			<div class="desc"><%= item.description %></div>
		</li><% end %>
	</ul>
</div>
EOT
