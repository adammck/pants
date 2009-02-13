#!/usr/bin/env ruby
# vim: noet


require "rubygems"
require "open-uri"
require "simple-rss"
require "erb"


class Pants
	DATE_TAGS = [:pubDate, :published, :updated, :expirationDate, :modified]
	
	# parse one or two command-line
	# arguments, or quit with usage
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

	# fetch the feed over http, parse it,
	# and generate the output with erb. if
	# anything at all goes wrong, abort
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
	
	# returns the first date tag present in _item_,
	# in the priority of DATE_TAGS (since in our default
	# template, we're only (currently) using one of them)
	def the_date(item)
		DATE_TAGS.each do |tag|
			return item[tag] if\
				item.has_key?(tag)
		end
	end

	# whether or not something goes wrong, the output of this program will
	# probably be piped into a tmp file to be included in an HTML document;
	# so include some HTML in the error, to hide (or highligh) it with CSS
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
			<div class="date"><%= the_date(item) %></div>
			<div class="desc"><%= item.description %></div>
		</li><% end %>
	</ul>
</div>
EOT
