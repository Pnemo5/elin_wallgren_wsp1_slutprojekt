import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('localhost:9292');
  await page.getByLabel('Användarnamn:').fill("Elin");
  await page.getByLabel('Lösenord:').fill("123");

  await page.getByRole("button").click();

  await expect(page.getByText('Alla böcker du har läst!')).toBeVisible();
});

test('get started link', async ({ page }) => {
  await page.goto('https://playwright.dev/');

  // Click the get started link.
  await page.getByRole('link', { name: 'Get started' }).click();

  // Expects page to have a heading with the name of Installation.
  await expect(page.getByRole('heading', { name: 'Installation' })).toBeVisible();
});
