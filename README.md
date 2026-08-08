# libmysqlclient

Reduced, source-buildable MySQL C client library for mcpp consumers.

This staging repository extracts the client library from MySQL Server source
without shipping the server, router, test suite, or command-line client. The
package is Form A: the checked-in `mcpp.toml` builds `libmysqlclient.a` directly
with mcpp. No CMake, Make, or prebuilt library is required by consumers.

**Upstream**: [MySQL Server](https://github.com/mysql/mysql-server) — this
repository is a client-only extraction of upstream tag `mysql-8.4.6` (see
`UPSTREAM.toml`).

Tags here follow the MySQL client ABI version. The initial tag is `8.4.6`,
extracted from the official MySQL Server archive recorded in `UPSTREAM.toml`.

## Maintainer update

Run `tools/extract.sh <version> <archive> <sha256>` to reproduce the current
client snapshot. The checked-in generated files are reused only when their
`LIBMYSQL_VERSION` matches `<version>`.

When updating to another MySQL version, first generate the matching
`mysqld_error.h`, `mysql_version.h`, `uca900_ja_tbls.cc`, and
`uca900_zh_tbls.cc`, then pass their build root through
`MYSQL_GENERATED_DIR=/path/to/build`. This maintainer-only generation step may
use upstream's build. Consumers never download or configure MySQL Server: they
clone this reduced source tree and build `libmysqlclient.a` directly with mcpp.

## License

The extracted MySQL source remains under the GPL-2.0-only license with the
Universal FOSS Exception where stated by the upstream files. See `LICENSE` and
the notices in the source tree.
