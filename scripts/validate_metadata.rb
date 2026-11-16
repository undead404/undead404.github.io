# Run after `bundle exec jekyll build`:
# bundle exec ruby scripts/validate_metadata.rb [_site] [schemaorg-current-https.jsonld]
require 'json'
require 'nokogiri'
require 'pathname'
require 'uri'

def check(condition, message)
  raise message unless condition
end

root = Pathname.new(ARGV[0] || '_site')
origin = 'https://undead404.github.io'
pages = { 'uk' => '/', 'en' => '/en/' }
graphs = {}
pages.each do |lang, path|
  doc = Nokogiri::HTML(root.join("#{path.delete_prefix('/')}index.html").read)
  canonical = origin + path
  meta = lambda do |key|
    matches = doc.css("head meta[name='#{key}'], head meta[property='#{key}']")
    check(matches.length == 1, "#{lang}: missing/duplicate #{key}")
    matches.first['content']
  end
  check(doc.at_css('html')['lang'] == lang, "#{lang}: html language")
  check(doc.css('head link[rel=canonical]').map { |n| n['href'] } == [canonical], "#{lang}: canonical")
  (pages.merge('x-default' => '/')).each do |code, target|
    links = doc.css("head link[rel=alternate][hreflang='#{code}']")
    check(links.map { |n| n['href'] } == [origin + target], "#{lang}: hreflang #{code}")
  end
  title = doc.at_css('head > title').text
  check(meta.call('og:title') == title && meta.call('twitter:title') == title, "#{lang}: title mismatch")
  description = meta.call('description')
  check(meta.call('og:description') == description && meta.call('twitter:description') == description, "#{lang}: description mismatch")
  check(meta.call('og:url') == canonical, "#{lang}: og:url")
  check(meta.call('og:type') == 'website' && meta.call('twitter:card') == 'summary', "#{lang}: card type")
  check(meta.call('og:locale') == (lang == 'uk' ? 'uk_UA' : 'en_US'), "#{lang}: locale")
  check(meta.call('og:locale:alternate') == (lang == 'uk' ? 'en_US' : 'uk_UA'), "#{lang}: alternate locale")
  image = meta.call('og:image')
  check(image == meta.call('twitter:image') && URI(image).host == URI(origin).host, "#{lang}: image URL")
  check(root.join(URI(image).path.delete_prefix('/')).file?, "#{lang}: missing image")
  check(meta.call('og:image:alt') == meta.call('twitter:image:alt'), "#{lang}: image alt")
  check(!doc.css('meta[name=robots], meta[name=googlebot]').any? { |n| n['content'].match?(/noindex|nofollow|none/i) }, "#{lang}: robots restriction")
  scripts = doc.css('script[type="application/ld+json"]')
  check(scripts.length == 1, "#{lang}: structured data block count")
  data = JSON.parse(scripts.first.text)
  check(data['@context'] == 'https://schema.org', "#{lang}: JSON-LD context")
  nodes = data.fetch('@graph')
  check(nodes.map { |n| n['@type'] }.sort == %w[CreativeWork Person ProfilePage WebSite], "#{lang}: graph types")
  by_id = nodes.to_h { |n| [n.fetch('@id'), n] }
  check(by_id.size == nodes.size, "#{lang}: duplicate graph IDs")
  # Every graph reference must resolve locally, including the external project identity.
  walk = lambda do |value|
    case value
    when Hash
      check(by_id.key?(value['@id']), "#{lang}: dangling reference #{value['@id']}") if value.keys == ['@id']
      value.each_value { |v| walk.call(v) }
    when Array then value.each { |v| walk.call(v) }
    end
  end
  walk.call(nodes)
  person = by_id.fetch(origin + '/#person')
  website = by_id.fetch(origin + '/#website')
  profile = by_id.fetch(canonical + '#webpage')
  check(doc.at_css('body').text.include?(person['name']), "#{lang}: person absent from visible content")
  check(person['name'] == meta.call('author') && person['image'] == image, "#{lang}: person metadata")
  person.fetch('sameAs').each do |url|
    check(doc.css('body a[href]').any? { |a| a['href'] == url }, "#{lang}: unsupported identity link #{url}")
  end
  check(website['url'] == origin + '/' && website['inLanguage'].sort == pages.keys.sort, "#{lang}: website")
  check(profile['url'] == canonical && profile['inLanguage'] == lang && profile['name'] == title && profile['description'] == description, "#{lang}: profile metadata")
  check(profile.dig('mainEntity', '@id') == person['@id'] && profile.dig('isPartOf', '@id') == website['@id'], "#{lang}: profile relationships")
  work = nodes.find { |n| n['@type'] == 'CreativeWork' }
  check(doc.css('body a[href]').any? { |a| a['href'] == work['url'] }, "#{lang}: unlinked creative work")
  check(work.dig('creator', '@id') == person['@id'], "#{lang}: creator")
  # Verify local navigation anchors still resolve.
  doc.css('a[href^="#"]').each do |a|
    id = a['href'].delete_prefix('#')
    check(id.empty? || doc.at_css("[id='#{id}']"), "#{lang}: broken anchor #{id}")
  end
  graphs[lang] = nodes
end
check(graphs['uk'].map { |n| n['@id'] }.reject { |id| id.end_with?('#webpage') } == graphs['en'].map { |n| n['@id'] }.reject { |id| id.end_with?('#webpage') }, 'Shared identities differ between translations')

sitemap = Nokogiri::XML(root.join('sitemap.xml').read) { |config| config.strict }
locations = sitemap.xpath('//*[local-name()="loc"]').map(&:text)
check(locations.sort == pages.values.map { |path| origin + path }.sort, 'Sitemap must contain both canonical pages exactly once')
robots = root.join('robots.txt').read
check(robots.match?(/^User-agent: \*\s+Allow: \/\s/) && !robots.match?(/^Disallow:\s*\S/), 'Crawler access restricted')
check(robots.include?("Sitemap: #{origin}/sitemap.xml"), 'Missing root sitemap reference')
%w[AGENTS.md SEO-AUDIT.md scripts/validate_metadata.rb].each do |file|
  check(!root.join(file).exist?, "Internal file published: #{file}")
end

if ARGV[1]
  # Validate terms, inherited property domains, and value ranges against the
  # official Schema.org vocabulary. This is not a search-engine eligibility test.
  vocabulary = JSON.parse(File.read(ARGV[1])).fetch('@graph').to_h { |node| [node['@id'], node] }
  ids = lambda { |value| (value.is_a?(Array) ? value : [value]).compact.map { |v| v.fetch('@id') } }
  ancestors = lambda do |type|
    node = vocabulary.fetch(type)
    [type] + ids.call(node['rdfs:subClassOf']).flat_map { |parent| ancestors.call(parent) }
  end
  graphs.each_value do |nodes|
    by_id = nodes.to_h { |n| [n['@id'], n] }
    nodes.each do |node|
      lineage = ancestors.call("schema:#{node.fetch('@type')}")
      node.reject { |key, _| key.start_with?('@') }.each do |property, value|
        definition = vocabulary.fetch("schema:#{property}")
        domains = ids.call(definition['schema:domainIncludes'])
        check((domains & lineage).any?, "Invalid domain: #{node['@type']}.#{property}")
        ranges = ids.call(definition['schema:rangeIncludes'])
        (value.is_a?(Array) ? value : [value]).each do |item|
          types = if item.is_a?(Hash)
                    ancestors.call("schema:#{by_id.fetch(item.fetch('@id')).fetch('@type')}")
                  else
                    ['schema:Text'] + (item.match?(%r{\Ahttps://}) ? ['schema:URL'] : [])
                  end
          check((types & ranges).any?, "Invalid range: #{node['@type']}.#{property}")
        end
      end
    end
  end
  puts 'Schema.org vocabulary: types, properties, inherited domains and ranges passed.'
end
puts 'Both languages: JSON-LD graph, metadata, canonicals, hreflang, image, anchors, sitemap and crawler checks passed.'
