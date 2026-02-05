# Developer MCP Tools Strategy for Project Chimera

**Date:** 2026-02-04  
**Purpose:** Configured MCP (Model Context Protocol) servers for development workflow enhancement

---

## Executive Summary

This document describes the configured MCP servers that enhance the development workflow for Project Chimera. These tools provide AI-assisted capabilities for version control, filesystem operations, and browser testing.

**Note:** These are *developer tools* MCPs (for your development environment), distinct from the *runtime MCPs* used by Chimera agents for external platform integrations (Twitter, Instagram, Coinbase, etc.).

---

## Configured MCP Servers

The following 4 MCP servers are configured in `.mcp.json`:

1. **Git MCP** - Local version control operations
2. **GitHub MCP** - Remote repository management
3. **Filesystem MCP** - Safe file operations
4. **Playwright MCP** - Browser automation and testing

---

## 1. Git MCP

### What It Is

Git MCP provides AI-assisted local version control operations. It allows the AI to interact with your Git repository directly, reading history, analyzing changes, creating commits, and managing branches.

### Why It's Needed

**Problem:** Manual Git operations can be time-consuming and error-prone. Writing meaningful commit messages, resolving merge conflicts, and tracking changes across commits requires context that AI can provide.

**Solution:** Git MCP enables natural language interactions with your repository. Instead of manually crafting commit messages or analyzing diffs, you can ask the AI to handle these tasks with full context of your codebase.

### When It's Used

#### Example 1: Creating Context-Aware Commits
**Scenario:** You've made changes to multiple files implementing a new feature.

**Without Git MCP:**
```bash
git add .
git commit -m "Add feature"  # Generic, unhelpful message
```

**With Git MCP:**
- You: "Create a commit for these changes with an appropriate message"
- AI reads all changed files, understands the context, and creates:
  ```
  feat: implement Planner service task decomposition
  
  - Add TaskDAG builder with dependency resolution
  - Implement parallel task execution support
  - Add OCC conflict detection for concurrent workers
  - Update technical spec with new task schema
  ```

#### Example 2: Analyzing Code Changes
**Scenario:** You want to understand what changed in the last few commits.

**Without Git MCP:**
```bash
git log --oneline  # Manual inspection
git diff HEAD~3    # Manual diff reading
```

**With Git MCP:**
- You: "Show me what changed in the last 3 commits related to the Judge service"
- AI analyzes commits, filters by relevance, and explains:
  - "The last 3 commits modified the Judge service to add confidence scoring. Changes include..."
  - Shows specific file changes with context

#### Example 3: Resolving Merge Conflicts
**Scenario:** You have merge conflicts after pulling from main.

**Without Git MCP:**
- Manually open each conflicted file
- Read both versions
- Decide which to keep
- Manually resolve

**With Git MCP:**
- You: "Help me resolve this merge conflict in `chimera/orchestrator.py`"
- AI reads both versions, understands the codebase context, suggests resolution, and explains why

#### Example 4: Branch Management
**Scenario:** You need to create a feature branch and understand what's different from main.

**With Git MCP:**
- You: "Create a new branch called 'mcp-integration' and show me what files differ from main"
- AI creates the branch and provides a diff summary

---

## 2. GitHub MCP

### What It Is

GitHub MCP provides programmatic access to GitHub repositories, issues, pull requests, and workflows. It enables AI-assisted collaboration and repository management.

### Why It's Needed

**Problem:** GitHub operations often require context switching between your IDE and the browser. Creating PRs, managing issues, and monitoring CI/CD requires manual navigation and repetitive tasks.

**Solution:** GitHub MCP brings GitHub operations into your development workflow. The AI can create PRs, manage issues, check workflow status, and provide context-aware assistance.

### When It's Used

#### Example 1: Creating Pull Requests
**Scenario:** You've completed a feature and want to create a PR.

**Without GitHub MCP:**
1. Push branch to GitHub
2. Open browser
3. Navigate to repository
4. Click "New Pull Request"
5. Fill in title and description manually
6. Select reviewers
7. Create PR

**With GitHub MCP:**
- You: "Create a PR for the current branch with a description based on the commits"
- AI:
  - Analyzes your commits
  - Generates PR title and description
  - Creates the PR
  - Suggests reviewers based on changed files

#### Example 2: Issue Management
**Scenario:** You want to find issues related to your current work.

**With GitHub MCP:**
- You: "Show me open issues related to MCP integration"
- AI searches issues, filters by relevance, and presents:
  - Issue #42: "Add MCP server configuration"
  - Issue #55: "Document MCP setup process"
  - Provides summaries and links

#### Example 3: CI/CD Monitoring
**Scenario:** You want to check if your latest push passed tests.

**Without GitHub MCP:**
- Open browser
- Navigate to Actions tab
- Find your workflow run
- Check status

**With GitHub MCP:**
- You: "Check the status of the latest GitHub Action run"
- AI reports: "The latest workflow run for commit abc123 passed all tests. 3 jobs completed successfully in 4m 32s."

#### Example 4: Code Review Assistance
**Scenario:** Someone commented on your PR asking about a specific change.

**With GitHub MCP:**
- You: "Add a comment to PR #42 explaining why we used OCC for conflict detection"
- AI reads the PR context, understands the question, and posts an informed response

---

## 3. Filesystem MCP

### What It Is

Filesystem MCP provides safe, controlled access to your project's file system. It allows the AI to read, write, and navigate files within configured boundaries.

### Why It's Needed

**Problem:** AI needs to read and modify files, but unrestricted file access is a security risk. You want AI assistance with file operations while maintaining safety boundaries.

**Solution:** Filesystem MCP provides configurable access controls. It's scoped to your project directory (`.`), preventing access to system files or sensitive directories outside your workspace.

### When It's Used

#### Example 1: Reading Project Files
**Scenario:** You want the AI to understand your project structure or read a specific file.

**With Filesystem MCP:**
- You: "Read the technical spec file and explain the Planner API"
- AI reads `specs/technical.md`, finds the Planner section, and explains it with context

#### Example 2: Creating New Files
**Scenario:** You want to create a new module following your project's patterns.

**With Filesystem MCP:**
- You: "Create a new module `chimera/judge.py` following the patterns from `chimera/planner.py`"
- AI:
  - Reads `chimera/planner.py` to understand patterns
  - Reads `specs/technical.md` for Judge requirements
  - Creates the new file with proper structure

#### Example 3: Updating Documentation
**Scenario:** You've made code changes and want to update the README.

**With Filesystem MCP:**
- You: "Update the README with the current project status based on what's implemented"
- AI:
  - Scans the codebase
  - Reads current README
  - Updates it with accurate status

#### Example 4: Project Navigation
**Scenario:** You want to understand the project structure.

**With Filesystem MCP:**
- You: "List all Python files in the chimera directory and show me their purposes"
- AI navigates the directory, reads file headers, and provides a structured overview

---

## 4. Playwright MCP

### What It Is

Playwright MCP provides browser automation capabilities for testing web applications. It can interact with web pages, fill forms, click buttons, and verify UI behavior.

### Why It's Needed

**Problem:** Project Chimera will include web-based dashboards (Orchestrator Dashboard, HITL Review Interface). Testing these manually is time-consuming and error-prone. Automated testing ensures reliability.

**Solution:** Playwright MCP enables AI-assisted test creation and execution. You can describe test scenarios in natural language, and the AI generates and runs Playwright tests.

### When It's Used

#### Example 1: Dashboard Testing
**Scenario:** You want to verify the Orchestrator Dashboard loads correctly.

**With Playwright MCP:**
- You: "Test that the orchestrator dashboard login flow works correctly"
- AI:
  - Opens the dashboard URL
  - Fills in login credentials
  - Verifies successful login
  - Checks that the dashboard loads
  - Reports any errors

#### Example 2: UI Component Verification
**Scenario:** You've updated the HITL review interface and want to verify it works.

**With Playwright MCP:**
- You: "Verify that the HITL review interface loads and the approve/reject buttons are clickable"
- AI:
  - Navigates to the review page
  - Checks element visibility
  - Tests button interactions
  - Reports results

#### Example 3: Data Extraction
**Scenario:** You want to extract data from a monitoring page for analysis.

**With Playwright MCP:**
- You: "Extract the agent status data from the monitoring page and format it as JSON"
- AI:
  - Navigates to the page
  - Extracts table/list data
  - Formats and returns structured data

#### Example 4: Visual Regression Testing
**Scenario:** You want to ensure UI changes don't break the layout.

**With Playwright MCP:**
- You: "Take a screenshot of the dashboard and compare it to the baseline"
- AI captures screenshots and can compare them for visual changes

---

## Configuration Details

### File Location

The MCP servers are configured in `.cursor/mcp.json`. This file is shared with the team via version control, ensuring consistent development tooling.

### Configuration Structure

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-name"],
      "env": { /* environment variables if needed */ }
    }
  }
}
```

### Environment Variables

Some MCP servers require environment variables:

- **GitHub MCP:** Requires `GITHUB_PERSONAL_ACCESS_TOKEN` (set this in your environment or `.cursor/mcp.json`)
- **Filesystem MCP:** Scoped to current directory (`.`) for security

### Security Considerations

1. **Filesystem MCP:** Restricted to project directory only (`.`)
2. **GitHub MCP:** Use fine-grained Personal Access Tokens with minimal required permissions

---

## Integration with Project Chimera

### Development Workflow Enhancement

These MCP tools enhance your development workflow by:

1. **Reducing Context Switching:** All operations available in your IDE
2. **Providing Context-Aware Assistance:** AI understands your codebase and project structure
3. **Automating Repetitive Tasks:** Commits, PRs, tests, service management
4. **Enabling Natural Language Interactions:** Describe what you want, not how to do it

### Alignment with Project Architecture

These developer tools complement Project Chimera's architecture:

- **Git/GitHub MCP:** Manages the codebase that implements the hub-and-spoke architecture
- **Filesystem MCP:** Accesses and modifies the codebase following architectural patterns
- **Playwright MCP:** Tests the Orchestrator Dashboard and HITL interfaces

### Spec Compliance

The AI can use these tools to:

- **Read Specs:** Filesystem MCP reads `specs/` directory
- **Verify Compliance:** Compare code changes against `specs/technical.md` and `specs/functional.md`
- **Update Documentation:** Keep README and docs aligned with implementation

---

## Usage Patterns

### Daily Development

1. **Coding:** "Create a commit for these changes" (Git MCP)
2. **Testing:** "Test the dashboard login flow" (Playwright MCP)
3. **File Operations:** "Read the technical spec for the Planner service" (Filesystem MCP)
4. **Collaboration:** "Create a PR for the current branch" (GitHub MCP)

### Feature Development

1. **Planning:** "Read the functional spec for the Planner service" (Filesystem MCP)
2. **Implementation:** "Create the module following patterns from existing code" (Filesystem MCP)
3. **Testing:** "Test the new feature in the dashboard" (Playwright MCP)
4. **Commit:** "Create a commit with an appropriate message" (Git MCP)
5. **PR:** "Create a PR for this feature" (GitHub MCP)

### Debugging Workflow

1. **Identify Issue:** "Read the error logs from the filesystem" (Filesystem MCP)
2. **Test Fix:** "Test the fix in the dashboard" (Playwright MCP)
3. **Commit Changes:** "Create a commit for the fix" (Git MCP)
4. **Create PR:** "Create a PR for this bug fix" (GitHub MCP)

---

## Next Steps

1. **Set Environment Variables:**
   - Create a GitHub Personal Access Token
   - Add it to `.mcp.json` or your environment

2. **Verify Installation:**
   - Ensure Node.js 18+ is installed
   - Restart Cursor IDE to load MCP configuration

3. **Test Each MCP:**
   - Try a simple Git operation
   - Test Filesystem access
   - Test Playwright browser automation
   - Verify GitHub connectivity

4. **Start Using:**
   - Begin with Git and Filesystem MCPs (most frequently used)
   - Gradually incorporate others as needed

---

## References

- [MCP Developer Guide](https://code.visualstudio.com/docs/copilot/guides/mcp-developer-guide)
- [MCP Directory](https://mcpdirectory.app/)
- [GitHub MCP Documentation](https://docs.github.com/en/copilot/how-tos/provide-context/use-mcp/use-the-github-mcp-server)

---

**Status:** ✅ Configured and ready for use
