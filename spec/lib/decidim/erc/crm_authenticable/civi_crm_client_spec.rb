# frozen_string_literal: true

require "spec_helper"
require "rest-client"

module Decidim
  module Erc
    module CrmAuthenticable
      describe CiviCrmClient do
        let(:document_number) { "123456789A" }

        describe "get_militant" do
          subject { described_class.new(document_number).get_militant }

          context "when document_number is valid against CiviCRM" do
            before { stub_valid_request }

            it { is_expected.to include(is_error: false) }

            it "contains information in the body" do
              expect(subject[:body]).to be_a(Hash)
              expect(subject[:body]).not_to be_empty
            end
          end

          context "when document_number NOT is valid against CiviCRM" do
            before { stub_invalid_request_not_member }

            it { is_expected.to include(is_error: false) }

            it "does NOT contain information in the body" do
              expect(subject[:body]).to be_nil
            end
          end

          context "when it fails to connect to CiviCRM" do
            before do
              expect(RestClient).to receive(:get).and_return(RestClient::ImATeapot)
            end

            it { is_expected.to include(is_error: true) }
          end
        end
      end
    end
  end
end
