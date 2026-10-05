const { test, expect } = require("@playwright/test");
const { preparePage, openPage, attachScreenshot } = require("./helpers");

const routes = [
  { path: "/", title: "Ellen Vitercik", id: "home" },
  { path: "/research/", title: "research", id: "research" },
  { path: "/publications/", title: "publications", id: "publications" },
  { path: "/group/", title: "group", id: "group" },
  { path: "/talks/", title: "talks", id: "talks" },
  { path: "/tutorials/", title: "tutorials", id: "tutorials" },
  { path: "/teaching/", title: "teaching", id: "teaching" },
  { path: "/bio/", title: "bio", id: "bio" },
  { path: "/faq/", title: "FAQ", id: "faq" },
];

for (const route of routes) {
  test(`${route.id}: production content and responsive layout`, async ({ page }, testInfo) => {
    const errors = [];
    page.on("pageerror", (error) => errors.push(error.message));
    await preparePage(page, testInfo.project.use.colorScheme);
    await openPage(page, route.path);

    const main = page.getByRole("main");
    const heading = main.getByRole("heading", { level: 1, name: route.title, exact: true });
    await expect(main).toBeVisible();
    await expect(heading).toBeVisible();
    await expect(page.locator("html")).toHaveAttribute("data-theme", testInfo.project.use.colorScheme);
    await expect(page.locator("#navbar")).toBeVisible();

    const layout = await page.evaluate(() => {
      const heading = document.querySelector('[role="main"] h1');
      const navbar = document.querySelector("#navbar");
      const main = document.querySelector('[role="main"]');
      return {
        viewportWidth: document.documentElement.clientWidth,
        documentWidth: document.documentElement.scrollWidth,
        mainLeft: main.getBoundingClientRect().left,
        mainRight: main.getBoundingClientRect().right,
        headingTop: heading.getBoundingClientRect().top,
        navbarBottom: navbar.getBoundingClientRect().bottom,
        headingFontSize: Number.parseFloat(getComputedStyle(heading).fontSize),
      };
    });
    expect(layout.documentWidth, "page must not scroll horizontally").toBeLessThanOrEqual(layout.viewportWidth + 1);
    expect(layout.mainLeft).toBeGreaterThanOrEqual(0);
    expect(layout.mainRight).toBeLessThanOrEqual(layout.viewportWidth + 1);
    expect(layout.headingTop, "fixed navigation must not cover the heading").toBeGreaterThanOrEqual(layout.navbarBottom);
    expect(layout.headingFontSize, "theme typography should be loaded").toBeGreaterThanOrEqual(24);

    if (route.id === "home") {
      const portrait = main.locator(".profile img");
      await expect(portrait).toBeVisible();
      await expect.poll(() => portrait.evaluate((img) => img.complete && img.naturalWidth > 0)).toBe(true);
      await expect(main.getByRole("link", { name: "selected publications", exact: true })).toBeVisible();
      expect(await main.locator(".bibliography > li").count()).toBeGreaterThan(0);
    }

    await attachScreenshot(page, testInfo, route.id);
    expect(errors, "page scripts should load without uncaught errors").toEqual([]);
  });
}
