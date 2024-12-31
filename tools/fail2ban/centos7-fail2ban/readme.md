
```bash
systemctl disable --now firewalld
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/sysconfig/selinux && setenforce 0

yum install -y fail2ban

rm -f /etc/fail2ban/jail.d/00-firewalld.conf
```


vim /etc/fail2ban/jail.d/ssh.conf

```ini
[DEFAULT]
# Ban hosts for one hour:
bantime = 3600
# Override /etc/fail2ban/jail.d/00-firewalld.conf:
banaction = iptables-multiport

[sshd]
enabled = true
mode = aggressive
```

aggressive 配置是 为了将那些 使用错误key登录失败的一起禁用了。

