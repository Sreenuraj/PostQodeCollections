#!/bin/bash
# Web Automation Pro — Framework Setup Script
# Usage: bash setup-framework.sh <framework> [base-url]
#
# Supported frameworks: playwright, cypress, selenium-python, selenium-java
# Example: bash setup-framework.sh playwright http://localhost:3000

set -e

FRAMEWORK="${1:-playwright}"
BASE_URL="${2:-http://localhost:3000}"

echo "🚀 Setting up $FRAMEWORK for web automation..."

case "$FRAMEWORK" in
  playwright)
    echo "📦 Installing Playwright..."
    [ ! -f package.json ] && npm init -y
    npm install -D @playwright/test
    npx playwright install chromium

    echo "📁 Creating directory structure..."
    mkdir -p tests/pages tests/fixtures

    echo "⚙️  Creating playwright.config.ts..."
    cat > playwright.config.ts << 'EOF'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: process.env.BASE_URL || 'BASE_URL_PLACEHOLDER',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});
EOF
    sed -i.bak "s|BASE_URL_PLACEHOLDER|$BASE_URL|g" playwright.config.ts && rm -f playwright.config.ts.bak

    echo "✅ Playwright setup complete!"
    echo "   Run tests: npx playwright test"
    echo "   Interactive: npx playwright test --ui"
    ;;

  cypress)
    echo "📦 Installing Cypress..."
    [ ! -f package.json ] && npm init -y
    npm install -D cypress typescript

    echo "📁 Creating directory structure..."
    mkdir -p cypress/e2e cypress/fixtures cypress/support cypress/pages

    echo "⚙️  Creating cypress.config.ts..."
    cat > cypress.config.ts << EOF
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: '$BASE_URL',
    specPattern: 'cypress/e2e/**/*.cy.{ts,js}',
    supportFile: 'cypress/support/e2e.ts',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: false,
    screenshotOnRunFailure: true,
  },
});
EOF

    echo "✅ Cypress setup complete!"
    echo "   Run tests: npx cypress run"
    echo "   Interactive: npx cypress open"
    ;;

  selenium-python)
    echo "📦 Installing Selenium (Python)..."
    pip install selenium pytest webdriver-manager pytest-html

    echo "📁 Creating directory structure..."
    mkdir -p tests/pages tests/test_data

    echo "⚙️  Creating conftest.py..."
    cat > tests/conftest.py << EOF
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

@pytest.fixture
def driver():
    options = webdriver.ChromeOptions()
    options.add_argument('--headless=new')
    options.add_argument('--window-size=1280,720')
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    yield driver
    driver.quit()

@pytest.fixture
def base_url():
    return "$BASE_URL"
EOF

    echo "✅ Selenium (Python) setup complete!"
    echo "   Run tests: pytest tests/ -v"
    ;;

  selenium-java)
    echo "📦 Setting up Selenium (Java + Maven)..."
    mkdir -p src/test/java/pages src/test/java/base src/test/java/tests

    if [ ! -f pom.xml ]; then
      echo "⚙️  Creating pom.xml..."
      cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.automation</groupId>
    <artifactId>web-tests</artifactId>
    <version>1.0-SNAPSHOT</version>
    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.seleniumhq.selenium</groupId>
            <artifactId>selenium-java</artifactId>
            <version>4.20.0</version>
        </dependency>
        <dependency>
            <groupId>io.github.bonigarcia</groupId>
            <artifactId>webdrivermanager</artifactId>
            <version>5.8.0</version>
        </dependency>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.2</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
EOF
    fi

    echo "✅ Selenium (Java) setup complete!"
    echo "   Run tests: mvn test"
    ;;

  *)
    echo "❌ Unknown framework: $FRAMEWORK"
    echo "   Supported: playwright, cypress, selenium-python, selenium-java"
    exit 1
    ;;
esac

echo ""
echo "🎯 Framework '$FRAMEWORK' is ready. Base URL: $BASE_URL"
