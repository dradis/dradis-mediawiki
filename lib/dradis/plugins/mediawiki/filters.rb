module Dradis::Plugins::Mediawiki::Filters
  class FullTextSearch < Dradis::Plugins::Import::Filters::Base
    def query(params={})
      results = []

      host   = Dradis::Plugins::Mediawiki::Engine.settings.host
      path   = Dradis::Plugins::Mediawiki::Engine.settings.path
      port   = Dradis::Plugins::Mediawiki::Engine.settings.port
      scheme = Dradis::Plugins::Mediawiki::Engine.settings.scheme
      limit = Dradis::Plugins::Mediawiki::Engine.settings.limit

      port   = (scheme == 'https' ? 443 : 80) if port.blank?

      begin
        # Parameters required by MediaWiki API
        # http://localhost/mediawiki-1.21.1/api.php?action=query&prop=revisions&generator=search&gsrwhat=text&gsrlimit=max&gsrsearch=Directory&rvprop=content&format=xml
        filter_params = {
             action: 'query',
               prop: 'revisions',
          generator: 'search',
            gsrwhat: 'text',
           gsrlimit: CGI::escape(limit),
          gsrsearch: CGI::escape(params[:query]), # user query
             rvprop: 'content',
             format: 'xml'
        }

        # Get the results over HTTP
        Net::HTTP.start(host, port, use_ssl: scheme == 'https') do |http|
          res = http.get("#{path}?#{filter_params.to_query}")
          xml_doc = Nokogiri::XML( res.body )
          results += xml_doc.xpath('api/query/pages/page').map do |xml_page|
            Dradis::Plugins::Import::Result.new(
                    title: xml_page[:title],
              description: fields_from_wikitext(xml_page.at_xpath('revisions/rev').text())
            )
          end
        end

      #rescue Exception => e
      #  records << {
      #              :title => 'Error fetching records',
      #              :description => e.message + "\n\n\n" +
      #                            "This error can be cause by a configuration " +
      #                            "issue (i.e. dradis not finding the MediaWiki instance). " +
      #                            "Please review the configuration settings located at:\n\n" +
      #                            "./server/vendor/plugins/wiki_import/lib/wiki_import/filters.rb"
      #             }
      end

      return results
    end

    private
    # WikiMedia has its own formatting, and there are some tweaks we need to do
    # to addapt it to standard dradis convention.
    def fields_from_wikitext(wikitext)
      fields = Dradis::Plugins::Mediawiki::Engine::settings.fields

      dradis_fields = wikitext
      fields = fields.split(',')
      fields.each do |f|
        dradis_fields.sub!( /=+#{f}=+/, "#[#{f}]#" )
      end
      return dradis_fields
    end
  end
end

Dradis::Plugins::Import::Filters.add :mediawiki, :full_text_search, Dradis::Plugins::Mediawiki::Filters::FullTextSearch
