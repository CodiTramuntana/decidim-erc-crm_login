# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'decidim/erc/crm_login/version'

Gem::Specification.new do |s|
  s.version = Decidim::Erc::CrmLogin.version
  s.authors = ['Isaac Massot']
  s.email = ['isaac.mg@coditramuntana.com']
  s.license = 'AGPL-3.0'
  s.homepage = ''
  s.required_ruby_version = '>= 2.5.3'

  s.name = 'decidim-erc-crm_login'
  s.summary = 'A decidim Erc::CrmLogin module'
  s.description = 'Integration with CiviCrm for ERC.'

  s.files = Dir['{app,config,lib}/**/*', 'LICENSE-AGPLv3.txt', 'Rakefile', 'README.md']

  # DECIDIM_VERSION = '>= 0.18.0'
  DECIDIM_VERSION = '>= 0.17.0'

  s.add_dependency "decidim-core", DECIDIM_VERSION
  s.add_dependency 'rails', '>= 5.2'
  s.add_dependency 'civicrm'
  s.add_dependency "decidim-verifications", DECIDIM_VERSION
  s.add_dependency "virtus-multiparams"

  s.add_development_dependency 'decidim-dev', DECIDIM_VERSION
end
