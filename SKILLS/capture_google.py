from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time

def take_snapshot():
    # Create options object because Selenium 4 requires it in Remote(command_executor=...)
    options = Options()
    driver = webdriver.Remote(command_executor='127.0.0.1:9222', options=options)
    print("Connected to Chrome on 127.0.0.1:9222")
    
    # Navigate to Google
    driver.get("https://www.google.com")
    time.sleep(3)  # Wait for page load
    
    # Save the snapshot
    driver.save_screenshot("google_snapshot.png")
    print("Snapshot successfully saved as google_snapshot.png")
    
    driver.quit()

if __name__ == "__main__":
    take_snapshot()
