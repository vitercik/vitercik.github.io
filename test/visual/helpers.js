const { expect } = require("@playwright/test");

async function preparePage(page, theme) {
  await page.addInitScript((setting) => {
    // Preserve changes made by the theme-toggle test across reloads.
    if (!window.localStorage.getItem("theme")) {
      window.localStorage.setItem("theme", setting);
    }
  }, theme);
}

async function openPage(page, route) {
  const response = await page.goto(route, { waitUntil: "load" });
  expect(response.status(), `${route} should be a published page`).toBe(200);
  await page.evaluate(() => document.fonts.ready);
  await page.addStyleTag({
    content: "*, *::before, *::after { animation: none !important; transition: none !important; caret-color: transparent !important; }",
  });
}

async function attachScreenshot(page, testInfo, name, fullPage = true) {
  // Very long publication/awards lists can exceed browser screenshot limits.
  const height = await page.evaluate(() => document.documentElement.scrollHeight);
  const captureFullPage = fullPage && height < 30000;
  await testInfo.attach(`${name}-${captureFullPage ? "full-page" : "viewport"}`, {
    body: await page.screenshot({ fullPage: captureFullPage, animations: "disabled" }),
    contentType: "image/png",
  });
}

module.exports = { preparePage, openPage, attachScreenshot };
