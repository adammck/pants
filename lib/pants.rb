#!/usr/bin/env ruby
# vim: noet


require "rubygems"
require "open-uri"
require "simple-rss"
require "json"
require "erb"


class Pants
	DATE_TAGS = [:pubDate, :published, :updated, :expirationDate, :modified]
	
	CONTENT_TYPES = {
		"application/json"     => :json,
		"application/rss+xml"  => :rss,
		"application/atom+xml" => :atom
	}
	
	# parse one or two command-line
	# arguments, or quit with usage
	def initialize(args, stdin)
		if args.length == 3
			@type = args[2]
			@tmpl = IO.read(args[1])
			@uri = args[0]
			
		elsif args.length == 2
			@tmpl = IO.read(args[1])
			@uri = args[0]

		elsif args.length == 1
			@uri = args[0]
			@tmpl = TMPL

		else
			puts "Usage: pants.rb FEED [TEMPLATE] [FORCE-TYPE]"
			puts ""
			puts "  FEED:        Remote URI of source data"
			puts "  TEMPLATE:    Local path of ERB template to build"
			puts "  FORCE-TYPE:  Content type to override mime type of fetched document"
			puts "               (Available types are: #{CONTENT_TYPES.values.join(", ")})"
			exit 1
		end
	end

	# fetch the feed over http, parse it,
	# and generate the output with erb. if
	# anything at all goes wrong, abort
	def run
		catch(:abort) do
			begin
				open(@uri) do |s|
					
					# if we're not forcing a particular parser type,
					# check that the actual content type is supported
					unless @type
						ct = s.content_type
						fail("unsupported content type", ct) unless\
							@type = CONTENT_TYPES[ct]
					end
					
					# get the raw data
					@src = s.read
				end
				
				# parse the document (with whichever parser type was
				# forced or fetched) and render the results with ERB
				@data = send(parser = "parse_#{@type}")
				puts ERB.new(@tmpl).result(binding)

			rescue OpenURI::HTTPError => err
				fail "fetching uri", err

			rescue SimpleRSSError => err
				fail "parsing rss", err
			
			rescue StandardError => err
				fail "rendering", err.message
			end
		end
	end
	
	private
	
	def parse_json
		JSON.parse(@src)
	end
	
	def parse_rss
		SimpleRSS.parse(@src)
	end
	
	def parse_atom
		SimpleRSS.parse(@src)
	end
	
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
	# so include some HTML in the error, to hide (or highlight) it with CSS
	def fail(doing, text)
		puts "<div class='feed-error'>Error while #{doing}: <span>#{text}</span></div>"
		throw(:abort)
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
