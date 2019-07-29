# Decidim::Erc::CrmAuthenticable

Decidim::Erc::CrmAuthenticable is based on the [Decidim::Verifications](https://github.com/decidim/decidim/tree/master/decidim-verifications#decidimverifications) module and implements a custom verification method against the CiviCrm of Esquerra Republicana.

## How it works

Registration:
- The DNI is validated against CiviCRM before allowing the user to register.
- The user is redirected to the registration form prefilled with the personal data found in CiviCRM.
- The user is created with the following information stored in the extended_data Hash:
  - phone_number:
  - member_of_code:
  - document_number: Base64-encoded version of their identity document number (for further requests)

Login:
- After loggin in, users are validated against CiviCRM to check if they are dues-paying members of Esquerra Republicana; if not, they are logged out.
- If they are succesfully validated a Decidim::Authorization is created or updated for the user; else, their authorization is deleted.

Verification options:
These options can be set in the admin zone to alter the authorization logic related to a component action:
- Type of membership: militant, sympathizer or friend.
- membership seniority: number of months.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-erc-crm_authenticable'
```

And then execute:

```bash
bundle
```

CrmAuthenticable needs some values to perform requests:

```yml
erc_crm_authenticable:
  api_base: <%= ENV["CIVICRM_API_BASE"] %>
  site_key: <%= ENV["CIVICRM_SITE_KEY"] %>
  api_key: <%= ENV["CIVICRM_API_KEY"] %>
  secret_key: <%= ENV["ERC_SECRET_KEY"] %>
```

## Testing

1. Run `bundle exec rake test_app`.

2. Run tests with `bundle exec rspec`

3. Set the configuration values for the test app in `spec/decidim_dummy_app/config/secrets.yml`

```yaml
# The test stubs are configured to use the following values as to not reveal the real ones.
erc_crm_authenticable:
  api_base: https://api.base/?
  site_key: site_key
  api_key: api_key
  secret_key: secret_key
```

## Versioning

`Decidim::Erc::CrmAuthenticable` depends directly on `Decidim::Core` in `0.19.0` version.

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
