#include <mysql.h>

int main() {
  // 固定上游 ABI 版本，防止提取脚本混入其他 MySQL 版本的生成头。
  static_assert(MYSQL_VERSION_ID == 80406);
  if (mysql_get_client_version() != 80406) return 1;

  MYSQL *client = mysql_init(nullptr);
  if (client == nullptr) return 2;
  mysql_close(client);
  return 0;
}
