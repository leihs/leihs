Feature: Visit model

  The Visit model is based on a direct sql query, not based on a concrete database table

  Scenario: Unique id
    Given the huge dump is loaded
    Then all the generated visit ids are unique
