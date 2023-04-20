import "@interactors/with-cypress";
import {
  Button,
  Page,
  TextField,
  Heading,
  Link,
  Select,
  Details,
} from "@interactors/html";
// load the global Cypress types
/// <reference types="cypress" />

/**
 * Adds custom command "cy.login" to the global "cy" object
 *
 * @example cy.login()
 */
Cypress.Commands.add("login", () => {
  cy.visit("/");
  cy.expect(Heading("Settings").exists);
  cy.do(Heading("Settings").click());
  cy.expect(Button("AUTHENTICATION PROVIDERS").exists());
  cy.do(Button("AUTHENTICATION PROVIDERS").click());
  cy.visit("/");
});
