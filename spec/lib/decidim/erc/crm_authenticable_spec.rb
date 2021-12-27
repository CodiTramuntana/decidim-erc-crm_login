# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Erc
    describe CrmAuthenticable do


      context "when the `users_csv_path` is set" do
        before do
          Rails.application.secrets.erc_crm_authenticable[:users_csv_path]= 'spec/fixtures/files/csv_users_pre.csv'
        end
        after do
          Rails.application.secrets.erc_crm_authenticable[:users_csv_path]= nil
          ::Decidim::Erc::CrmAuthenticable.reset_mode!
        end

        it "works in CSV mode" do
          expect(::Decidim::Erc::CrmAuthenticable.crm_mode?).to be_falsy
          expect(::Decidim::Erc::CrmAuthenticable.csv_mode?).to be_truthy
        end
      end

      context "when the `users_csv_path` is NOT set" do
        it "works in CRM mode" do
          expect(::Decidim::Erc::CrmAuthenticable.crm_mode?).to be_truthy
          expect(::Decidim::Erc::CrmAuthenticable.csv_mode?).to be_falsy
        end
      end

    end
  end
end
