// ***********************************************************
// This example support/e2e.js is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

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
});
