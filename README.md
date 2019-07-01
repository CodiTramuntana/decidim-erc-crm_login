# Decidim::Erc::Crm::Login

Integration with CiviCrm of ERC.

## Usage


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-erc-crm_login'
```

And then execute:

```bash
bundle
```

CrmLogin needs some values to perform requests:

```yml
civicrm:
  api_base: <%= ENV["CIVICRM_API_BASE"] %>
  site_key: <%= ENV["CIVICRM_SITE_KEY"] %>
  api_key: <%= ENV["CIVICRM_API_KEY"] %>
```

## Testing

1. Run `bundle exec rake test_app`. **Execution will fail in an specific migration.**

2. cd `spec/decidim_dummy_app/` and:

  2.1. Comment `up` execution in failing migration

  2.2. Execute...
  ```bash
  RAILS_ENV=test bundle exec rails db:drop
  RAILS_ENV=test bundle exec rails db:create
  RAILS_ENV=test bundle exec rails db:migrate
  ```
3. back to root folder `cd ../..`

4. run tests with `bundle exec rspec`

5. Remember to configure this new test App with configuration values.

## Versioning

`Decidim::Erc::CrmLogin` depends directly on `Decidim::Core` in `0.18.0` version.

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
