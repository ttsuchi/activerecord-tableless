Feature: Rails integration

  Background:
    Given I generate a new rails application
    And I run a "scaffold" generator to generate a "User" scaffold with "name:string"
    And I delete all migrations
    And I update my new user model to be tableless
    And I update my users controller to render instead of redirect

  Scenario: Work as normal model
    And I start the rails application
    When I go to the new user page
    And I fill in "Name" with "something"
    And I press "Create"
    Then I should see "Name: something"

