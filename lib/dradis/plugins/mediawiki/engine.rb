module Dradis::Plugins::Mediawiki
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::Mediawiki

    include ::Dradis::Plugins::Base
    provides :import
    description 'Import entries from an external MediaWiki'

    addon_settings :wikiimport do
      settings.default_fields    = 'Title,Impact,Probability,Description,Recommendation'
      settings.default_host      = 'localhost'
      settings.default_path      = 'mediawiki/api.php'
      settings.default_port      = 443
      settings.default_scheme    = 'http(s)'
      settings.default_limit     = 'max'
    end
  end
end
