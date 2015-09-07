Feature: Availability

  @personas
  Scenario: Maximum availability considering groups
    Given I am Normin
    And the model "Kamera Nikon X12" has following partitioning in inventory pool "A-Ausleihe":
      | group    | quantity |
      | Cast     | 1       |
      | IAD      | 1       |
      | General  | 3       |
    When I am member of group "Cast"
    And I am not member of group "IAD"
    Then the maximum available quantity of this model for me is 4
    When I am member of group "IAD"
    Then the maximum available quantity of this model for me is 5
    When I am not member of any group
    Then the maximum available quantity of this model for me is 3

  @personas
  Scenario: Group priorities when assigning
    Given I am Normin
    And the model "Kamera Nikon X12" has following partitioning in inventory pool "A-Ausleihe":
      | group    | quantity |
      | Cast     | 1       |
      | IAD      | 1       |
      | General  | 3       |
    And I am member of group "Cast"
    And I am member of group "IAD"
    Then the general group is used last in assignments

  @personas
  Scenario: Splitting capacities (Group General / Another Group)
    Given I am Normin
    And the model "Kamera Nikon X12" has following partitioning in inventory pool "A-Ausleihe":
      | group    | quantity |
      | Cast     | 1       |
      | IAD      | 1       |
      | General  | 3       |
    And I am member of group "Cast"
    And I am member of group "IAD"
    When I have 5 approved reservations for this model in this inventory pool
    Then 1 of these reservations is allocated to group "Cast"
    And 1 of these reservations is allocated to group "IAD"
    And 3 of these reservations are allocated to group "General"
    And all these reservations are available

  @javascript @browser @personas
  Scenario: No availability for options
    Given I am Pius
    When a take back contains only options
    Then no availability will be computed for these options
