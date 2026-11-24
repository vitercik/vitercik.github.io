const path = require("path");
const { devices } = require("@playwright/test");

const baseURL = process.env.VISUAL_BASE_URL || "http://127.0.0.1:4000";

module.exports = {
  testDir: __dirname,
  timeout: 60000,
  expect: { timeout: 10000 },
  forbidOnly: Boolean(process.env.CI),
  workers: process.env.CI ? 2 : undefined,
  outputDir: path.resolve(__dirname, "../../output/playwright/results"),
  reporter: [["list"], ["html", { outputFolder: path.resolve(__dirname, "../../output/playwright/report"), open: "never" }]],
  use: {
    baseURL,
    screenshot: "only-on-failure",
    trace: "retain-on-failure",
  },
  webServer: process.env.NO_WEBSERVER
    ? undefined
    : {
        command: 'bundle exec jekyll build --baseurl "" && python3 -m http.server 4000 --bind 127.0.0.1 --directory _site',
        cwd: path.resolve(__dirname, "../.."),
        env: { JEKYLL_ENV: "production" },
        url: baseURL,
        reuseExistingServer: false,
        timeout: 300000,
      },
  projects: ["light", "dark"].flatMap((colorScheme) => [
    {
      name: `desktop-${colorScheme}`,
      use: { ...devices["Desktop Chrome"], viewport: { width: 1366, height: 1000 }, colorScheme },
    },
    {
      name: `mobile-${colorScheme}`,
      use: { ...devices["iPhone 12"], colorScheme },
    },
  ]),
};
