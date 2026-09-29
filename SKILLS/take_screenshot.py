from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time

def main():
    options = Options()
    # We don't need to set special options because we are connecting to an already running instance
    # But sometimes explicit ones help.
    
    driver = webdriver.Remote(
        command_executor='127.0.0.1:9222',
        options=options
    )

    try:
        print("Navigating to google.com...")
        driver.get("https://www.google.com")
        time.sleep(3)

        print("Taking screenshot...")
        screenshot_path = "google_snapshot.png"
        driver.save_screenshot(screenshot_path)
        print(f"Screenshot saved as {screenshot_path}")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        driver.quit()

if __name__ == "__main__":
    main()
