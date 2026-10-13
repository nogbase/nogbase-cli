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

## Call the API directly

`nogbase api` calls any Nogbase v1 endpoint with the session from `nogbase login`
(or your API key), against the API address saved in your profile. You never
handle a token.

```bash
nogbase api GET /v1/schemas
nogbase api GET "/v1/collections/leads?limit=20"
nogbase api GET "/v1/collections/leads?limit=20&after=<meta.nextCursor>"
nogbase api POST /v1/collections/leads --data '{"name":"Sara"}'
nogbase api PUT /v1/collections/leads/<id> --data @lead.json --if-match 3
```

- Writes always send an `Idempotency-Key`. If you don't pass `--idempotency-key`,
  the CLI prints the one it generated to stderr; pass it back to repeat the same request.
  Endpoints that support idempotency (collection writes do) then return the
  stored result instead of writing twice. After a 412 version conflict, re-read
  the record and send the corrected write with a new key.
- Collection lists return `meta.nextCursor`; pass it as `after` for the next page.
- `--include` prints the HTTP status and headers. A non-2xx response (including
  a redirect, which the CLI never follows) prints the body and exits with code 3.
- URL-encode query values (`%20`, `%2C`); the CLI sends the query as given.
- Market scope works as in the data commands: `--country AE` (or `all`) sets it.
  Without `--country`, a signed-in session sends your saved market
  (`nogbase market use <country>`) and an API key sends `all`.
- To call another environment, switch profiles (`nogbase profile use <name>`).
  `nogbase api` refuses `--api-url`, `NOGBASE_API_URL` and `--insecure`, so your
  sign-in is only ever sent to the address it was saved with. It still honours
  `--profile`/`NOGBASE_PROFILE`, `--entity`/`NOGBASE_ENTITY` and
  `--api-key`/`NOGBASE_API_KEY` as every command does: they choose the saved
  profile, the workspace or the key, and the server checks access as for any
  other call (a login session acts only in its own workspace).
- Agent API keys can group their changes into a run: open one with
  `nogbase api POST /v1/agent-runs`, pass its id with `--run-id`, and close it with
  `nogbase api PATCH /v1/agent-runs/<runId>/close`. A signed-in session does not
  open runs; its changes are recorded as yours.

The endpoints are described at https://api.nogbase.ae/llms.txt.

## Command Names

- `nogbase` is the canonical command.
- `ngb` is the short alias.

Use `--json` in scripts and agent workflows when the command supports structured output. Some operational commands are text-only; check command help before parsing output.
