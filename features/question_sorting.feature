@Question

Feature: Sorting questions

  In order to see the most relevant questions first
  As a user
  I want to see the questions list in a sorting order I choose

  Scenario: Root page
    Given there are sortable questions
    When I visit root page
    Then I should see newest questions first

  Scenario Outline: Questions page
    Given there are sortable questions
    And I visit questions page
    When I choose <criterion> sorting order
    Then I should see <criterion> questions first
  Examples:
    | criterion   |
    | newest      |
    | hot         |
    | votes       |
    | activity    |
    | unanswered  |

  Scenario Outline: Remembering sorting order
    Given I visit questions page
    When I choose <criterion> sorting order
    And I visit questions page
    Then <criterion> tab should be selected
  Examples:
    | criterion   |
    | newest      |
    | hot         |
    | votes       |
    | activity    |
    | unanswered  |
