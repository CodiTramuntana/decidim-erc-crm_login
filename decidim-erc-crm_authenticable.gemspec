# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/erc/crm_authenticable/version"

Gem::Specification.new do |s|
  s.version = Decidim::Erc::CrmAuthenticable.version
  s.authors = ["Isaac Massot"]
  s.email = ["isaac.mg@coditramuntana.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/CodiTramuntana/decidim-erc-crm_authenticable/"
  s.required_ruby_version = ">= 2.6.3"

  s.name = "decidim-erc-crm_authenticable"
  s.summary = "A decidim Erc::CrmAuthenticable module"
  s.description = "Integration with CiviCrm for ERC."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", "~>#{Decidim::Erc::CrmAuthenticable.decidim_version}"
  s.add_dependency "decidim-verifications", "~>#{Decidim::Erc::CrmAuthenticable.decidim_version}"

  s.add_development_dependency "decidim-dev", "~>#{Decidim::Erc::CrmAuthenticable.decidim_version}"
end
