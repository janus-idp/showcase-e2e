import { defineConfig } from "cypress";

export default defineConfig({
  video: true,
  videoUploadOnPasses: true,
  screenshotOnRunFailure: true,
  defaultCommandTimeout: 5000,
  viewportWidth: 1000,
  viewportHeight: 600,
  e2e: {
    defaultCommandTimeout: 10000,
    // We've imported your old cypress plugins here.
    // You may want to clean this up later by importing these.
    setupNodeEvents(on, config) {
      return require("./cypress/plugins/index.js")(on, config);
    },
    baseUrl: "http://localhost:7007",
    specPattern: "cypress/e2e/**/*.spec.*",
  },
});
