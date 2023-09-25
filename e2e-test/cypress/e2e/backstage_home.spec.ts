import {
  Heading,
  Button,
  // Page,
  // TextField,
  // Link,
  // Select,
  // Details,
} from "@interactors/html";

describe("Sign-in Page test", () => {
  beforeEach(() => {
    cy.login();
  });

  it("should have the expected sign-in methods", () => {
    cy.expect([
      Heading("Red Hat Developer Hub").exists(),
      Heading("Select a sign-in method").exists(),
    ]);
    cy.expect([Button("ENTER").exists(), Button("SIGN IN").exists()]);
    cy.do(Button("SIGN IN").click());
  });

  it("should have the expected links in side bar", () => {
    cy.expect([
      Heading("Home").exists(),
      Heading("Search").exists(),
      Heading("Catalog").exists(),
    ]);
    cy.do(Heading("Catalog").click());
  });
});
