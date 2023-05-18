import {
  Heading,
  // Button,
  // Page,
  // TextField,
  // Link,
  // Select,
  // Details,
} from "@interactors/html";

describe("Home Page test", () => {
  beforeEach(() => {
    cy.login();
  });

  it("should have the expected links in side bar", () => {
    cy.expect([Heading("Home").exists(), Heading("Search").exists()]);
    cy.do(Heading("Home").click());
  });
});
