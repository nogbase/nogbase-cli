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

## Maintainer Notes

This repository is distribution-only.

- Do not add Nogbase backend or CLI source code here.
- Do not commit release binaries to git.
- Public binaries are published as GitHub Release assets.
- Installer scripts download from `nogbase/nogbase-cli` releases by default.
- The private `nogbase/nogbase-core` repository owns the source and release workflow.

Release updates are tag-driven from `nogbase/nogbase-core`:

1. Update CLI source in private core under `backend/cmd/nogbase/`.
2. Commit and push the source/docs changes in private core.
3. Tag the intended core commit with `nogbase-cli-v<version>`, for example:

```bash
git tag nogbase-cli-v0.1.1
git push org nogbase-cli-v0.1.1
```

4. The private core workflow builds Linux, macOS, and Windows archives.
5. The workflow publishes checksummed assets to this public repo's GitHub Releases.
6. Verify the public installer:

```bash
install_root="$(mktemp -d /tmp/nogbase-cli-install.XXXXXX)"
curl -fsSL https://raw.githubusercontent.com/nogbase/nogbase-cli/main/install.sh \
  | NOGBASE_CLI_INSTALL_DIR="${install_root}/bin" sh
"${install_root}/bin/nogbase" version
"${install_root}/bin/ngb" --help >/tmp/nogbase-cli-help.txt
```

If the public installer behavior changes, update both this repository's installer scripts and the
private core copies under `scripts/install-nogbase-cli.*`.
