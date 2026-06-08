# Nogbase CLI

Public binary distribution for the Nogbase CLI.

The Nogbase CLI source and build automation live in the private `nogbase/nogbase-core`
repository. This public repository contains installer scripts and GitHub Release assets only.

## Install

Linux and macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/nogbase/nogbase-cli/main/install.sh | sh
nogbase --help
ngb --help
```

Linux and macOS with a pinned version or custom install directory:

```bash
curl -fsSL https://raw.githubusercontent.com/nogbase/nogbase-cli/main/install.sh \
  | NOGBASE_CLI_VERSION=0.1.0 NOGBASE_CLI_INSTALL_DIR="$HOME/.local/bin" sh
```

Windows PowerShell:

```powershell
iwr -UseBasicParsing https://raw.githubusercontent.com/nogbase/nogbase-cli/main/install.ps1 | iex
nogbase --help
ngb --help
```

Windows PowerShell with a pinned version or custom install directory:

```powershell
$installer = iwr -UseBasicParsing https://raw.githubusercontent.com/nogbase/nogbase-cli/main/install.ps1
& ([scriptblock]::Create($installer.Content)) -Version "0.1.0" -InstallDir "$HOME\AppData\Local\Nogbase\bin"
```

## Manual Install

Linux amd64 example:

```bash
VERSION=0.1.0
curl -LO "https://github.com/nogbase/nogbase-cli/releases/download/nogbase-cli-v${VERSION}/nogbase_${VERSION}_linux_amd64.tar.gz"
curl -LO "https://github.com/nogbase/nogbase-cli/releases/download/nogbase-cli-v${VERSION}/nogbase_${VERSION}_linux_amd64.tar.gz.sha256"
sha256sum -c "nogbase_${VERSION}_linux_amd64.tar.gz.sha256"
tar -xzf "nogbase_${VERSION}_linux_amd64.tar.gz"
mkdir -p "$HOME/.local/bin"
install -m 0755 "nogbase_${VERSION}_linux_amd64/nogbase" "$HOME/.local/bin/nogbase"
install -m 0755 "nogbase_${VERSION}_linux_amd64/ngb" "$HOME/.local/bin/ngb"
```

## Configure

```bash
nogbase profile add sandbox --api-url https://beta.nogbase.ae
nogbase profile use sandbox
nogbase login --api-key "$NOGBASE_API_KEY"
nogbase status --json
```

New installs use `~/.nogbase/config.yaml`. Existing legacy installs under
`~/.edget/config.yaml` continue to work during the migration window.

## Command Names

- `nogbase` is the canonical command.
- `ngb` is the short alias.
- `edget` is the former command and is kept only as a temporary compatibility shim in private
  platform builds during the migration window.

Use `--json` in scripts and agent workflows when the command supports structured output.
