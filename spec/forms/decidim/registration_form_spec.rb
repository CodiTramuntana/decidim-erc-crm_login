# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe RegistrationForm do
    let(:form) do
      described_class.from_params(
        name: "User",
        nickname: "justme",
        email: "user@example.org",
        password: "S4CGQ9AM4ttJdPKS",
        password_confirmation: "S4CGQ9AM4ttJdPKS",
        tos_agreement: "1",
        phone_number: phone_number,
        extended_data: extended_data.to_json
      ).with_context(
        current_organization: create(:organization)
      )
    end

    let(:extended_data) do
      {
        "document_number" => "document_number",
        "member_of_code" => "member_of_code"
      }
    end
    let(:phone_number) { "666-666-666" }

    describe "valid?" do
      subject { form.valid? }

      context "when extended_data is present" do
        it { is_expected.to eq(true) }
      end

      context "when extended_data NOT present" do
        let(:extended_data) { nil }

        it { is_expected.to eq(false) }
      end
    end

    describe "extended_data" do
      subject { form.extended_data }

      context "when form has not been validated yet" do
        it { is_expected.to be_a(String) }
      end

      context "when form is validated" do
        before { form.valid? }

        it { is_expected.to be_a(Hash) }

        it { is_expected.to include(extended_data) }

        context "and phone_number is present" do
          it { is_expected.to include("phone_number" => Base64.encode64(phone_number)) }
        end

        context "and phone_number is NOT present" do
          let(:phone_number) { nil }

          it { is_expected.to include("phone_number" => "") }
        end
      end
    end
  end
end
