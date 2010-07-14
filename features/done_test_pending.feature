Feature: Resolved Wishes and Bug Reports by our Users that are pending a Test

Background: moving resolved todo's here, which we did not have the time to write tests for

Scenario: Inventory Manager should be able to add own ("Besitzer" and not "Verantwortlicher"!) Items to Package
  Given reported by Mike on 12.July 2010
  Given resolved by tpo on 12.July
  Given test pending

Scenario: The inventory relevant flag should be 'no' by default and 'yes' for managers with level > 3 who should be also able to set it
# BUG: A manager of level 2 should not be able to create items flagged "inventory relevant". The default must be "not inventory relevant"
  Given reported by Mike on 12.July 2010
  Given resolved by tpo on 13.July
  Given test pending
