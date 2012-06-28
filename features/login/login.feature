Feature: Login

  In order to login
  As a normal user
  I want to be able to login

  Background:
    Given personas existing

  @javascript
  Scenario: Redirection after i successful login
    When "Ramon" sign in successfully he is redirected to the "Admin" section
    When "Mike" sign in successfully he is redirected to the "Inventory" section
    When "Pius" sign in successfully he is redirected to the "Lending" section
