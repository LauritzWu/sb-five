#!/usr/bin/env bash
set -euo pipefail

main() {
    local repo="LauritzWu/sb-five" commit="d31f9f0c53a0cd104b1927b6a4d93fafe2703792"
    if [[ "$#" -eq 2 ]]; then
        repo="$1"
        commit="$2"
    elif [[ "$#" -ne 0 ]]; then
        printf '用法：bash install.sh [所有者/仓库 40位Git提交号]\n' >&2
        return 2
    fi
    if [[ ! "$repo" =~ ^[A-Za-z0-9_-]+/[A-Za-z0-9_.-]+$ ||
          ! "$commit" =~ ^[a-fA-F0-9]{40}$ ]]; then
        printf '用法：bash install.sh 所有者/仓库 40位Git提交号\n' >&2
        return 2
    fi
    if [[ ! -t 0 ]]; then
        printf '请在 VPS 的交互终端中执行。\n' >&2
        return 2
    fi
    command -v curl >/dev/null || { printf '请先安装 curl。\n' >&2; return 2; }
    local -a elevate=()
    if (( EUID != 0 )); then
        command -v sudo >/dev/null || { printf '请以 root 运行，或安装 sudo。\n' >&2; return 2; }
        elevate=(sudo)
    fi
    if ! command -v python3 >/dev/null; then
        "${elevate[@]}" apt-get update
        "${elevate[@]}" apt-get install -y python3
    fi
    temp=$(mktemp -d)
    trap 'rm -f -- "$temp/sb"; rmdir -- "$temp"' EXIT
    curl --proto '=https' --tlsv1.2 -fsSL --retry 2 \
        "https://raw.githubusercontent.com/$repo/$commit/sb" -o "$temp/sb"
    "${elevate[@]}" python3 "$temp/sb"
}

main "$@"
