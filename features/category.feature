Feature: Creating and editing the category tree in the backend

  As admin or inventory manager, I want to add new categories
  to the system and manage the category tree (parents, children).
  
  Background: There's a manager logged in
    Given inventory pool 'ABC'
      And a manager 'inv_man_0' with access level 3
      And his password is 'pass'
      And a category 'Tierkörperteile' exists
      And a category 'Hasenartige' exists
      And the category 'Hasenartige' is child of 'Tierkörperteile' with label 'Hasenartige'
      And a model 'Hasenpfote' exists
      And a model 'Hasenohr' exists
      And the model 'Hasenpfote' belongs to the category 'Hasenartige'
      And the model 'Hasenohr' belongs to the category 'Hasenartige'
      
  @javascript    
  Scenario: Browsing the category list to verify that there's something in it
    When I log in as 'inv_man_0' with password 'pass'
     And I press "Backend"
     And I follow "ABC"
     And I follow the sloppy link "All Models"
     Then I should see "Hasenpfote"
     And I should see "Hasenohr"
     
  Scenario: Assigning a model to a category
  
  Scenario: Assigning a model to a subcategory
  
  Scenario: Removing a model from a category