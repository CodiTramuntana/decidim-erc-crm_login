# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Erc
    module CrmAuthenticable
      describe IdentityDocumentForm do
        let(:form) do
          described_class.from_params(document_number: document_number)
        end

        let(:document_number) { "123456789A" }

        describe "valid?" do
          subject { form.valid? }

          context "when document_number NOT present" do
            let(:document_number) { nil }

            it { is_expected.to eq(false) }
          end

          context "when document_number NOT is valid against CiviCRM" do
            before { stub_invalid_request_not_member }

            it { is_expected.to eq(false) }
          end

          context "when document_number is valid against CiviCRM" do
            before { stub_valid_request }

            it { is_expected.to eq(true) }
          end

          context "when it fails to connect to CiviCRM" do
            before { stub_invalid_request_connection_error }

            it { is_expected.to eq(false) }
          end
        end

        describe "registration_form_params" do
          subject { form.registration_form_params }

          context "when form has not been validated yet" do

            it { is_expected.to be_empty }
          end

          context "when document_number is valid against CiviCRM" do
            let(:user_data) do
              {
                name: a_kind_of(String),
                nickname: a_kind_of(String),
                email: a_kind_of(String),
                phone_number: a_kind_of(String),
                extended_data: a_kind_of(String)
              }
            end

            before do
              stub_valid_request
              form.validate
            end

            it { is_expected.to include(user_data) }
          end

          context "when document_number NOT is valid against CiviCRM" do
            before do
              stub_invalid_request_not_member
              form.validate
            end

            it { is_expected.to be_empty }
          end

          context "when it fails to connect to CiviCRM" do
            before do
              stub_invalid_request_connection_error
              form.validate
            end

            it { is_expected.to be_empty }
          end
        end
      end
    end
  end
end
