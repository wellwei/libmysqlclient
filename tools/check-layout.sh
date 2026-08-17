#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
required=(
  "$repo_root/mcpp.toml"
  "$repo_root/include/mysql.h"
  "$repo_root/UPSTREAM.toml"
  "$repo_root/generated/my_config.h"
  "$repo_root/generated/mysql_version.h"
  "$repo_root/generated/mysqld_error.h"
  "$repo_root/generated/uca900_ja_tbls.cc"
  "$repo_root/generated/uca900_zh_tbls.cc"
)
for path in "${required[@]}"; do
  [[ -e "$path" ]] || { printf 'missing required path: %s\n' "$path" >&2; exit 1; }
done

for forbidden in router storage mysql-test unittest client; do
  [[ ! -e "$repo_root/$forbidden" ]] || {
    printf 'forbidden server/client-tool directory present: %s\n' "$forbidden" >&2
    exit 1
  }
done

# Windows 下的 OpenSSL 采用不带旧式 uplink 桥接的静态构建，客户端不能
# 要求引用包内并未提供的 applink 源文件。
if grep -q '^#define HAVE_OPENSSL_APPLINK_C 1$' "$repo_root/generated/my_config.h"; then
  printf 'Windows config must not require OpenSSL applink.c.\n' >&2
  exit 1
fi

printf 'libmysqlclient source layout is client-only.\n'
