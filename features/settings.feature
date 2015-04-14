Feature: Defining application settings through web interface

  @personas
  Scenario: The settings are existing
    Given I am Normin
    When I go to the home page
    Then I am on the home page

  @personas
  Scenario: The settings are missing
    Given I am Normin
    When the settings are not existing
    Then there is an error for the missing settings
    Given I am Ramon
    When I go to the home page
    Then I am on the settings page

  @javascript @personas
  Scenario: Editing the settings
    Given I am Ramon
    When I go to the settings page
    Then I am on the settings page
    And I edit the following settings
      | contract_lending_party_string |
      | contract_terms                |
      | default_email                 |
      | deliver_order_notifications   |
      | email_signature               |
      | local_currency_string         |
      | logo_url                      |
      | mail_delivery_method          |
      | smtp_address                  |
      | smtp_domain                   |
      | smtp_enable_starttls_auto     |
      | smtp_openssl_verify_mode      |
      | smtp_password                 |
      | smtp_port                     |
      | smtp_username                 |
      | time_zone                     |
      | user_image_url                |
    And the settings are persisted
