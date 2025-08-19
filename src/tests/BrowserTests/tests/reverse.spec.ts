import { test, expect } from '@playwright/test';

test('index.html reverses string via API', async ({ page }) => {
  await page.goto('/'); // served by UseDefaultFiles + UseStaticFiles
  await page.fill('#inputBox', 'hello');
  await page.click('#button');
  await expect(page.locator('#result')).toHaveText('Result: olleh', { timeout: 5000 });
});