# libmysqlclient Form A Design

## Goal

Maintain a small, source-buildable MySQL 8.4+ client library repository for
Connector/C++ and other consumers. The repository must not make consumers
download the full MySQL Server source tree, and its package entry must be a
Form A package carrying its own `mcpp.toml`.

## Architecture

Each release tag matches the corresponding MySQL Server client ABI version,
starting with `8.4.6`. The repository contains only the client-facing headers,
the source files needed for `libmysqlclient.a`, generated configuration/error
headers required by that source set, and the mcpp manifest. `tools/extract.sh`
downloads and verifies the authoritative MySQL Server archive only for
maintainers, applies an explicit allow-list, and records the upstream archive
SHA-256. Consumers fetch the repository tag archive, which is the reduced
source package.

The manifest declares a static `libmysqlclient` target and its source/include
paths directly. OpenSSL, zlib, zstd, and lz4 remain normal mcpp dependencies
where the current index provides compatible targets; no CMake, Make, server,
router, test, command-line client, or prebuilt library is part of the package.

## Build and dependency boundary

The first release targets Linux and macOS, matching the existing index
coverage. The public include layout is the MySQL Server 8.4 layout, including
`<mysql.h>` at the include root and `<mysql/...>` auxiliary headers. The static
archive is produced by mcpp in the consumer's target graph, so downstream
packages link the real archive through the Form A dependency edge rather than
looking for an xlings install prefix.

Connector/C++ remains a separate package. Its build bridge may use the reduced
client source tree for configure-time headers and must not claim that a
placeholder archive is the final client library; final consumer linking must
include the Form A `libmysqlclient` target and assert the client API at runtime.

## Verification

The repository CI and local checks must prove:

1. The extracted tree contains no server/router/test/client-tool directories.
2. `mcpp xpkg parse` accepts the package manifest and `mcpp build` produces a
   `libmysqlclient.a` target on each declared platform.
3. A C API consumer includes `<mysql.h>`, checks `MYSQL_VERSION_ID == 80406`,
   calls `mysql_get_client_version()`, and links/runs against the archive.
4. The extraction script reproduces the recorded upstream version and SHA.

