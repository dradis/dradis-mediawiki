module Dradis::Plugins::Mediawiki

  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::Mediawiki

    include ::Dradis::Plugins::Base
    provides :import
    description 'Import entries from an external MediaWiki'

    addon_settings :wikiimport do
      settings.default_host      = 'https://localhost'
      settings.default_port      = 443
      settings.default_path      = 'mediawiki/api.php'
      settings.default_fields    = 'Title,Impact,Probability,Description,Recommendation'
    end
  end

end
