Feature: Edit order

  @javascript @personas
  Scenario: View suspended status of a user
    Given I am Pius
    When I navigate to the open orders
    And I open a take back for a suspended user
    Then I see the note 'Suspended!' next to their name

  @javascript @personas
  Scenario: Prevent 'approve anyway' for group managers
    Given I am Andi
    And an order contains overbooked models
    When I edit the order
    And I approve the order
    Then I cannot force the order to be approved

  @personas @javascript
  Scenario: No empty orders in the order list
    Given I am Pius
    Then I don't see empty orders in the list of orders

  @personas
  Scenario: Visible tabs
    Given I am Andi
    When I am listing the orders
    Then I see the tabs "All, Pending, Approved, Rejected"

  @personas
  Scenario: Definition of orders requiring verification
    Given a verifiable order exists
    Then this order was created by a user that is in a group whose orders require verification
    And this order contains a model from a group whose orders require verification

  @javascript @personas
  Scenario: Show all orders - tab 'All orders'
    Given I am Andi
    And I am in an inventory pool with verifiable orders
    And I am listing the orders
    When I view the tab "All"
    Then I see all verifiable orders
    And these orders are ordered by creation date

  @javascript @browser @personas
  Scenario: Displaying the tab of pending orders
    Given I am Andi
    And I am in an inventory pool with verifiable orders
    And I am listing the orders
    When I view the tab "Pending"
    Then I see all pending verifiable orders
    Then I see who placed this order on the order line and can view a popup with user details
    And I see the order's creation date on the order line
    And I see the number of items on the order line and can view a popup containing the items ordered
    And I see the duration of the order on the order line
    And I see the purpose on the order line
    And I can approve the order
    And I can reject the order
    And I can edit the order
    And I cannot hand over orders

  @javascript @browser @personas
  Scenario: Displaying the tab of approved orders
    Given I am Andi
    And I am in an inventory pool with verifiable orders
    And I am listing the orders
    When I view the tab "Approved"
    Then I see all verified and approved orders
    And I see who placed this order on the order line and can view a popup with user details
    And I see the order's creation date on the order line
    And I see the number of items on the order line and can view a popup containing the items ordered
    And I see the duration of the order on the order line
    And I see the order's status on the order line
    And I edit an already approved order
    And I am directed to the hand over view
    But I cannot hand over


  @javascript @browser @personas
  Scenario: Displaying the tab of rejected orders
    Given I am Andi
    And I am in an inventory pool with verifiable orders
    And I am listing the orders
    When I view the tab "Rejected"
    Then I see all verifiable rejected orders
    And I see who placed this order on the order line and can view a popup with user details
    And I see the order's creation date on the order line
    And I see the number of items on the order line and can view a popup containing the items ordered
    And I see the duration of the order on the order line
    And I see the order's status on the order line

  @javascript @personas
  Scenario: Remove filter that shows orders to be verified
    Given I am Andi
    And I am in an inventory pool with verifiable orders
    And I am listing the orders
    Then I see all verifiable orders
    When I uncheck the filter "To be verified"
    Then I see orders placed by users in groups requiring verification

  @javascript @browser @personas
  Scenario: Reset order that is already approved
    Given I am Andi
    And I am in an inventory pool with verifiable orders
    And I am listing the orders
    When I view the tab "Approved"
    And I edit an already approved order
    Then I am directed to the hand over view
    And I can add models
    And I can add options
    But I cannot assign items
    And I cannot hand over
