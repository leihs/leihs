Feature: Email templates

  As an admin or inventory manager
  I want to customize the text of the emails that leihs sends
  So that my users get all information they need
  and so that my leihs instance is unique and matches the rest
  of my organization.

  Scenario: How an email template is parsed
    # TBD

  @upcoming
  Scenario Outline: Specifying system-wide default templates
    Given I am Gino
    When I specify an email template for the <action> action
    And the inventory pool in question does not have its own custom email template
    Then these templates are used for the <action>
    Examples:
    | action                 |
    | approved order         |
    | changed order          |
    | received order         |
    | rejected order         |
    | submitted order        |
    | deadline soon reminder |
    | reminder               |

  @upcoming
  Scenario Outline: Specifying templates specific to an inventory pool
    Given I am Mike
    When I specify an email template for the <action> action in the current inventory pool
    Then these templates are used for the <action> in the current inventory pool
    Examples:
    | action                 |
    | approved order         |
    | changed order          |
    | received order         |
    | rejected order         |
    | submitted order        |
    | deadline soon reminder |
    | reminder               |

  @upcoming
  Scenario Outline: Multilingual email templates
    Given there is a system-wide email template defined for the lanuage "<language>"
    When a user has their language set to "<language>"
    And the user's orders are from an inventory pool without custom email templates
    Then they receive emails based on the system-wide template for the language "<language>"
    Examples:
    | language |
    | de-CH    |
    | en-GB    |

  @upcoming
  Scenario: Precedence of email templates
    Given there is a system-wide email template defined
    Then the system-wide email template is used when sending email concerning any inventory pool
    When there is an inventory-pool-specific email template for an inventory pool
    Then the inventory-pool-specific email template is used when sending email concerning that inventory pool
