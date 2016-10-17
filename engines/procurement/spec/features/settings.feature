Feature: General Settings

  @settings
  Scenario: Creating a contact link
    Given I am Hans Ueli
    And I navigate to the settings page
    When I enter the following settings
      | key         | value                         |
      | contact_url | https://www.zhdk.ch/?finanzen |
    And I click on save
    Then I see a success message
    And the settings are saved successfully to the database
    And the contact link is visible
