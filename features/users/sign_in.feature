Feature: Sign in
  In order to get access to protected sections of the site
  A user
  Should be able to sign in

  Background:
  Given the following users exist:
    | user@example.com  | foobar   |
    | user2@example.com | foobar2  |
    | user3@example.com | foobar3  |

    Scenario: User access to the sign in form
      Given a user is not logged in
      When he visits the home page
      Then he should see the sign in form

    Scenario: Access forbidden to the sign in form for logged in users
      Given a user is logged in
      When he visits the home page
      Then he should not see the sign in form

    Scenario Outline: User submits sign in form with invalid information
      Given a user is not logged in
      When he visits the home page
      And he enters "<email>" in the email field
      And he enters "<password>" in the password field
      And he press the sign in button
      Then he should see the error message: "<message>"
      And he should not be logged in

    Scenarios:
      | email             | password      | message                            |
      |                   |               | Email and password can't be blank  |
      |                   | a             | Email can't be blank               |
      | a                 |               | Password can't be blank            |
      | a                 | a             | Email is invalid                   |
      | wrong@example.com | wrongpassword | Invalid email/password combination |
      | user@example.com  | wrongpassword | Invalid email/password combination |

    Scenario: User sign in sucessfully
      Given a user is not logged in
      When he visits the home page
      And he enters "user@example.com" in the email field
      And he enters "foobar" in the password field
      And he press the sign in button
      Then he should be logged in
