@Question

Feature: Displaying question counters

  In order to know which questions are interesting
  As a user
  I want to see the vote, answer and view count for each question

  Scenario: Root page
    Given there are different questions
    When I visit root page
    Then I should see valid counters with correct pluralization

  Scenario: Questions page
    Given there are different questions
    When I visit questions page
    Then I should see valid counters with correct pluralization
