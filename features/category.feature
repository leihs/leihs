Feature: Creating and editing the category tree in the backend

  As admin or inventory manager, I want to add new categories
  to the system and manage the category tree (parents, children).
  
  Background: We have a manager as well as stuff in categories
    Given inventory pool 'ABC'
      And a manager 'inv_man_0' with access level 3
      And his password is 'pass'
      And a category 'Tierkörperteile' exists
      And a category 'Hasenartige' exists
      And a category 'Allgemein' exists
      And the category 'Hasenartige' is child of 'Tierkörperteile' with label 'Hasenartige'
      And the category 'Allgemein' is child of 'Tierkörperteile' with label 'Allgemein'
      And a model 'Hasenpfote' exists
      And a model 'Hasenohr' exists
      And the model 'Hasenpfote' belongs to the category 'Hasenartige'
      And the model 'Hasenohr' belongs to the category 'Hasenartige'
      And I log in as 'inv_man_0' with password 'pass'
      And I press "Backend"  
      And I follow "ABC"   

  @javascript @logoutafter
  Scenario: Browsing the category list to verify that there's something in it
    When I follow "ABC"
     And I follow the sloppy link "All Models"
    Then I should see "Hasenpfote"
     And I should see "Hasenohr"
      
  @javascript @logoutafter
  Scenario: Browsing a specific category
     When I follow "ABC"
     Then the model "Hasenohr" should be in category "Hasenartige"
  
  @javascript @logoutafter @kaka
  Scenario: Assigning a model to a category when there are few categories
     When I follow "ABC"    
     And I follow the sloppy link "All Models"
     And I pick the model "Hasenohr" from the list
     And I follow "Categories (1)"
     And I check the category "Allgemein"
    Then I should see "This model is now in 2 categories" within "#flash"
     And the model "Hasenohr" should be in category "Allgemein"
     And the model "Hasenohr" should be in category "Hasenartige"

  @javascript @logoutafter @kaka
  Scenario: Assigning a model to a category when there are more categories
   Given a category 'Fuchshafte' exists
     And the category 'Fuchshafte' is child of 'Tierkörperteile' with label 'Fuchshafte'
     And a model 'Fuchsschwanz' exists
     And the model 'Fuchsschwanz' belongs to the category 'Fuchshafte'  
     When I follow "ABC"    
     And I follow the sloppy link "All Models"
     And I pick the model "Fuchsschwanz" from the list
     And I follow "Categories (1)"
     And I check the category "Allgemein"
    Then I should see "This model is now in 2 categories" within "#flash"
     And the model "Fuchsschwanz" should be in category "Allgemein"
     And the model "Fuchsschwanz" should be in category "Fuchshafte"
  
  @javascript @logoutafter
  Scenario: Removing a model from a category