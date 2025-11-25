## nebula 项目说明

1. 自己的服务器上运行的一些开源项目。
2. 一些运维工程师日常用到的服务合集，主要是用于快速的搭建服务，有时候我们只是想要一个学习或者测试的环境，所以没有必要把时间浪费在如何搭建上面，这个项目就是一个快速搭建环境的集合。

## 安装docker
```bash
curl -fsSL get.docker.com | bash
```

## 关于配置文件

配置文件统一命名为 `.env` 第一次启动需要 `cp .env.example .env` 然后进行修改。

nginx配置文件为：nginx.conf 启动时会检测是否有自定义的custom_nginx.conf 如果没有则生成一个，后续需要修改nginx配置，直接编辑custom_nginx.conf


## 包含的组件


| 名称 | 说明 | 开源地址 |
|------|------|----------|
| aria2 | 一个下载工具 | https://github.com/aria2/aria2 |
| cloudreve | 一个开源的网盘工具 | https://github.com/cloudreve/cloudreve |
| code-server | vscode 网页版 | https://github.com/coder/code-server |
| consul | 注册中心，服务发现 | https://github.com/hashicorp/consul |
| docmost | 开源的在线文档/wiki | https://github.com/docmost/docmost |
| easytier | 去中心化VPN/组网工具 | https://github.com/EasyTier/EasyTier |
| Fail2ban | 可以通过检测日志来自动封禁恶意IP | https://github.com/fail2ban/fail2ban |
| Gitea | 一个git服务端，轻量化 | https://github.com/go-gitea/gitea |
| Gitlab-arm64 | Arm64版本的GitLab服务端 | https://gitlab.com/gitlab-org/gitlab |
| grafana | 开源的可视化和监控平台 | https://github.com/grafana/grafana |
| jenkins | 开源自动化服务器，用于CI/CD | https://github.com/jenkinsci/jenkins |
| kafka | 分布式流处理平台 | https://github.com/apache/kafka |
| minio | 高性能对象存储 | https://github.com/minio/minio |
| MySQL | 开源关系型数据库 | https://github.com/mysql/mysql-server |
| nginx | 高性能HTTP和反向代理服务器 | https://github.com/nginx/nginx |
| outline | 团队知识管理和协作平台 | https://github.com/outline/outline |
| php-fpm | PHP FastCGI进程管理器 | https://github.com/php/php-src |
| postgres | PostgreSQL关系型数据库 | https://github.com/postgres/postgres |
| public | 本项目的公共脚本， 比如创建docker网络，管理nginx配置文件等。 | - |
| redis | 内存数据结构存储 | https://github.com/redis/redis |
| registry | Docker镜像仓库 | https://github.com/distribution/distribution |
| rustdesk | 开源远程桌面软件 | https://github.com/rustdesk/rustdesk |
| tools | 小工具 | - |
| vaultwarden | Bitwarden密码管理器的轻量级实现 | https://github.com/dani-garcia/vaultwarden |
| wordpress | 开源内容管理系统 | https://github.com/WordPress/WordPress |
| xray | 网络扫描和安全评估工具 | https://github.com/chaitin/xray |
| xtemp | 文件中转站，支持curl | https://xtemp.babudiu.com/ |
| rustfs | 兼容S3协议的开源对象存储 | https://github.com/rustfs/rustfs |


详细说明请进入对应的文件夹查看说明或查看对应项目的官方文档


## Sponsor
The project is develop by [JetBrains Ide](https://www.jetbrains.com/?from=puck)

![JetBrains logo](https://resources.jetbrains.com/storage/products/company/brand/logos/jetbrains.png)