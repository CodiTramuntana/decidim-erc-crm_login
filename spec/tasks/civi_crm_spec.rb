# frozen_string_literal: true

require "spec_helper"
require "rake"

describe "civi_crm" do
  let(:invoke_task) { Rake.application.invoke_task(task) }

  before do
    Rake.application.rake_require "tasks/civi_crm"
    Rake::Task.define_task(:environment)
    allow(STDOUT).to receive(:puts)
    allow(File).to receive(:write)
  end

  describe "import" do
    let(:civi_crm_client) { Decidim::Erc::CrmAuthenticable::CiviCrmClient.new }
    let(:response) do
      {
        error: false,
        body: body
      }
    end

    before do
      allow(Decidim::Erc::CrmAuthenticable::CiviCrmClient).to receive(:new).and_return(civi_crm_client)
    end

    describe "comarcals" do
      let(:task) { "civi_crm:import:comarcals" }
      let(:body) do
        [
          {
            "contact_is_deleted" => "0",
            "contact_id" => "4",
            "display_name" => "Vallès Oriental (comarcal)"
          }
        ]
      end

      before do
        allow(civi_crm_client).to receive(:find_all_comarcals).and_return(response)
      end

      it "creates a YAML file with comarcals in it" do
        expect(File).to receive(:write).with(
          %r{config\/civi_crm\/comarcals.yml},
          /'4'\: Vallès Oriental \(comarcal\)/
        )

        invoke_task
      end
    end

    describe "local_comarcal_relationships" do
      let(:task) { "civi_crm:import:local_comarcal_relationships" }
      let(:body) do
        [
          {
            "contact_is_deleted" => "0",
            "contact_id" => "1",
            "api.Relationship.get" => { "values" => [{ "contact_id_b" => "4" }] }
          }
        ]
      end

      before do
        allow(civi_crm_client).to receive(:find_local_comarcal_relationships).and_return(response)
        allow(YAML).to receive(:load_file).and_return(double(keys: ["4"]))
      end

      it "creates a YAML file with local_comarcal_relationships in it" do
        expect(File).to receive(:write).with(
          %r{config\/civi_crm\/local_comarcal_relationships.yml},
          /'1'\: '4'/
        )

        invoke_task
      end
    end
  end

  describe "create:scopes" do
    let(:task) { "civi_crm:create:scopes" }
    let(:comarcals) do
      {
        "4" => "Vallès Oriental (comarcal)",
        "1928" => "Esquerra Maresme",
        "1954" => "Alt Penedès (comarcal)"
      }
    end

    context "with organization" do
      before do
        allow(YAML).to receive(:load_file).and_return(comarcals)
        Decidim::Organization.create!( # Have troubles with Faker translations
          name: "Kohler-Moen",
          host: "1.lvh.me",
          default_locale: "en",
          available_locales: ["en"],
          reference_prefix: "DDS",
          enable_omnipresent_banner: false,
          highlighted_content_banner_enabled: false,
          badges_enabled: true,
          send_welcome_notification: true,
          users_registration_mode: "enabled",
          user_groups_enabled: true
        )
      end

      it "creates Scopes and assign the correct codes" do
        expect { invoke_task }.to change(Decidim::Scope, :count).by(3)
        codes = Decidim::Scope.all.pluck(:code)
        expect(codes).to include("4", "1928", "1954")
      end
    end

    context "without organization" do
      it "does not create Scopes" do
        expect { invoke_task }.not_to change(Decidim::Scope, :count)
      end
    end
  end
end
