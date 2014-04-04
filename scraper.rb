require 'scraperwiki'
require 'mechanize'

#
# # Find somehing on the page using css selectors
# p page.at('div.content')
#
# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})
#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries. You can use whatever gems are installed
# on Morph for Ruby (https://github.com/openaustralia/morph-docker-ruby/blob/master/Gemfile) and all that matters
# is that your final data is written to an Sqlite database called data.sqlite in the current working directory which
# has at least a table called data.

base_url = "http://203.38.125.77/T1PRWeb/eProperty/P1/eTrack"
url = "#{base_url}/eTrackApplicationSearchResults.aspx?Field=S&Period=L14&r=WW.P1.WEBGUEST&f=%24P1.ETR.SEARCH.SL14"

agent = Mechanize.new

# Read in a page
page = agent.get(url)

page.at("table.grid").search("tr.normalRow, tr.alternateRow").each do |tr|
  tds = tr.search("td")
  day, month, year = tds[1].inner_text.split("/").map{|s| s.to_i}
  record = {
    "council_reference" => tds[0].inner_text,
    "date_received" => Date.new(year, month, day).to_s,
    "description" => tds[2].inner_text,
    "address" => tds[5].inner_text,
    "date_scraped" => Date.today.to_s
  }
  record["info_url"] = "#{base_url}/eTrackApplicationDetails.aspx?r=WW.P1.WEBGUEST&f=$P1.ETR.APPDET.VIW&ApplicationId=" + CGI.escape(record["council_reference"])
  record["comment_url"] = "mailto:council@wagga.nsw.gov.au"
  p record
end
