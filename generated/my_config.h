#ifndef MY_CONFIG_H
#define MY_CONFIG_H

/* mcpp client snapshot: platform configuration split into Windows / macOS /
   Linux branches, mirroring what upstream CMake would generate. The POSIX
   block applies to Linux and macOS only; Windows (LLP64) gets its own block. */

/* ---------- common ---------- */
#define HAVE_OPENSSL 1
#define HAVE_TLSv13 1
#define HAVE_DNS_SRV 1
#define MYSQL_DEFAULT_CHARSET_NAME "utf8mb4"
#define MYSQL_DEFAULT_COLLATION_NAME "utf8mb4_0900_ai_ci"
#define PACKAGE_VERSION "8.4.6"
#define MAX_INDEXES 64U
#define ENABLED_PROFILING 1
#define MAX_HOST_NAME_LENGTH 255
#define DEFAULT_MYSQL_HOME "."
#define SHAREDIR "."
#define DEFAULT_BASEDIR "."
#define MYSQL_DATADIR "."
#define MYSQL_KEYRINGDIR "."
#define DEFAULT_CHARSET_HOME "."
#define PLUGINDIR "."
#define DEFAULT_SYSCONFDIR "."
#define SIZEOF_VOIDP 8
#define SIZEOF_CHARP 8
#define SIZEOF_SHORT 2
#define SIZEOF_INT 4
#define SIZEOF_LONG_LONG 8
#define SIZEOF_TIME_T 8
#define HAVE_MBSTATE_T 1
#define HAVE_WCHAR_T 1
#define HAVE_WINT_T 1

#if defined(_WIN32)
/* ---------- Windows (LLP64) ---------- */
#define HAVE_ALIGNED_MALLOC 1
#define HAVE_MALLOC_H 1
#define HAVE_TELL 1
#define HAVE_OPENSSL_APPLINK_C 1
#define SIZEOF_LONG 4
#define SO_EXT ".dll"
#define DEFAULT_TMPDIR "\\tmp"
#define MACHINE_TYPE "windows"
#define SYSTEM_TYPE "windows"
#elif defined(__APPLE__)
/* ---------- macOS ---------- */
#define HAVE_STRLCAT 1
#define HAVE_STRLCPY 1
#define HAVE_KQUEUE 1
#define HAVE_KQUEUE_TIMERS 1
#define HAVE_KQUEUE_H 1
#define HAVE_PTHREAD_SETNAME_NP_MACOS 1
#define APPLE_ARM 1
#define SIZEOF_LONG 8
#define SO_EXT ".dylib"
#define DEFAULT_TMPDIR P_tmpdir
#define MACHINE_TYPE "macos"
#define SYSTEM_TYPE "macos"
#else
/* ---------- Linux ---------- */
#define HAVE_POSIX_TIMERS 1
#define HAVE_EPOLL 1
#define HAVE_PTHREAD_SETNAME_NP_LINUX 1
#define HAVE_O_TMPFILE 1
#define HAVE_MEMALIGN 1
#define HAVE_FDATASYNC 1
#define HAVE_DECL_FDATASYNC 1
#define HAVE_STRLCAT 1
#define HAVE_STRLCPY 1
#define SIZEOF_LONG 8
#define SO_EXT ".so"
#define DEFAULT_TMPDIR P_tmpdir
#define MACHINE_TYPE "linux"
#define SYSTEM_TYPE "linux"
#endif

/* ---------- POSIX common (Linux/macOS) ---------- */
#if !defined(_WIN32)
#define HAVE_ALLOCA_H 1
#define HAVE_ARPA_INET_H 1
#define HAVE_DLFCN_H 1
#define HAVE_EXECINFO_H 1
#define HAVE_FNMATCH_H 1
#define HAVE_GETADDRINFO 1
#define HAVE_GETLINE 1
#define HAVE_GETPASS 1
#define HAVE_GETPWNAM 1
#define HAVE_GETPWUID 1
#define HAVE_GETRUSAGE 1
#define HAVE_GETTIMEOFDAY 1
#define HAVE_GRP_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_LANGINFO_H 1
#define HAVE_NL_LANGINFO 1
#define HAVE_NETINET_IN_H 1
#define HAVE_POLL_H 1
#define HAVE_POLL 1
#define HAVE_PWD_H 1
#define HAVE_SIGNAL_H 1
#define HAVE_SYS_RESOURCE_H 1
#define HAVE_TERMIOS_H 1
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
#define HAVE_SYS_TIMES_H 1
#define HAVE_TIMES 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_SYS_UN_H 1
#define HAVE_SYS_WAIT_H 1
#define HAVE_SYS_PARAM_H 1
#define HAVE_UNISTD_H 1
#define HAVE_FCNTL 1
#define HAVE_FCNTL_H 1
#define HAVE_FSYNC 1
#define HAVE_FTRUNCATE 1
#define HAVE_GETUID 1
#define HAVE_GETEUID 1
#define HAVE_GETGID 1
#define HAVE_GETEGID 1
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
#define HAVE_CLOCK_GETTIME 1
#define HAVE_CLOCK_REALTIME 1
#define HAVE_TM_GMTOFF 1
#define HAVE_BACKTRACE 1
#define HAVE_UNIX_DNS_SRV 1
#define HAVE_U_INT32_T 1
#define HAVE_WCSDUP 1
#define TIME_WITH_SYS_TIME 1
#define HAVE_VISIBILITY_HIDDEN 1
#define HAVE_BUILTIN_EXPECT 1
#define HAVE_BUILTIN_UNREACHABLE 1
#define HAVE_GCC_SYNC_BUILTINS 1
#endif

#endif /* MY_CONFIG_H */
