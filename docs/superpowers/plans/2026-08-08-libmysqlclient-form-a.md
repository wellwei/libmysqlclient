# libmysqlclient Form A Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `wellwei/libmysqlclient` as a reduced MySQL 8.4.6 client-only source package built by mcpp, then consume it from mcpp-index as a Form A dependency.

**Architecture:** The staging repository stores an allow-listed MySQL client source snapshot, generated headers, an mcpp manifest, and a reproducible extraction script. Its static `libmysqlclient` target is built inside the consumer graph; the index descriptor only supplies the source archive URL/SHA and does not run CMake or install hooks for this package. Connector/C++ is updated only after the direct Form A consumer proves the library target and link boundary.

**Tech Stack:** mcpp 2026.8.8.2, xpkg V1 Lua descriptors, C/C++11-compatible MySQL sources, OpenSSL 3.5.1, zlib 1.3.2, zstd 1.5.7, lz4 1.10.0, GitHub tags and Actions.

---

### Task 1: Establish the staging repository and provenance files

**Files:**
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/README.md`
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/LICENSE`
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/UPSTREAM.toml`
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/tools/extract.sh`

- [ ] **Step 1: Write the provenance assertion test**

Create `tools/check-layout.sh` that fails unless the checked-out tree has
`mcpp.toml`, `include/mysql.h`, `UPSTREAM.toml`, and no `router`, `storage`,
`mysql-test`, `unittest`, or command-line client source directory.

- [ ] **Step 2: Run the layout check to verify it fails**

Run `bash tools/check-layout.sh` in the empty repository. Expected: failure
because the client source and manifest are not present yet.

- [ ] **Step 3: Add the minimal provenance and extraction implementation**

Record `mysql-8.4.6.tar.gz` and SHA-256
`d44a93897156a124696e5492971c215981e7f638c2a5c4d773fc586eea213ad1` in
`UPSTREAM.toml`. Make `tools/extract.sh` require an explicit version, download
the matching official tag archive, verify SHA-256, copy only the allow-listed
client paths, and emit the generated client headers into the repository.
Keep all paths rooted at the repository and reject an archive whose top-level
directory does not match the requested tag.

- [ ] **Step 4: Run the layout check again**

Run `bash tools/check-layout.sh`; it must still fail until the extracted files
and manifest are added in Task 2.

- [ ] **Step 5: Commit the repository scaffolding**

Run:

```bash
git add README.md LICENSE UPSTREAM.toml tools
git commit -m "chore: add libmysqlclient provenance tooling"
```

### Task 2: Add the reduced MySQL 8.4.6 source tree and Form A manifest

**Files:**
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/mcpp.toml`
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/include/`
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/libmysql/`
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/mysys/`
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/strings/`
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/vio/`
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/sql-common/`
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/generated/`

- [ ] **Step 1: Add the failing direct consumer**

Create a temporary consumer with a dependency on the local repository and an
assertion that includes `<mysql.h>`, checks `MYSQL_VERSION_ID == 80406`, calls
`mysql_get_client_version()`, and calls `mysql_init`/`mysql_close`.

- [ ] **Step 2: Run the consumer to verify it fails**

Run the current mcpp binary against the temporary consumer. Expected: failure
because the repository has no Form A manifest or source target.

- [ ] **Step 3: Extract the minimum source set and declare it in mcpp.toml**

Copy the upstream client headers and the source groups required by the proven
8.4.6 client-only build. Exclude server, router, test, command-line client,
LDAP/Kerberos/WebAuthn/FIDO, and generated dump utilities. Add the generated
`mysql_version.h`, `mysqld_error.h`, `my_config.h`, and the UCA source tables
needed by the selected string sources. Declare C11/C++14-compatible compilation,
the client source globs, include roots, OpenSSL/zlib/zstd/lz4 dependencies,
platform link flags, and a static `libmysqlclient` target. Add Chinese comments
in the manifest explaining why each generated header or source exclusion is
present.

- [ ] **Step 4: Run the direct consumer and inspect the archive**

Run the consumer with a cold local build cache. Expected: `libmysqlclient.a`
is produced by mcpp, the C API assertion runs, and the final link contains the
Form A target rather than an xlings install-prefix `-L` path.

- [ ] **Step 5: Commit the first source package**

Run:

```bash
git add mcpp.toml include libmysql mysys strings vio sql-common generated
git commit -m "feat: add MySQL 8.4.6 client Form A package"
```

### Task 3: Validate and publish the staging repository

**Files:**
- Create: `/Users/cltx/projects/mcpp/libmysqlclient/.github/workflows/validate.yml`
- Modify: `/Users/cltx/projects/mcpp/libmysqlclient/README.md`

- [ ] **Step 1: Add the CI assertions**

Run the layout check, parse `mcpp.toml` with the pinned mcpp, build the direct
consumer on Linux and macOS, and verify the archive size is materially below
the original MySQL Server archive. Do not add a prebuilt library artifact.

- [ ] **Step 2: Run the same checks locally**

Run `bash tools/check-layout.sh`, `mcpp xpkg parse mcpp.toml`, and the cold
consumer build. Expected: all pass and the runtime reports version `80406`.

- [ ] **Step 3: Create and tag the staging GitHub repository**

Run `gh repo create wellwei/libmysqlclient --public --source . --remote origin`
from the repository root, push the default branch, create tag `8.4.6`, and
push the tag. Confirm the GitHub tag archive contains `mcpp.toml` at the
expected Form A lookup location.

- [ ] **Step 4: Commit the CI and documentation update**

Run:

```bash
git add .github/workflows/validate.yml README.md
git commit -m "ci: validate the reduced client package"
```

### Task 4: Switch mcpp-index to the Form A provider

**Files:**
- Modify: `/Users/cltx/projects/mcpp/mcpp-index/pkgs/c/compat.libmysqlclient.lua`
- Modify: `/Users/cltx/projects/mcpp/mcpp-index/tests/examples/libmysqlclient/mcpp.toml`
- Modify: `/Users/cltx/projects/mcpp/mcpp-index/tests/examples/libmysqlclient/tests/client.cpp`
- Modify: `/Users/cltx/projects/mcpp/mcpp-index/mcpp.toml`

- [ ] **Step 1: Write the failing index consumer assertion**

Change the consumer to request `libmysqlclient = "8.4.6"` and assert the 8.4.6
API version. Run it against the old Form B descriptor; expected: resolution or
version assertion failure.

- [ ] **Step 2: Replace the descriptor with a Form A entry**

Declare the staging repository URL, exact tag archive SHA, Linux/macOS entries,
namespace `compat`, and no inline `mcpp` block or `install()` hook. The Form A
manifest inside the archive owns compilation and dependencies.

- [ ] **Step 3: Run the cold index consumer**

Run the workflow-pinned mcpp with `MCPP_BUILD_CACHE=local` after removing only
the isolated libmysqlclient consumer cache. Expected: the package source is
small, `libmysqlclient.a` is built by mcpp, and the C API test passes.

- [ ] **Step 4: Commit the index migration**

Run:

```bash
git add pkgs/c/compat.libmysqlclient.lua tests/examples/libmysqlclient mcpp.toml
git commit -m "feat: consume libmysqlclient as a Form A package"
```

### Task 5: Reconnect Connector/C++ and verify the final dependency edge

**Files:**
- Modify: `/Users/cltx/projects/mcpp/mcpp-index/pkgs/c/compat.mysql-connector-cpp.lua`
- Modify: `/Users/cltx/projects/mcpp/mcpp-index/tests/examples/mysql-connector-cpp/mcpp.toml`
- Modify: `/Users/cltx/projects/mcpp/mcpp-index/tests/examples/mysql-connector-cpp/tests/connector.cpp`

- [ ] **Step 1: Add the failing JDBC/X DevAPI consumer assertion**

Pin the selected Connector/C++ 9.x release and `compat.libmysqlclient =
"8.4.6"`; assert both headers, both static connector archives, JDBC driver
version, and a final link that also resolves a symbol from `libmysqlclient`.

- [ ] **Step 2: Run the consumer before the bridge change**

Run the cold connector consumer. Expected: the old install hook fails because it
expects a preinstalled `mysql_config`/`libmysqlclient.a` prefix or cannot resolve
the 9.x client API against the old descriptor.

- [ ] **Step 3: Make the connector bridge consume Form A source/target semantics**

Pass the reduced client include root to Connector/C++ configure, keep any
configure-only library placeholder isolated and explicitly named if the legacy
CMake finder requires a file, and ensure the installed Connector/C++ descriptor
does not claim that placeholder as a runtime dependency. The final mcpp target
must link the actual Form A `libmysqlclient` archive and its OpenSSL/compression
dependencies through the dependency graph.

- [ ] **Step 4: Run the final cold consumer**

Run the Linux/macOS connector consumer with a local build cache and inspect the
installed headers and static archives. Expected: X DevAPI and JDBC compile and
link, `mysql_get_client_version()` resolves from the mcpp-built client archive,
and no 500MB MySQL Server archive or CMake build is downloaded for the client
package.

- [ ] **Step 5: Run repository validation**

Run Lua syntax/cross-reference/platform parity checks, parse every descriptor
with mcpp `2026.8.8.2`, run the two focused consumers, and run `git diff --check`.
Record any platform not exercised locally rather than claiming it is verified.

