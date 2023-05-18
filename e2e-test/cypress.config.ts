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
    baseUrl: "http://localhost:7007",
    // baseUrl: "https://showcase.janus-idp.io/",
    specPattern: "cypress/e2e/**/*.spec.ts",
  },
});
