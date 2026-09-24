import asyncio
from playwright.async_api import async_playwright

async def run_e2e_test():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()

        print("--- 1. Navigating to root / #/login ---")
        await page.goto("http://localhost:8080/#/login")
        await page.wait_for_timeout(1000)

        # Check sidebar is hidden on login page
        sidebar_visible = await page.is_visible("aside")
        print(f"Is sidebar visible on login page? {sidebar_visible}")
        assert not sidebar_visible, "Sidebar should be hidden on login page"

        print("--- 2. Performing Login with isaac / 123 ---")
        await page.fill("input[placeholder*='isaac']", "isaac")
        await page.fill("input[type='password']", "123")
        await page.click("button[type='submit']")

        await page.wait_for_timeout(1500)
        current_url = page.url
        print(f"Current URL after login: {current_url}")
        assert "#/dashboard" in current_url, "User should be redirected to #/dashboard"

        # Check sidebar is visible after login
        sidebar_visible = await page.is_visible("aside")
        print(f"Is sidebar visible after login? {sidebar_visible}")
        assert sidebar_visible, "Sidebar should be visible after login"

        print("--- 3. Navigating through Navigation Menus ---")
        menus = [
          ("#/turmas", "Turmas"),
          ("#/matriculas", "Matrículas"),
          ("#/frequencia", "Frequência"),
          ("#/alunos", "Alunos"),
          ("#/professores", "Professores"),
          ("#/modalidades", "Modalidades"),
          ("#/relatorios", "Relatórios")
        ]

        for route, name in menus:
            print(f"Testing navigation to {name} ({route})...")
            await page.click(f"aside nav a[href='{route}']")
            await page.wait_for_timeout(500)
            assert route in page.url, f"Failed to navigate to {route}"
            print(f"Successfully reached {route}")

        print("--- 4. Testing Logout ---")
        await page.click("button[title='Encerrar sessão']")
        await page.wait_for_timeout(1000)
        print(f"URL after logout: {page.url}")
        assert "#/login" in page.url, "User should be redirected to #/login on logout"

        print("\nAll UI integration and navigation tests passed successfully!")
        await browser.close()

if __name__ == "__main__":
    asyncio.run(run_e2e_test())
