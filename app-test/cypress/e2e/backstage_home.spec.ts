import {
  Button,
  Page,
  TextField,
  Heading,
  Link,
  Select,
  Details,
} from "@interactors/html";

describe("Home Page test", () => {
  beforeEach(() => {
    cy.login();
  });

  it("should have the expected links in side bar", async () => {
    cy.expect([
      Heading("Search").exists(),
      Heading("Home").exists(),
      Heading("APIs").exists(),
      Heading("Docs").exists(),
      Heading("Tech Radar").exists(),
      Heading("Settings").exists(),
    ]);

    cy.do(Heading("Home").click());

    cy.expect(Heading("My Company Catalog").exists());
    cy.contains("Janus IDP Catalog").should("be.visible");
  });
});
