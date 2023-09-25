import { defineConfig } from "cypress";

export default defineConfig({
  video: true,
  videoUploadOnPasses: true,
  screenshotOnRunFailure: true,
  // These settings apply everywhere unless overridden
  defaultCommandTimeout: 5000,
  viewportWidth: 1000,
  viewportHeight: 600,
  // Viewport settings overridden for component tests
  component: {
    viewportWidth: 500,
    viewportHeight: 500,
  },
  // Command timeout overridden for E2E tests
  e2e: {
    defaultCommandTimeout: 10000,
    baseUrl:
      "https://backstage-showcase.backstage-os-eu-de-2-bx2-c74b3ed44ce86949f501aefb2db80652-0000.eu-de.containers.appdomain.cloud",
    specPattern: "cypress/e2e/**/*.spec.ts",
  },
});
