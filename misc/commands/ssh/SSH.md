ssh命令用于远程登录上Linux主机
========================================

常用格式：ssh [-l login_name] [-p port] [user@]hostname

更详细的可以用ssh -h查看。

举例
----------------------------------------

### 不指定用户：

```
$ ssh 192.168.0.11
```

### 指定用户：

```
$ ssh -l root 192.168.0.11
$ ssh root@192.168.0.11
```

### 如果修改过ssh登录端口的可以：

```
$ ssh -p 12333 192.168.0.11
$ ssh -l root -p 12333 216.230.230.114
$ ssh -p 12333 root@216.230.230.114
```

另外修改配置文件/etc/ssh/sshd_config，可以改ssh登录端口和禁止root登录。改端口可以防止被端口扫描。
编辑配置文件：

```
vim /etc/ssh/sshd_config
```

找到#Port 22，去掉注释，修改成一个五位的端口：

```
Port 12333
```

找到#PermitRootLogin yes，去掉注释，修改为：

PermitRootLogin no

### 重启sshd服务：

```
service sshd restart
```