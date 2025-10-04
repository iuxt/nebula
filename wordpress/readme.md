
wordpress 官方镜像 使用的用户id 是 33

```bash
sudo chown -R 33:33 data/
```

## 关闭WordPress自动更新

在 data/wp-config.php 文件中，增加以下两行代码，位置建议放在 /* That's all, stop editing! Happy publishing. */ 之前。

```php
define('AUTOMATIC_UPDATER_DISABLED', true); // 禁用所有类型的自动更新
define('WP_AUTO_UPDATE_CORE', false); // 禁用核心程序的自动更新
```
