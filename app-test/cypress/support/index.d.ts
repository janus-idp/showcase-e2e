// describe custom Cypress commands in this file

// load the global Cypress types
/// <reference types="cypress" />

declare namespace Cypress {
  interface Chainable {
    /**
     * Custom command to setup login.
     * @example cy.login()
     */
    login(): Chainable<Element>;
  }
}
