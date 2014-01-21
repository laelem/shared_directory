Feature: Job list
  In order to manage jobs
  A logged in user
  Should be able to show the job list

  Background:
  Given the following users exist:
    | user@example.com  | foobar   |
    | user2@example.com | foobar2  |
    | user3@example.com | foobar3  |
  Given a user is logged in

    Scenario: User access to the job list
      When a user press the "Jobs" menu link
      Then he should see the job list page

    Scenario: No job present in the list
      Given no job is saved
      When a user press the "Jobs" menu link
      Then he should see a message saying no "job" is present

    Scenario: Many jobs present in the list
      Given the following jobs exist:
        | Developer web | true  |
        | Confectioner  | false |
        | Magician      | false |
      When a user press the "Jobs" menu link
      Then he should see the existing jobs
      And the non active jobs should be grayed