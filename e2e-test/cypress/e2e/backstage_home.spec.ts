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
    cy.expect([Heading("Home").exists(), Heading("Catalog").exists()]);
    cy.do(Heading("Home").click());
  });
});
