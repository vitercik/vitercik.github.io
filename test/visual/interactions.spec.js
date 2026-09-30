const { test, expect } = require("@playwright/test");
const { preparePage, openPage, attachScreenshot } = require("./helpers");

test.beforeEach(async ({ page }, testInfo) => {
  await preparePage(page, testInfo.project.use.colorScheme);
});

test("navigation opens the research page", async ({ page, isMobile }, testInfo) => {
  await openPage(page, "/");
  const navbar = page.locator("#navbar");
  const researchLink = navbar.getByRole("link", { name: "research", exact: true });
  if (isMobile) {
    const toggle = navbar.getByRole("button", { name: "Toggle navigation" });
    await expect(researchLink).toBeHidden();
    await toggle.click();
    await expect(toggle).toHaveAttribute("aria-expanded", "true");
    await expect(researchLink).toBeVisible();
    await attachScreenshot(page, testInfo, "navigation-expanded", false);
    await toggle.click();
    await expect(researchLink).toBeHidden();
    await toggle.click();
  }
  await researchLink.click();
  await expect(page).toHaveURL(/\/research\/$/);
  await expect(page.getByRole("heading", { level: 1, name: "research", exact: true })).toBeVisible();
});

test("theme control changes appearance and persists after reload", async ({ page, isMobile }, testInfo) => {
  await openPage(page, "/");
  if (isMobile) {
    await page.getByRole("button", { name: "Toggle navigation" }).click();
  }
  const target = testInfo.project.use.colorScheme === "light" ? "dark" : "light";
  const before = await page.locator("body").evaluate((body) => getComputedStyle(body).backgroundColor);
  const toggle = page.getByRole("button", { name: "Change color theme" });
  // Dark -> system can preserve dark appearance; a second click reaches light.
  for (let attempt = 0; attempt < 3 && (await page.locator("html").getAttribute("data-theme")) !== target; attempt++) {
    await toggle.click();
  }
  await expect(page.locator("html")).toHaveAttribute("data-theme", target);
  const after = await page.locator("body").evaluate((body) => getComputedStyle(body).backgroundColor);
  expect(after).not.toBe(before);
  await page.reload({ waitUntil: "load" });
  await expect(page.locator("html")).toHaveAttribute("data-theme", target);
});

test("publication filtering narrows results and clearing restores them", async ({ page }, testInfo) => {
  await openPage(page, "/publications/");
  const entries = page.locator(".publications .bibliography > li");
  const allCount = await entries.count();
  expect(allCount).toBeGreaterThan(1);
  const title = (await entries.first().locator(".title").innerText()).trim();
  const filter = page.getByPlaceholder("Type to filter");
  await filter.fill(title);
  await expect(entries.filter({ visible: true })).toHaveCount(1);
  await expect(entries.filter({ visible: true }).first()).toContainText(title);
  await attachScreenshot(page, testInfo, "publications-filtered", false);
  await filter.fill("");
  await expect(entries.filter({ visible: true })).toHaveCount(allCount);
});

test("awards filters and search update the table", async ({ page }, testInfo) => {
  await openPage(page, "/awards/");
  await expect(page.getByRole("heading", { level: 1, name: "Awards for PhD students & postdocs" })).toBeVisible();
  const rows = page.locator("#body tr");
  const allCount = await rows.count();
  expect(allCount).toBeGreaterThan(1);
  await page.locator("#f-type").getByRole("button", { name: "Fellowship", exact: true }).click();
  await expect.poll(() => rows.count()).toBeLessThan(allCount);
  expect(await rows.count()).toBeGreaterThan(0);
  for (const row of await rows.all()) {
    await expect(row.locator("td").nth(2)).toHaveText("Fellowship");
  }
  await page.locator("#f-type").getByRole("button", { name: "All", exact: true }).click();
  await expect(rows).toHaveCount(allCount);
  const firstAward = (await rows.first().locator("a.prog").innerText()).replace(/\s*↗$/, "").trim();
  const search = page.getByPlaceholder("Search…");
  await search.fill(firstAward);
  await expect(rows).toHaveCount(1);
  await expect(rows.first()).toContainText(firstAward);
  await attachScreenshot(page, testInfo, "awards-filtered", false);
  await search.fill("");
  await expect(rows).toHaveCount(allCount);
});
