# PostQode Collections

This repository is a collection of high-quality **Skills**, **Rules**, and **Workflows** designed to supercharge your AI agent's capabilities within PostQode.

Each directory represents a specialized system or skill that can be loaded into your agent's context to help with specific tasks.

## 📚 Available Systems & Skills

### 1. Web Automation Pro (`web-automation-pro-skill`)
**Purpose:** Master web exploration and automation.
- **Capabilities:**
    - Smart navigation using built-in browser tools.
    - **Recording Mode:** Converts manual web interactions into production-quality Playwright test code.
    - **Exploration Mode:** For general web tasks and data extraction.
    - Falls back to `chrome-devtools` only when necessary.
- **Key Guide:** [SKILL.md](web-automation-pro-skill/SKILL.md)

### 2. Playwright Best Practices (`playwright-best-practices`)
**Purpose:** Comprehensive guide for writing, debugging, and maintaining Playwright tests.
- **Features:**
    - Activity-based reference guides (Writing, Debugging, Mobile, API, etc.).
    - Decision trees for choosing the right testing approach.
    - Best practices for locators, assertions, and test organization.
- **Key Guide:** [SKILL.md](playwright-best-practices/SKILL.md)

### 3. MCP Builder (`mcp-builder`)
**Purpose:** A guide for creating high-quality Model Context Protocol (MCP) servers.
- **Use Case:** When you need to build tools that let LLMs interact with external APIs or services.
- **Process:** Covers Deep Research, Implementation (Python/Node), Testing, and Evaluation.
- **Key Guide:** [SKILL.md](mcp-builder/SKILL.md)

### 4. Skill Creator (`skill-creator`)
**Purpose:** Meta-skill for creating *new* skills like the ones in this repo.
- **Methodology:** Teaches the "Progressive Disclosure" design principle for context efficiency.
- **Structure:** Explains how to organize `SKILL.md`, `scripts/`, `references/`, and `assets/`.
- **Key Guide:** [SKILL.md](skill-creator/SKILL.md)

### 5. API Performance Pro (`api-performance-pro`)
**Purpose:** Systems for high-performance API testing and load testing (k6, JMeter, Locust).
- **Contains:**
    - **Rules:** Guidelines for JMeter usage, load model selection, and metric validation.
    - **Workflows:** Step-by-step guides for running API performance tests and scaling them.
    - **References:** Script templates for k6/JMeter/Locust and **minimum infrastructure requirements** (CPU, RAM, network, distributed testing) for the execution environment.
- **Location:** `api-performance-pro/.postqode/`

### 6. Mobile Performance Pro (`mobile-performance-pro`)
**Purpose:** Intent-driven mobile app performance profiling, framework generation, and CI/CD integration.
- **Contains:**
    - **Rules:** Metric thresholds (launch, FPS, memory, battery, crash/ANR, backend), profiling guidelines, device coverage + compatibility testing, test naming conventions.
    - **Workflows:** `/mobile-performance` (Strategize → Classify → Baseline → Framework Generation) and `/mobile-performance-deep` (Endurance, Network, Stress, CI/CD, Server-Side, Post-Release Monitoring).
    - **References:** ADB/Xcode profiling commands, Maestro/Appium/Apptim CLI templates, device matrix, framework selection guide (app type → right tool), post-release monitoring (Firebase Perf, MetricKit, Android Vitals), infrastructure requirements.
- **Key Feature:** Classifies app type (Native/React Native/Flutter/Hybrid/PWA) and generates the right performance testing framework — scripts, CI/CD pipelines, and monitoring setup.
- **Location:** `mobile-performance-pro/.postqode/`

### 7. Web Performance Pro (`web-performance-pro`)
**Purpose:** Intent-driven web application performance auditing, load testing, and framework generation.
- **Contains:**
    - **Rules:** Core Web Vitals thresholds (LCP, INP, CLS), supplementary metrics (TTFB, FCP, TBT, TTI), backend thresholds (p90, RPS, error rate), testing guidelines (environment parity, lab vs field), browser coverage matrix, test naming conventions.
    - **Workflows:** `/web-performance` (Strategize → Classify → Audit → Generate Framework → Monitor) and `/web-performance-deep` (Load, Stress, Spike, Soak, Hybrid, CI/CD Gates, Backend Pairing, Production Monitoring).
    - **References:** Lighthouse CLI + CI templates, k6/k6-browser hybrid testing, Playwright Performance APIs, WebPageTest deep analysis, framework selection guide (SPA/SSR/SSG/MPA/PWA → right tools), production monitoring (RUM + Synthetic), infrastructure requirements.
- **Key Feature:** Classifies app type and generates the right performance testing framework. Agent generates scripts/configs — user executes in their environment — agent analyzes results.
- **Location:** `web-performance-pro/.postqode/`

### 8. Setup Demo App (`setup-demo-app`)
**Purpose:** Quickly scaffold a minimal Vite + React + Tailwind demo app.
- **Use Case:** Perfect for quick UI experiments or creating reproduction cases.
- **Stack:** Vite, React, TypeScript, Tailwind CSS (using `@tailwindcss/vite`).
- **Key Guide:** [SKILL.md](setup-demo-app/SKILL.md)

## 🚀 How to Use

### Project-Specific Setup

To activate these skills, rules, and workflows in your specific project:

1.  Create a `.postqode` directory in the root of your workspace.
2.  Inside `.postqode`, create subdirectories for `rules`, `workflows`, and `skills` as needed.
3.  Copy the content from this repository into the respective folders.

For example:
- Copy the `web-automation-pro` directory into your `.postqode/skills/` folder to enable it as a **Workspace Skill**.
- Copy rule files into your `.postqode/rules/` folder.

Once placed, these will be automatically recognized by PostQode as **Workspace Rules, Workflows, and Skills**.

### Global Configuration

You can also add these as **Global Objects** to make them available across all your projects.

For detailed configuration guides, please refer to the official documentation:
👉 [https://docs.postqode.ai/](https://docs.postqode.ai/)

## Repository Structure

```
.
├── api-performance-pro/       # API Load Testing Rules & Workflows
├── mobile-performance-pro/    # Mobile App Performance Profiling & Testing
├── mcp-builder/               # MCP Server Development Guide
├── playwright-best-practices/ # Playwright Testing Guide
├── setup-demo-app/            # Quick React App Scaffolder
├── skill-creator/             # Guide for Building New Skills
├── web-automation-pro/        # Web Automation & Recording Skill
├── web-performance-pro/       # Web App Performance Auditing & Load Testing
└── README.md                  # This file
```

## 🤝 Note on Origins & Customization

While some systems and skills in this repository (such as `playwright-best-practices` and `mcp-builder`) are based on excellent public open-source repositories, they have been **significantly improvised, adapted, and extended** to fit specific project workflows and requirements.

Original credits go to their respective authors (e.g., [currents.dev](https://currents.dev) for Playwright Best Practices). The modifications here represent my specific implementations and enhancements.
