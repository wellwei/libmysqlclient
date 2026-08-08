#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  printf 'usage: %s <version> <archive> <sha256>\n' "$0" >&2
  exit 2
fi

version=$1
archive_url=$2
expected_sha=$3
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/libmysqlclient-extract.XXXXXX")
trap 'rm -rf "$work_dir"' EXIT

archive="$work_dir/mysql-server-${version}.tar.gz"
if [[ -f "$archive_url" ]]; then
  # 本地归档便于维护者复用已下载的 478 MB 文件，避免重复下载。
  cp "$archive_url" "$archive"
else
  curl --fail --location --retry 2 --retry-connrefused --output "$archive" "$archive_url"
fi
printf '%s  %s\n' "$expected_sha" "$archive" | shasum -a 256 -c -

tar -xzf "$archive" -C "$work_dir"
source_dir=$(find "$work_dir" -mindepth 1 -maxdepth 1 -type d -name "mysql-server-*" -print -quit)
[[ -n "$source_dir" ]] || { printf 'archive has no mysql-server-* root\n' >&2; exit 1; }

# The allow-list is deliberately explicit: adding a new source requires
# reviewing its client ABI and dependency impact. Headers are copied separately
# so disabled authentication plugins and test/utility translation units never
# become part of the package source set.
rm -rf "$repo_root/include" "$repo_root/libmysql" "$repo_root/mysys" \
  "$repo_root/strings" "$repo_root/vio" "$repo_root/sql-common" \
  "$repo_root/sql" "$repo_root/libs" "$repo_root/libbinlogevents" \
  "$repo_root/extra/rapidjson"

copy_headers() {
  local src_root=$1
  local dst_root=$2
  find "$src_root" -type f \( -name '*.h' -o -name '*.hpp' -o -name '*.inl' \
      -o -name '*.inc' -o -name '*.tcc' \) -print0 |
    while IFS= read -r -d '' src; do
      local rel=${src#"$src_root/"}
      mkdir -p "$dst_root/$(dirname "$rel")"
      cp "$src" "$dst_root/$rel"
    done
}

copy_sources() {
  local src_root=$1
  local dst_root=$2
  shift 2
  local rel
  for rel in "$@"; do
    [[ -f "$src_root/$rel" ]] || {
      printf 'allow-listed source is missing: %s\n' "$src_root/$rel" >&2
      exit 1
    }
    mkdir -p "$dst_root/$(dirname "$rel")"
    cp "$src_root/$rel" "$dst_root/$rel"
  done
}

copy_headers "$source_dir/include" "$repo_root/include"
copy_headers "$source_dir/libmysql" "$repo_root/libmysql"
copy_headers "$source_dir/mysys" "$repo_root/mysys"
copy_headers "$source_dir/strings" "$repo_root/strings"
copy_headers "$source_dir/vio" "$repo_root/vio"
copy_headers "$source_dir/sql-common" "$repo_root/sql-common"
copy_headers "$source_dir/sql" "$repo_root/sql"
copy_headers "$source_dir/libs" "$repo_root/libs"
mkdir -p "$repo_root/libbinlogevents" "$repo_root/extra/rapidjson"
cp -R "$source_dir/libbinlogevents/include" "$repo_root/libbinlogevents/include"
cp -R "$source_dir/extra/rapidjson/include" "$repo_root/extra/rapidjson/include"

copy_sources "$source_dir/libmysql" "$repo_root/libmysql" \
  libmysql.cc errmsg.cc dns_srv.cc mysql_trace.cc
copy_sources "$source_dir/sql-common" "$repo_root/sql-common" \
  client.cc client_plugin.cc client_authentication.cc compression.cc \
  get_password.cc net_serv.cc bind_params.cc mysql_native_authentication_client.cc
copy_sources "$source_dir/sql/auth" "$repo_root/sql/auth" \
  password.cc sha2_password_common.cc
copy_sources "$source_dir/mysys" "$repo_root/mysys" \
  array.cc charset.cc dbug.cc decimal.cc errors.cc lf_alloc-pin.cc lf_dynarray.cc \
  lf_hash.cc list.cc mf_arr_appstr.cc mf_cache.cc mf_dirname.cc mf_fn_ext.cc \
  mf_format.cc mf_iocache2.cc mf_iocache.cc mf_keycache.cc mf_keycaches.cc \
  mf_loadpath.cc mf_pack.cc mf_path.cc mf_same.cc mf_tempdir.cc mf_tempfile.cc \
  mf_unixpath.cc mf_wcomp.cc mulalloc.cc my_access.cc my_aligned_malloc.cc \
  my_alloc.cc my_bitmap.cc my_chmod.cc my_chsize.cc my_compare.cc my_compress.cc \
  my_copy.cc my_create.cc my_delete.cc my_error.cc my_fallocator.cc my_file.cc \
  my_fopen.cc my_fstream.cc my_gethwaddr.cc my_getwd.cc my_init.cc my_lib.cc \
  my_malloc.cc my_mess.cc my_mkdir.cc my_mmap.cc my_murmur3.cc my_once.cc \
  my_open.cc my_pread.cc my_rdtsc.cc my_read.cc my_rename.cc my_seek.cc \
  my_static.cc my_string.cc my_symlink2.cc my_symlink.cc my_sync.cc my_syslog.cc \
  my_system.cc my_thread.cc my_thr_init.cc my_user.cc my_version.cc my_write.cc \
  pack.cc print_version.cc psi_noop.cc ptr_cmp.cc stacktrace.cc str2int.cc \
  strcont.cc strmake.cc strxmov.cc strxnmov.cc thr_cond.cc thr_lock.cc \
  thr_mutex.cc thr_rwlock.cc tree.cc \
  typelib.cc unhex.cc keyring_operations_helper.cc crypt_genhash_impl.cc \
  my_default.cc my_getopt.cc my_kdf.cc my_aes.cc my_sha1.cc my_sha2.cc my_md5.cc \
  my_rnd.cc my_openssl_fips.cc my_aes_openssl.cc my_getpwnam.cc my_time.cc \
  my_systime.cc posix_timers.cc kqueue_timers.cc
copy_sources "$source_dir/strings" "$repo_root/strings" \
  collations.cc collations_internal.cc ctype-big5.cc ctype-bin.cc ctype-cp932.cc \
  ctype-czech.cc ctype-euc_kr.cc ctype-eucjpms.cc ctype-extra.cc ctype-gb18030.cc \
  ctype-gb2312.cc ctype-gbk.cc ctype-latin1.cc ctype-mb.cc ctype-simple.cc \
  ctype-sjis.cc ctype-tis620.cc ctype-uca.cc ctype-ucs2.cc ctype-ujis.cc \
  ctype-utf8.cc ctype-win1250ch.cc ctype.cc dtoa.cc int2str.cc my_strchr.cc \
  my_strtoll10.cc my_uctype.cc sql_chars.cc str_alloc.cc xml.cc
copy_sources "$source_dir/vio" "$repo_root/vio" \
  vio.cc viosocket.cc viossl.cc viosslfactories.cc

# my_config.h is intentionally a portable, mcpp-owned configuration rather
# than a CMake cache containing machine-specific install paths.
mkdir -p "$repo_root/generated"
cat > "$repo_root/generated/my_config.h" <<EOF
#ifndef MY_CONFIG_H
#define MY_CONFIG_H

/* mcpp client snapshot: common POSIX capabilities shared by Linux/macOS. */
#define HAVE_ALLOCA_H 1
#define HAVE_ARPA_INET_H 1
#define HAVE_DLFCN_H 1
#define HAVE_FNMATCH_H 1
#define HAVE_GETADDRINFO 1
#define HAVE_GETPWNAM 1
#define HAVE_GETPWUID 1
#define HAVE_GETPASS 1
#define HAVE_GETTIMEOFDAY 1
#define HAVE_SYS_TIMES_H 1
#define HAVE_TIMES 1
#define HAVE_GRP_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_NETINET_IN_H 1
#define HAVE_POLL_H 1
#define HAVE_POLL 1
#define HAVE_PWD_H 1
#define HAVE_SIGNAL_H 1
#define HAVE_STDARG_H 1
#define HAVE_STDINT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRINGS_H 1
#define HAVE_STRING_H 1
#define HAVE_STRTOK_R 1
#define HAVE_STRTOLL 1
#define HAVE_SYS_CDEFS_H 1
#define HAVE_SYS_IOCTL_H 1
#define HAVE_SYS_MMAN_H 1
#define HAVE_SYS_SELECT_H 1
#define HAVE_SYS_SOCKET_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TIME_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_SYS_UN_H 1
#define HAVE_UNISTD_H 1
#define HAVE_FCNTL 1
#define HAVE_FCNTL_H 1
#define HAVE_FTRUNCATE 1
#define HAVE_FSYNC 1
#define HAVE_GETUID 1
#define HAVE_GETEUID 1
#define HAVE_GETGID 1
#define HAVE_GETEGID 1
#define HAVE_GETRUSAGE 1
#define HAVE_LRAND48 1
#define HAVE_MADVISE 1
#define HAVE_MMAP 1
#define HAVE_MLOCK 1
#define HAVE_MLOCKALL 1
#define HAVE_POSIX_MEMALIGN 1
#define HAVE_PTHREAD_SIGMASK 1
#define HAVE_SLEEP 1
#define HAVE_STPCPY 1
#define HAVE_STPNCPY 1
#define HAVE_STRPTIME 1
#define HAVE_STRSIGNAL 1
#define HAVE_VASPRINTF 1
#define HAVE_VISIBILITY_HIDDEN 1
#define HAVE_CLOCK_GETTIME 1
#define HAVE_CLOCK_REALTIME 1
#define TIME_WITH_SYS_TIME 1
#define HAVE_BUILTIN_EXPECT 1
#define HAVE_BUILTIN_UNREACHABLE 1
#define HAVE_GCC_SYNC_BUILTINS 1
#define HAVE_SYS_WAIT_H 1
#define HAVE_SYS_PARAM_H 1
#define HAVE_U_INT32_T 1
#define HAVE_TM_GMTOFF 1
#define HAVE_TLSv13 1
#define HAVE_DNS_SRV 1
#define HAVE_UNIX_DNS_SRV 1
#define HAVE_OPENSSL 1
#define MYSQL_DEFAULT_CHARSET_NAME "utf8mb4"
#define MYSQL_DEFAULT_COLLATION_NAME "utf8mb4_0900_ai_ci"
#define PACKAGE_VERSION "$version"
#define SO_EXT ".so"
#define MAX_INDEXES 64U
#define ENABLED_PROFILING 1
#define SIZEOF_VOIDP 8
#define SIZEOF_CHARP 8
#define SIZEOF_LONG 8
#define SIZEOF_SHORT 2
#define SIZEOF_INT 4
#define SIZEOF_LONG_LONG 8
#define SIZEOF_TIME_T 8
#define MAX_HOST_NAME_LENGTH 255
#define DEFAULT_TMPDIR P_tmpdir
#define DEFAULT_MYSQL_HOME "."
#define SHAREDIR "."
#define DEFAULT_BASEDIR "."
#define MYSQL_DATADIR "."
#define MYSQL_KEYRINGDIR "."
#define DEFAULT_CHARSET_HOME "."
#define PLUGINDIR "."
#define DEFAULT_SYSCONFDIR "."
#define HAVE_MBSTATE_T 1
#define HAVE_WCHAR_T 1
#define HAVE_WINT_T 1
#define HAVE_GETLINE 1
#define HAVE_WCSDUP 1
#define HAVE_LANGINFO_CODESET 1

#if defined(__APPLE__)
#define HAVE_STRLCAT 1
#define HAVE_STRLCPY 1
#define HAVE_KQUEUE 1
#define HAVE_KQUEUE_TIMERS 1
#define HAVE_KQUEUE_H 1
#define HAVE_PTHREAD_SETNAME_NP_MACOS 1
#define APPLE_ARM 1
#define MACHINE_TYPE "macos"
#define SYSTEM_TYPE "macos"
#else
#define HAVE_POSIX_TIMERS 1
#define HAVE_EPOLL 1
#define HAVE_PTHREAD_SETNAME_NP_LINUX 1
#define MACHINE_TYPE "linux"
#define SYSTEM_TYPE "linux"
#endif

#endif /* MY_CONFIG_H */
EOF

if [[ -n "${MYSQL_GENERATED_DIR:-}" ]]; then
  generated_dir=$MYSQL_GENERATED_DIR
  for generated in include/mysqld_error.h include/mysql_version.h \
    strings/uca900_ja_tbls.cc strings/uca900_zh_tbls.cc; do
    [[ -f "$generated_dir/$generated" ]] || {
      printf 'missing generated client file: %s/%s\n' "$generated_dir" "$generated" >&2
      printf 'provide MYSQL_GENERATED_DIR from a matching MySQL client generation build\n' >&2
      exit 1
    }
    output=${generated##*/}
    cp "$generated_dir/$generated" "$repo_root/generated/$output"
  done
else
  # 同版本重提取直接复用仓库内已审阅的生成文件；升级版本必须显式替换。
  for generated in mysqld_error.h mysql_version.h \
    uca900_ja_tbls.cc uca900_zh_tbls.cc; do
    [[ -f "$repo_root/generated/$generated" ]] || {
      printf 'missing checked-in generated client file: generated/%s\n' "$generated" >&2
      printf 'provide MYSQL_GENERATED_DIR when updating the MySQL version\n' >&2
      exit 1
    }
  done
  rg -q "^#define LIBMYSQL_VERSION[[:space:]]+\"$version\"$" \
    "$repo_root/generated/mysql_version.h" || {
    printf 'checked-in generated files do not match MySQL %s\n' "$version" >&2
    printf 'provide MYSQL_GENERATED_DIR when updating the MySQL version\n' >&2
    exit 1
  }
fi

cp "$source_dir/LICENSE" "$repo_root/LICENSE"
printf 'extracted MySQL client sources for %s\n' "$version"
