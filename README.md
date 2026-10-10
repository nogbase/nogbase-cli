# Nogbase CLI

The Nogbase CLI lets you, your scripts and your coding agents work with your Nogbase workspace
from a terminal. Release binaries are checksummed and published on GitHub Releases.

## Install

Linux and macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/nogbase/nogbase-cli/main/install.sh | sh
nogbase --help
ngb --help
```

Linux and macOS with a specific version or custom install directory:

```bash
curl -fsSL https://raw.githubusercontent.com/nogbase/nogbase-cli/main/install.sh \
  | NOGBASE_CLI_VERSION=0.2.0 NOGBASE_CLI_INSTALL_DIR="$HOME/.local/bin" sh
```

Windows PowerShell:

```powershell
iwr -UseBasicParsing https://raw.githubusercontent.com/nogbase/nogbase-cli/main/install.ps1 | iex
nogbase --help
ngb --help
```

Windows PowerShell with a specific version or custom install directory:

```powershell
$installer = iwr -UseBasicParsing https://raw.githubusercontent.com/nogbase/nogbase-cli/main/install.ps1
& ([scriptblock]::Create($installer.Content)) -Version "0.2.0" -InstallDir "$HOME\AppData\Local\Nogbase\bin"
```

Manual Linux binary installation from GitHub Releases:

```bash
VERSION=0.2.0
curl -LO "https://github.com/nogbase/nogbase-cli/releases/download/nogbase-cli-v${VERSION}/nogbase_${VERSION}_linux_amd64.tar.gz"
curl -LO "https://github.com/nogbase/nogbase-cli/releases/download/nogbase-cli-v${VERSION}/nogbase_${VERSION}_linux_amd64.tar.gz.sha256"
sha256sum -c "nogbase_${VERSION}_linux_amd64.tar.gz.sha256"
tar -xzf "nogbase_${VERSION}_linux_amd64.tar.gz"
mkdir -p "$HOME/.local/bin"
install -m 0755 "nogbase_${VERSION}_linux_amd64/nogbase" "$HOME/.local/bin/nogbase"
install -m 0755 "nogbase_${VERSION}_linux_amd64/ngb" "$HOME/.local/bin/ngb"
```

## Configure

Release builds connect to `https://api.nogbase.ae`. Start with:

```bash
nogbase login            # opens your browser; MFA and workspace choice supported
nogbase status           # shows who you are and which workspace
```

`nogbase login` opens Nogbase sign-in in your browser. Multi-factor authentication and the
workspace choice happen there, and the CLI saves a session that it refreshes on its own. Browser
sign-in needs CLI 0.2.0 or later; older builds support only `-u`/`-p` and `--api-key`.

- `nogbase login --no-browser` prints the sign-in link instead of opening a browser.
- On a machine without a browser (SSH, servers, agent sandboxes) `nogbase login` prints a link and a
  code to approve on any device; `--device` forces this.
- `nogbase login --password-prompt` (or `-u` and `-p`) signs in with a username and password.
  `-p` leaves the password in your shell history and process list; prefer `--password-prompt`.
- `nogbase logout` signs out and clears the saved session.

CI and servers use a workspace API key instead of a browser session:

```bash
nogbase login --api-key "$NOGBASE_API_KEY"   # CI and servers
nogbase status --json
```

When `NOGBASE_API_KEY` is set, `nogbase login` uses that key and does not open the browser.

Coding agents that run on your machine should ask you to run `nogbase login` once and then use
that session. Use a workspace API key only for unattended runs.

The CLI keeps its configuration in `~/.nogbase/config.yaml`.

## Command Names

- `nogbase` is the canonical command.
- `ngb` is the short alias.

Use `--json` in scripts and agent workflows when the command supports structured output. Some operational commands are text-only; check command help before parsing output.
