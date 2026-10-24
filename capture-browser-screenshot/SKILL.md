---
name: capture-browser-screenshot
description: Capture browser screenshots using the bundled Selenium helpers. Use when asked to take a website screenshot; the existing helpers specifically navigate to Google and save google_snapshot.png.
---

# Capture Browser Screenshot

Confirm the requested page and destination. Use the configured Python environment with `selenium` installed, following the project's dependency conventions.

## Bundled Helpers

- [scripts/take_screenshot.py](scripts/take_screenshot.py): navigates to Google, waits three seconds, and saves `google_snapshot.png` in the current working directory. Attempts browser cleanup in a `finally` block.
- [scripts/capture_google.py](scripts/capture_google.py): performs the same capture with a simpler flow; cleanup occurs only after a successful capture.

Both helpers currently pass `127.0.0.1:9222` to Selenium's `webdriver.Remote`. Inspect the actual browser service before running them: a Chrome debugging port is not itself a Selenium WebDriver endpoint. Configure a valid WebDriver connection or an explicit Chrome debugger attachment as appropriate, and verify any code changes before use.

The URL, output filename, and wait duration are hardcoded. Adapt them when the requested capture differs. Choose a working directory where the output will not overwrite an unrelated screenshot. Run the selected helper with the configured Python executable and its resolved script path.

Verify that the output image exists and inspect it before reporting success. A helper may print an error without returning a failing exit status, so exit status alone is insufficient.

Best: confirm the browser connection, capture the requested page, and inspect the saved image. Avoid: treating Chrome's debugging endpoint as a Selenium server or reporting success from printed output alone.
