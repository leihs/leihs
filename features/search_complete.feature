#Feature: The programmer should be sure that he's covered all the search cases
#
#       As a programmer I want to be sure that whatever is searchable
#       has the respective visual representation to display it.
#
#  @old-ui
#  Scenario: There needs to be a search partial for each indexed model
#    When I count the number of indexed models
#    Then that number must be the same as the number of search partials
#    Given comment: because otherwise we can get search results that have no
#    Given comment: means, i.e. no partial to "visualise" aka represent them
