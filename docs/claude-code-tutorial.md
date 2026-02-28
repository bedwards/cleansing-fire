# Claude Code Tutorial

A practical guide for people who have never used Claude Code before.

---

## What Is Claude Code?

Claude Code is an AI assistant that runs in your terminal. It is made by Anthropic and powered by Claude Opus 4.6, one of the most capable AI models in existence.

Think of it as a brilliant colleague who lives in your terminal. You describe what you want in plain English. Claude reads your files, writes code, searches the web, runs commands, and explains what it is doing. It is not a chatbot that gives you text to copy-paste. It is an agent that takes action on your behalf, with your permission, in your actual working environment.

What it can do:

- **Read any file** on your machine -- source code, data files, documentation, configuration
- **Write and edit code** -- it modifies files directly, not just suggests changes
- **Run shell commands** -- build, test, deploy, search, install, whatever you need
- **Search the web** -- find documentation, research topics, look up current information
- **Understand context** -- it reads your project's structure and documentation automatically
- **Remember conversation** -- within a session, it builds on everything discussed so far

For the Cleansing Fire project specifically, Claude Code is the human interface. You learn Claude Code, and Claude handles everything else -- infrastructure setup, running investigations, generating content, coordinating agents, writing plugins.

---

## Installing Claude Code

### macOS and Linux (including WSL)

Open your terminal and run:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

This downloads and installs the Claude Code binary. No Node.js or other dependencies required. The installer handles everything: downloads the right binary for your system architecture, configures your PATH, and sets up auto-updates.

### Windows

**Option 1: PowerShell (recommended)**

```powershell
irm https://claude.ai/install.ps1 | iex
```

**Option 2: CMD**

```batch
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

**Prerequisite:** Windows requires [Git for Windows](https://git-scm.com/downloads/win). Install that first. Claude Code uses Git Bash internally to run commands.

**Option 3: WSL**

If you use Windows Subsystem for Linux, install Claude Code from your Linux terminal using the macOS/Linux command above. WSL 2 is recommended over WSL 1 because it supports sandboxing for enhanced security.

### macOS via Homebrew

```bash
brew install --cask claude-code
```

Note: Homebrew installations do not auto-update. Run `brew upgrade claude-code` periodically.

### Windows via WinGet

```powershell
winget install Anthropic.ClaudeCode
```

### Verify your installation

```bash
claude --version
```

For a more thorough check:

```bash
claude doctor
```

### Setting up authentication

Claude Code requires a paid Anthropic account. The free Claude.ai plan does not include Claude Code access. You need one of:

- **Claude Pro or Max** subscription (through claude.ai)
- **Claude Teams or Enterprise** account (through your organization)
- **Anthropic Console** API key (through console.anthropic.com -- pay per use)

When you run `claude` for the first time, it will open your browser and walk you through authentication. Follow the prompts. If you are using an API key from the Anthropic Console, the setup will ask for it during this process.

---

## Basic Usage

### Starting a session

Open your terminal, navigate to your project directory, and type:

```bash
claude
```

That is it. Claude starts, reads any `CLAUDE.md` file in the current directory (which gives it project context), and waits for your input.

### Talking to Claude

Just type what you want in natural language. No special syntax. No commands to memorize. Examples:

```
What does this project do?
```

```
Find the bug in auth.py that's causing the login failure
```

```
Create a Python script that fetches data from this API
```

```
Explain this function to me like I'm new to programming
```

Press **Enter** to send your message. Press **Shift+Enter** to add a new line without sending (useful for multi-line messages).

### Claude reads files

Claude can read any file on your machine. You can ask it to:

```
Read the README and summarize what this project does
```

```
Look at src/auth.py and explain the authentication flow
```

```
What's in the config.yaml file?
```

You can also reference files directly by path, and Claude will read them.

### Claude edits files

Claude does not just suggest changes -- it makes them, with your permission. When Claude wants to modify a file, it shows you exactly what will change and asks for approval before proceeding.

```
Fix the typo in line 42 of README.md
```

```
Add error handling to the database connection function
```

```
Refactor this function to use async/await
```

### Claude runs commands

Claude can execute shell commands on your machine. It will show you the command before running it and ask for permission.

```
Run the test suite
```

```
Install the requests library with pip
```

```
Show me the git log for the last week
```

When Claude runs a command, you will see the command it wants to execute and can approve or reject it.

### Claude searches the web

Claude can search the internet to find current information:

```
What's the latest version of Python?
```

```
Look up the API documentation for this library
```

```
Find recent news about this company's SEC filings
```

---

## Tips and Tricks

### Be specific about what you want

Good:
```
Create a Python function that takes a list of URLs, fetches each one
concurrently using aiohttp, and returns a dictionary mapping URLs to
their HTTP status codes. Include error handling for timeouts.
```

Less good:
```
Write some code to fetch URLs
```

Claude can work with vague requests, but specificity gets you better results faster.

### Paste error messages directly

When something breaks, paste the full error message into Claude. It will diagnose the problem and fix it:

```
I'm getting this error when I run the tests:

TypeError: expected str, bytes or os.PathLike object, not NoneType
  File "src/loader.py", line 47, in load_config
    with open(config_path) as f:

Can you fix this?
```

### Use built-in commands

Type `/help` during a session to see all available commands. Key ones:

- `/help` -- show available commands
- `/clear` -- clear the conversation and start fresh
- `/compact` -- condense the conversation to save context
- `/config` -- change settings
- `/cost` -- show token usage and cost for the session
- `/status` -- show session status

### Context and memory

Claude remembers everything said within a session. You can build on previous exchanges:

```
[You] Explain the authentication module.

[Claude explains it]

[You] Now add rate limiting to the login endpoint you just described.

[Claude remembers the context and makes targeted changes]
```

When you exit Claude (Ctrl+C or type `/exit`), the session ends. The next time you run `claude`, it starts fresh -- but it reads `CLAUDE.md` again, so it always knows your project context.

To continue your most recent session:

```bash
claude --continue
```

### Multi-line input

Press **Shift+Enter** to add new lines without sending. Useful for pasting code blocks, long descriptions, or structured requests.

### The CLAUDE.md file

If your project has a `CLAUDE.md` file in its root directory, Claude reads it automatically when you start a session. This file tells Claude about the project -- its architecture, conventions, goals, and how things work. In Cleansing Fire, this file is the project's operating manual for Claude.

You do not need to repeat information that is in `CLAUDE.md`. Claude already knows it.

---

## Advanced Usage

### Headless mode: scripting with Claude

The `-p` flag (for "print") runs Claude non-interactively. Send a prompt, get a response, no interactive session. This is how you use Claude in scripts, CI/CD pipelines, and automation.

```bash
# Ask a question and get the answer on stdout
claude -p "What does the auth module do?"

# Get JSON output with metadata
claude -p "Summarize this project" --output-format json

# Stream responses in real time
claude -p "Explain recursion" --output-format stream-json

# Auto-approve specific tools (no permission prompts)
claude -p "Run the test suite and fix any failures" \
  --allowedTools "Bash,Read,Edit"

# Create a commit from staged changes
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

### Continuing conversations

```bash
# Continue the most recent conversation
claude -p "Now focus on the database queries" --continue

# Resume a specific session by ID
claude -p "Continue that review" --resume "$session_id"
```

### Working with git

Claude understands git deeply. You can ask it to:

```
Create a new branch for this feature
```

```
Look at my changes and create a commit with a good message
```

```
Review the diff on this pull request
```

```
Rebase my branch onto main and resolve any conflicts
```

### Custom system prompts

For scripting, you can modify Claude's behavior:

```bash
# Add instructions while keeping default behavior
gh pr diff 123 | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json

# Fully replace the system prompt
claude -p "Analyze this data" \
  --system-prompt "You are a data analyst. Output only JSON."
```

### Structured output

Get machine-parseable responses with JSON schemas:

```bash
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```

---

## For Cleansing Fire Specifically

### Running an investigation

Start Claude in the project directory and describe what you want to investigate:

```bash
cd cleansing-fire
claude
```

Then:

```
I want to investigate defense contractor lobbying. Use the civic plugins
to pull FEC data, cross-reference with USAspending contract data, and
generate a summary with visualizations.
```

Claude knows about the project's plugins (`civic-fec`, `civic-spending`, `civic-legiscan`, `civic-crossref`), the forge tools (`forge-vision`, `forge-voice`), and the full pipeline (`pipeline-data-to-fire`). It will orchestrate them for you.

### Using plugins directly

Plugins are executable scripts that accept JSON on stdin and produce JSON on stdout. You can ask Claude to run them:

```
Run the civic-fec plugin to look up contributions to
Senate candidates from defense industry PACs.
```

```
Use forge-voice to generate a social media thread from
this investigation's findings.
```

```
Run the full data-to-fire pipeline on the Palantir investigation.
```

### Using the gatekeeper for local AI

If you have Ollama running with the gatekeeper daemon, Claude can use local AI for lightweight tasks:

```
Check if the gatekeeper is running and healthy.
```

```
Submit a summarization task to the gatekeeper using fire-ask.
```

```
Set up the gatekeeper daemon on my machine. Walk me through it.
```

### Generating content

The forge plugins produce content from investigation data:

```
Generate an SVG visualization showing the money flow between
these defense contractors and congressional committees.
```

```
Write a newsletter article about what we found in the
FEC data. Use the Pyrrhic Lucidity voice -- direct, sourced,
no performative outrage.
```

```
Create ASCII art showing the corporate ownership chain.
```

### Building new plugins

Ask Claude to help you build:

```
Help me write a new plugin that monitors SEC EDGAR for
insider trading filings. Follow the existing plugin
conventions -- JSON stdin/stdout, executable script,
access to the gatekeeper for LLM tasks.
```

Claude knows the plugin conventions from `CLAUDE.md` and will write code that fits the existing architecture.

### Contributing through Claude Code

The standard workflow for contributing:

```
I want to contribute a fix for issue #42. Walk me through
the git workflow for this project.
```

Claude will:
1. Create a feature branch following the naming convention (`cf/<issue-number>-<description>`)
2. Make the changes
3. Write tests if appropriate
4. Create a commit with a clear message
5. Help you submit a pull request

### Example: a complete investigation session

Here is what a real session might look like:

```
[You] I want to investigate private equity acquisitions in the
nursing home industry. Start with the largest PE firms and their
healthcare portfolios.

[Claude] I'll research the major private equity firms with nursing
home holdings. Let me search for recent acquisitions and cross-
reference with public records...

[Claude searches the web, reads project docs, identifies relevant
data sources]

[You] Good. Now check if any of these firms have lobbied against
staffing requirements or patient safety regulations.

[Claude] I'll use the civic plugins to search lobbying disclosures
and cross-reference with the companies we identified...

[Claude runs civic-fec, civic-spending, civic-crossref]

[You] Generate a visualization of the money flow and a social
media thread summarizing the findings.

[Claude] I'll use forge-vision for the diagram and forge-voice
for the thread...

[Claude generates SVG, writes thread, outputs both]

[You] Write this up as a research document and add it to docs/.

[Claude writes the document, creates a git branch, commits, and
offers to open a pull request]
```

---

## Troubleshooting

### Claude is not recognized as a command

Your PATH may not include the installation directory. Try:

```bash
# Check where it was installed
ls ~/.local/bin/claude

# Add to PATH if needed (add to your .bashrc or .zshrc)
export PATH="$HOME/.local/bin:$PATH"
```

Then open a new terminal window.

### Authentication fails

- Ensure you have a paid Anthropic account (Pro, Max, Teams, Enterprise, or Console)
- The free Claude.ai plan does not include Claude Code access
- Try running `claude` again and following the browser authentication prompts
- If using an API key, check that it is valid at [console.anthropic.com](https://console.anthropic.com)

### Claude seems slow to start

First launch after installation may take a moment. Subsequent launches are faster. If consistently slow, run `claude doctor` to diagnose issues.

### Commands fail with permission errors

Claude asks permission before running commands. If you accidentally denied a tool, you can re-approve it in the session or restart. For headless mode, use `--allowedTools` to pre-approve specific tools.

### Claude does not know about the project

Make sure you are running `claude` from the `cleansing-fire` directory. Claude reads `CLAUDE.md` from the current working directory. If you are in a different directory, Claude will not have the project context.

---

## Further Reading

- [Official Claude Code documentation](https://code.claude.com/docs/en/setup)
- [Claude Code CLI reference](https://code.claude.com/docs/en/cli-reference)
- [Headless mode / Agent SDK](https://code.claude.com/docs/en/headless)
- [Cleansing Fire project -- CLAUDE.md](/CLAUDE.md)
- [Pyrrhic Lucidity philosophy](/philosophy.md)
- [Cleansing Fire getting started guide](getting-started.md)
