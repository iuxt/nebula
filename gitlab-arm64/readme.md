构建arm64镜像的作者仓库，以及流水线
https://git.yrzr.tk/docker/gitlab-ce-arm64/-/pipelines


初始账号root

初始密码

```bash
docker exec gitlab-ce bash -c "cat /etc/gitlab/initial_root_password"
```


修改ssh port

vim conf/gitlab.rb

```bash
gitlab_rails['gitlab_shell_ssh_port'] = 2222
```
