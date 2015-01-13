Feature: Mail templates

  As an admin or inventory manager
  I want to customize the text of the emails that leihs sends
  So that my users get all information they need
  and so that my leihs instance is unique and matches the rest
  of my organization.

  Scenario Outline: Available default templates in english
    Then the default <template name> exists in the file system in <directory> as <file name>
  Examples:
    | template name          | directory | file name                          |
    | approved               | order     | approved.text.liquid               |
    | changed                | order     | changed.text.liquid                |
    | received               | order     | received.text.liquid               |
    | rejected               | order     | rejected.text.liquid               |
    | submitted              | order     | submitted.text.liquid              |
    | deadline soon reminder | user      | deadline_soon_reminder.text.liquid |
    | reminder               | user      | reminder.text.liquid               |


  @personas
  Scenario Outline: Specifying system-wide default templates
    Given I am Gino
    When I specify a mail template for the <template name> action for the whole system for each active language
    And I save
    Then the template <template name> is saved for the whole system for each active language
  Examples:
    | template name          |
    | approved               |
    | changed                |
    | received               |
    | rejected               |
    | submitted              |
    | deadline soon reminder |
    | reminder               |

  @personas
  Scenario Outline: Specifying mail templates specific to an inventory pool
    Given I am Mike
    When I specify a mail template for the <template name> action in the current inventory pool for each active language
    And I save
    Then the template <template name> is saved for the current inventory pool for each active language
  Examples:
    | template name          |
    | approved               |
    | changed                |
    | received               |
    | rejected               |
    | submitted              |
    | deadline soon reminder |
    | reminder               |

  @personas
  Scenario Outline: Multilingual mail templates
    Given I am Normin
    And there is a system-wide approved mail template defined for the language "<language>"
    When my language is set to "<language>"
    And one of my submitted orders to an inventory pool without custom approved mail templates get approved
    Then I receive an approved mail based on the system-wide template for the language "<language>"
  Examples:
    | language |
    | de-CH    |
    | en-GB    |

  @personas
  Scenario Outline: Receiving reminders using the correct mail template
    Given I am Normin
    And I have a contract with deadline <deadline>
    And there <custom> a custom <template name> mail template for this contract's inventory pool
    And there <system> a system-wide <template name> mail template
    And there <default> a default <template name> mail template
    When the reminders are sent
    Then I receive an email formatted according to the <received template> <template name> mail template
  Examples:
    | template name          | deadline  | custom | system | default | received template |
    | reminder               | yesterday | is     | is     | is      | custom            |
    | reminder               | yesterday | is not | is     | is      | system-wide       |
    | reminder               | yesterday | is not | is not | is      | default           |
    | deadline soon reminder | tomorrow  | is     | is     | is      | custom            |
    | deadline soon reminder | tomorrow  | is not | is     | is      | system-wide       |
    | deadline soon reminder | tomorrow  | is not | is not | is      | default           |

  @personas
  Scenario Outline: Mail template language precendence
    Given I am Normin
    And my language is set to "<language>"
    And I have a contract with deadline yesterday
    And there is a custom reminder mail template for this contract's inventory pool in "<custom languages>"
    And there is a system-wide reminder mail template in "<system languages>"
    When the reminders are sent
    Then I receive a <received template> reminder in "<received language>"
  Examples:
    | language | custom languages  | system languages  | received template | received language |
    | de-CH    | de-CH,en-GB,en-US | de-CH,en-GB,en-US | custom            | de-CH             |
    | de-CH    | en-GB,en-US       | de-CH,en-GB,en-US | custom            | en-GB,en-US       |
    | de-CH    | none              | de-CH,en-GB,en-US | system-wide       | de-CH             |
    | de-CH    | none              | en-GB,en-US       | system-wide       | en-GB,en-US       |
    | de-CH    | none              | none              | default           | default           |

  @upcoming
  Scenario: Receiving mails using order templates

  @personas
  Scenario: How an email template is parsed
    Given I am Normin
    And I have a contract with deadline yesterday for the inventory pool "A-Ausleihe"
    And there is a custom reminder mail template for this contract's inventory pool
    And the custom reminder mail template looks like
    """
Dear {{ user.name }},

Kind regards,
{{ inventory_pool.name }}
    """
    When the reminders are sent
    Then I receive an email formatted according to the custom reminder mail template
    And the mail body looks like
    """
Dear Normin Normalo,

Kind regards,
A-Ausleihe
    """

  @personas @javascript
  Scenario Outline: Reporting errors on mail templates
    Given I am <persona>
    When I specify a mail template for the <template name> action <scope> for each active language
    When I edit the <template name> with the "<body>" template in "en-GB"
    And I save
    Then I land on the mail templates edit page
    And I see an error message
    And the failing <template name> mail template in "en-GB" is highlighted in red
    And the failing <template name> mail template in "en-GB" is not persisted with the "<body>" template
  Examples:
    | persona | scope                         | template name | body                |
    | Gino    | for the whole system          | reminder      | Hi {{{ user.name }} |
    | Mike    | in the current inventory pool | reminder      | Hi {{{ user.name }} |
