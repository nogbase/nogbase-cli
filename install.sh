#!/usr/bin/env sh
set -eu

repo="${NOGBASE_CLI_REPO:-nogbase/nogbase-cli}"
version="${NOGBASE_CLI_VERSION:-${1:-latest}}"
install_dir="${NOGBASE_CLI_INSTALL_DIR:-${HOME}/.local/bin}"

case "$(uname -s)" in
  Linux) os="linux" ;;
  Darwin) os="darwin" ;;
  MINGW*|MSYS*|CYGWIN*) os="windows" ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64|amd64) arch="amd64" ;;
  arm64|aarch64) arch="arm64" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

if [ "$version" = "latest" ]; then
  tag="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" | sed -n 's/.*"tag_name":[[:space:]]*"nogbase-cli-v\([^"]*\)".*/\1/p' | head -n 1)"
  if [ -z "$tag" ]; then
    echo "Could not resolve latest nogbase-cli release" >&2
    exit 1
  fi
  version="$tag"
fi

archive_ext="tar.gz"
if [ "$os" = "windows" ]; then
  archive_ext="zip"
fi

name="nogbase_${version}_${os}_${arch}"
archive="${name}.${archive_ext}"
base_url="https://github.com/${repo}/releases/download/nogbase-cli-v${version}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT INT TERM

cd "$tmp_dir"
curl -fsSLO "${base_url}/${archive}"
curl -fsSLO "${base_url}/${archive}.sha256"

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum -c "${archive}.sha256"
else
  shasum -a 256 -c "${archive}.sha256"
fi

if [ "$archive_ext" = "zip" ]; then
  unzip -q "$archive"
else
  tar -xzf "$archive"
fi

mkdir -p "$install_dir"
if [ "$os" = "windows" ]; then
  cp "${name}/nogbase.exe" "${install_dir}/nogbase.exe"
  cp "${name}/ngb.exe" "${install_dir}/ngb.exe"
else
  install -m 0755 "${name}/nogbase" "${install_dir}/nogbase"
  install -m 0755 "${name}/ngb" "${install_dir}/ngb"
fi

echo "Installed nogbase ${version} to ${install_dir}"
echo "Make sure ${install_dir} is on your PATH."
