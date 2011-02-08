Feature: Leihs must perform acceptably for its users

	We want to make sure that performance of leihs does not degrade as
	leihs evolves.
  
  Scenario: Computing availability of a heavily booked model should remain acceptable
    Given the MacBook availability as of 2011-01-11
     When its availability is recalculate
     Then it should take at maximum 4 seconds
