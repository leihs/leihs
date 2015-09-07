Feature: Inventory

  Background:
    Given I am Mike
    And I open the inventory

  @javascript @personas
  Scenario: Finding inventory using a search term
    Given there is a model with the following properties:
      | Name       | suchbegriff1 |
      | Manufacturer | suchbegriff4 |
    And there is a item with the following properties:
      | Inventory code | suchbegriff2 |
    When I search in the inventory section for one of those properties
    Then all matching models appear
    And all matching items appear

  @javascript @personas
  Scenario: Finding packages using search term
    Given there is a model with the following properties:
      | Name | Package Model |
    And this model is a package
    And there is a item with the following properties:
      | Inventory code | P-AVZ40001 |
    And this package item is part of this package model
    And there is a model with the following properties:
      | Name | Normal Model |
    And there is a item with the following properties:
      | Inventory code | AVZ40020 |
    And this item is part of this package item
    When I search in the inventory section for one of those properties
    Then all matching package models appear
    And all matching package items appear
    And all matching items appear

  @personas @javascript @browser
  Scenario: Finding model and item in the inventory pool that owns them
    Given there is a model with the following properties:
      | Name | Package Model |
    And this model is a package
    And there is a item with the following properties:
      | Inventory code             | P-AVZ40001             |
      | Owner                      | Another inventory pool |
      | Responsible inventory pool | Another inventory pool |
    And this package item is part of this package model
    And there is a model with the following properties:
      | Name | Normal Model |
    And there is a item with the following properties:
      | Inventory code             | AVZ40020               |
      | Owner                      | Current inventory pool |
      | Responsible inventory pool | Another inventory pool |
    And this item is part of this package item
    When I search for the following properties in the inventory section:
      | Normal Model |
    Then the item corresponding to the model appears
    And the item appears
    When I search for the following properties in the inventory section:
      | AVZ40020 |
    Then the item corresponding to the model appears
    And the item appears

  @personas @javascript @browser
  Scenario Outline: Finding a package's models and items in its responsible inventory pool
    Given there is a model with the following properties:
      | Name | Package Model |
    And this model is a package
    And there is a item with the following properties:
      | Inventory code             | P-AVZ40001             |
      | Owner                      | Current inventory pool |
      | Responsible inventory pool | Current inventory pool |
    And this package item is part of this package model
    And there is a model with the following properties:
      | Name | Normal Model |
    And there is a item with the following properties:
      | Inventory code             | AVZ40020               |
      | Owner                      | Another inventory pool |
      | Responsible inventory pool | Current inventory pool |
    And this item is part of this package item
    When I search for the following properties in the inventory section:
      | <property> |
    Then the item corresponding to the model appears
    And the item appears
    And all matching package models appear
    And all matching package items appear
    And all matching items appear
  Examples:
    | property     |
    | Normal Model |
    | AVZ40020     |

  @personas @javascript @browser
  Scenario: The tab 'All'
    Then I can click one of the following tabs to filter inventory by:
      | Choice |
      | All               |

  @personas @javascript @browser
  Scenario: The tab 'Models'
    Then I can click one of the following tabs to filter inventory by:
      | Choice |
      | Models            |

  @personas @javascript @browser
  Scenario: The tab 'Packages'
    Then I can click one of the following tabs to filter inventory by:
      | Choice |
      | Packages          |

  @personas @javascript @browser
  Scenario: The tab 'Options'
    Then I can click one of the following tabs to filter inventory by:
      | Choice |
      | Options           |

  @personas @javascript @browser
  Scenario: The tab 'Software'
    Then I can click one of the following tabs to filter inventory by:
      | Choice |
      | Software           |

  @personas @javascript @browser
  Scenario Outline: Filtering used and unused inventory
    Given I see retired and not retired inventory
    When I choose inside all inventory as "<dropdown>" the option "<property>"
    Then only the "<property>" inventory is shown
  Examples:
    | dropdown        | property |
    | used & not used | used     |
    | used & not used | not used |

  @personas @javascript @browser
  Scenario Outline: Filtering borrowable and not borrowable inventory
    Given I see retired and not retired inventory
    When I choose inside all inventory as "<dropdown>" the option "<property>"
    Then only the "<property>" inventory is shown
  Examples:
    | dropdown                  | property       |
    | borrowable & unborrowable | borrowable     |
    | borrowable & unborrowable | unborrowable   |

  @personas @javascript @browser
  Scenario Outline: Filtering retired and not retired inventory
    Given I see retired and not retired inventory
    When I choose inside all inventory as "<dropdown>" the option "<property>"
    Then only the "<property>" inventory is shown
  Examples:
    | dropdown              | property    |
    | retired & not retired | retired     |
    | retired & not retired | not retired |

  @personas @javascript @browser
  Scenario Outline: Filter inventory by owner, stock, completeness and defective status
    Given I see retired and not retired inventory
    When I set the option "<filter>" inside of the full inventory
    Then only the "<filter>" inventory is shown
  Examples:
    | filter     |
    | Owned      |
    | In stock   |
    | Incomplete |
    | Broken     |

  @personas @javascript @browser
  Scenario: Filtering by responsible department
    Given I see retired and not retired inventory
    When I choose a certain responsible pool inside the whole inventory
    Then only the inventory is shown for which this pool is responsible

  @personas @javascript
  Scenario: The default filter is "not retired"
    Then for the following inventory groups the filter "not retired" is set
      | All     |
      | Models  |
      | Software |

  @personas @javascript
  Scenario: Default setting for the list view
    Then the tab "All" is active

  # # Not implemented
  # @personas
  # Scenario: Default setting for the "Software" view
  #   # Undefined
  #   Then enthält die Auswahl "Software" Software und Software-Lizenzen
  #   And der Filter "Nicht Ausgemustert" ist aktiviert

  @javascript @personas @browser
  Scenario: What an option line contains
    Given one is on the list of the options
    Then the option line contains:
      | information |
      | Barcode     |
      | Name        |
      | Price       |

  @javascript @personas @browser
  Scenario: Expand package models
    Then I can expand each package model line
    And I see the packages contained in this package model
    And such a line looks like an item line
    And I can expand this package line
    And I see the components of this package
    And such a line shows only inventory code and model name of the component

  @javascript @personas @browser
  Scenario: Look of a model line
    When I see a model line
    Then the model line contains:
      | information              |
      | Image                    |
      | Model name               |
      | Number available (now)   |
      | Number available (total) |

  @javascript @personas @browser
  Scenario: Look of an item line
    When I view the tab "Models"
    And the item is in stock and my department is responsible for it
    Then the item line contains:
      | information          |
      | Code of the building |
      | Room                 |
      | Shelf                |
    When my department is the owner but has given responsibility for the item to another department
    Then the item line contains:
      | information            |
      | Responsible department |
      | Code of the building   |
      | Room                   |
    When I view the tab "Models"
    And the item is not in stock and another department is responsible for it
    Then the item line contains:
      | information            |
      | Responsible department |
      | Current borrower       |
      | End date of contract   |

  @javascript @personas @browser
  Scenario: Look of a software license line
    Given there exists a software license
    And I see retired and not retired inventory
    When I look at this license in the software list
    Then the software license line contains:
      | information    |
      | Operating system |
      | License type      |
    Given there exists a software license of one of the following types
      | Typ                | technical          |
      | Concurrent         | concurrent         |
      | Site license       | site_license       |
      | Multiple workplace | multiple_workplace |
    When I look at this license in the software list
    Then the software license line contains:
      | information      |
      | Operating system |
      | License type     |
      | Quantity         |
    Given there exists a software license, owned by my inventory pool, but given responsibility to another inventory pool
    When I look at this license in the software list
    Then the software license line contains:
      | information            |
      | Responsible department |
      | Operating system       |
      | License type           |
    Given there exists a software license, which is not in stock and another inventory pool is responsible for it
    When I look at this license in the software list
    Then the software license line contains:
      | information            |
      | Responsible department |
      | Current borrower       |
      | End date of contract   |
      | Operating system       |
      | License type           |

  @javascript @personas
  Scenario: How to display no results after a search
    When I make a search without any results
    Then I see 'No entries found'

  @javascript @personas @browser
  Scenario: Expand model
    Then I can expand each model line
    And I see the items belonging to the model
    And such a line looks like an item line

  # # Not implemented
  # #73278620
  # # No steps for this seem to be defined?
  #  @personas
  # Scenario: Verhalten nach Speichern
  #   When ich einen Reiter auswähle
  #   And ich eine oder mehrere Filtermöglichkeiten verwende
  #   When ich eine aufgeführte Zeile editiere
  #   And I save
  #   Then werde ich zur Liste des eben gewählten Reiters mit den eben ausgewählten Filtern zurueckgefuehrt

  @personas @javascript @browser
  Scenario Outline: Labeling of broken, retired, incomplete and unborrowable items
    Given I see the list of "<condition>" inventory
    When I open a model line
    Then the item line ist marked as "<condition>" in red
    Examples:
      | condition    |
      | Broken       |
      | Retired      |
      | Incomplete   |
      | Unborrowable |

  @personas @javascript @browser
  Scenario: Displaying multiple problems on an item line
    Given I see retired and not retired inventory
    And there exists an item with many problems
    When I search after this item in the inventory list
    And I open the model line of this item
    Then the problems of this item are displayed separated by a comma
