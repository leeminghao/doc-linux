Misc
========================================

emacs
----------------------------------------

```
C-q C-j # 加入换行
```

git
----------------------------------------

```
git remote -v
git remote add pis ssh://git@git.mioffice.cn/mionew0/android/platform/frameworks/native
git push ssh://liminghao@git.xiaomi.com:29418/miui/bootable/recovery kk:远程分支名（比如l-alpha）

gerrit:
git push ssh://liminghao@git.xiaomi.com:29418/device/qcom/sepolicy HEAD:refs/for/v7-m-land-dev
```


X7 Build
----------------------------------------

### Build kernel

如果更改了device tree，需要先 rm out/target/product/msm8994/dt.img 然后make kernel –j8，因为如果不rm dt.img，
device tree不会被更新 make的方法也变了，make kernel而不是make bootimage。因为后者不是signed kernel.前者可

### Build aboot

Make aboot 以后需要make gensecimage_target -j16 因为需要sign一下aboot

beyond
----------------------------------------

```
$ rm -rf ~/.beyondcompare
```

verify key
----------------------------------------

```
$ jarsigner -verify -verbose -certs Superuser.apk
```

format
----------------------------------------

```
make_ext4fs -s -S out/target/product/pisces/root/file_contexts -l 268435456 -a storage out/target/product/pisces/storage.img out/target/product/pisces/storage
simg2img out/target/product/pisces/storage.img out/target/product/pisces/unsparse_storage.img
e2fsck -f -n out/target/product/pisces/unsparse_storage.img
```

查看进程切换trace
----------------------------------------

```
enable schedule switch tracing:
# echo 1 > /d/tracing/events/sched/sched_switch/enable
disable schedule switch tracing:
# echo 0 > /d/tracing/events/sched/sched_switch/enable
get tracing log:
# cat /d/tracing/trace
```

打开adb
----------------------------------------

```
persist.service.adb.enable
```

Get package name
----------------------------------------

```
pm list packages -f | grep vending
```

查看进程占用的端口号
----------------------------------------

```
busybox netstat -apn
```

mount
----------------------------------------

```
$ mount -o loop -t iso9660 /home/sunky/mydisk.iso /mnt/vcdrom
$ mount -wo remount rootfs /
```

tcpdump
----------------------------------------

```
$ tcpdump -i any -p -s 0 -w /sdcard/netCapture.pcap
```

hosts
----------------------------------------

```
git clone https://code.google.com/p/ipv6-hosts/
```

build adb
----------------------------------------

```
$ make USE_MINGW=y adb
$ make USE_MINGW=y fastboot
```

Android Cts knwonfailures.txt
----------------------------------------

http://androidxref.com/4.4_r1/xref/cts/tests/expectations/knownfailures.txt

ota
----------------------------------------

```
# ota -i /sdcard/update.zip /cache/ota_update.log 1 stdout
```


$ make target-files-package
$ ./build/tools/releasetools/ota_from_target_files -i ~/armani-target_files-eng.liminghao01.zip ~/armani-target_files-eng.liminghao.zip ota.zip
$ ./build/tools/releasetools/ota_from_target_files -n out/target/product/cancro/obj/PACKAGING/target_files_intermediates/cancro-target_files-eng.liminghao.zip ota.zip

debugfs
----------------------------------------

```
# mount -o remount,passwd=*#*#MiPhone#*#* -t debugfs debugfs
```

start activity
----------------------------------------

```
mdb shell am start com.android.settings/.MiuiSettings
mdb shell am startservice com.google.android.inputmethod.pinyin/.PinyinIME
adb shell am start com.jingdong.app.mall/com.jingdong.common.phonecharge.calendar.AlamrActivity
```

gerrit
----------------------------------------

```
$ git push origin HEAD:refs/for/master
```

Google手机版本
----------------------------------------

```
https://developers.google.com/android/nexus/images
https://developers.google.com/android/nexus/images
```

adb
----------------------------------------

```
$ adb logcat -v threadtime 2>&1 | tee log.txt
$ java –jar chkbugreport.jar bugreport.txt
$ adb shell monkey -v --throttle 200 -p com.androidesk 200000
$ adb shell kill -s SIGQUIT # 抓单个APP堆栈
```

zip
----------------------------------------

```
zip -r filename.zip file1 file2 file3 /usr/work/school
zip -r wt98007.zip *.bin EBR* *.img *.ini *.txt MBR kernel
```

proxy
----------------------------------------

```
export https_proxy=https://p.pt.xiaomi.com:3128
export http_proxy=http://p.pt.xiaomi.com:3128
repo init -u https://android.googlesource.com/platform/manifest
```

APK 签名网站: http://sign.n.miui.com/

scp
----------------------------------------

设有两机，均为局域网，两机可相互通信无问题，中间无防火墙。
两机IP分别为：A:192.168.1.240 B:192.168.1.102
假设A，B机的SSH都允许root登录
设要把 A上的 /root/abc.zip 传到 B机并放到/abc目录，可以在A机上用命令
# scp  /root/abc.zip  root@192.168.1.102:/abc/
若 SSH端口不是默认的22，比如，是端口1234 则加-P参数：
# scp  -P 1234 /root/abc.zip  root@192.168.1.102:/abc/
也可以在B机上用命令：
# scp  root@192.168.1.240:/root/abc.zip  /abc/

将手机USB加入访问规则
----------------------------------------

http://files.xiaomi.com/xmg/%E9%85%8D%E7%BD%AEUSB%E8%AE%BE%E5%A4%87
1.lsusb 查看现有列表
2.插入手机
3.lsusb 查看更新后的列表，找到手机对应的USB信息
4.sudo gedit /etc/udev/rules.d/99-android.rules
  从以前的记录中新加入一行
  将ID中冒号前的数值写入idVendor == 后边面的字串；
  将ID中冒号后的数值写入idProduct == 后面的子窜
  保存文档退出
5.sudo restart udev
  adb kill-server
  拔掉USB设备，并重新插上
6.adb devices 查看是否正确识别了数据
7.cat /etc/udev/rules.d/51-android.rules
SUBSYSTEM=="usb", MODE="0666"

lint
----------------------------------------

```
lint --html /tmp/report.html --disable MissingTranslation  DeskClock
```

gdb
----------------------------------------

1. . build/envsetup.sh
2. lunch 31
   adb root
3. gdbclient app_process :5309 flipboard.cn  flipboard.cn为进程名，或写进程号也行，5309为端口号,
info b 查看当前断点
b 在当前行设置断点
d 1 删除1号断点
c 继续程序执行
bt 查看调用栈
condition 1 n >= 3520016 断点条件
where 查看调用栈

Using ccache
----------------------------------------

ccache is a compiler cache for C and C++ that can help make builds faster. In the root of the source tree, do the following:
```
$ export USE_CCACHE=1
$ export CCACHE_DIR=/<path_of_your_choice>/.ccache
$ prebuilt/linux-x86/ccache/ccache -M 20G
```
You can watch ccache being used by doing the following:
$ watch -n1 -d prebuilt/linux-x86/ccache/ccache -s

反汇编boot.img
----------------------------------------

```
$ unpackbootimg -i boot.img
$ mkdir ramdisk
$ cd ramdisk
$ gzip -dc ../boot.img-ramdisk.gz | cpio -i
$ cd ..
$ mkbootfs ramdisk | gzip > ramdisk-new.gz
$ mkbootimg --cmdline 'console=ttyHSL0 androidboot.hardware=pyramid no_console_suspend=1' --kernel boot.img-zImage --ramdisk ramdisk-new.gz --base 0x48000000 --pagesize 2048 -o boot-new.img
```

mount system.img
----------------------------------------

```
1. mkdir sys
2. ./simg2img system.img sys.raw
3. sudo mount -t ext4 -o loop sys.raw sys/
```

ssh
----------------------------------------

```
$ ssh guest@10.237.14.123

# Start the ssh-agent in the background

$ eval "$(ssh-agent -s)"

# Add your SSH key to the ssh-agent:

$ ssh-add ~/.ssh/id_rsa
```

java
----------------------------------------

```
$ ls -la /etc/alternatives/java* && ls -la /etc/alternatives/jar
$ sudo update-alternatives --config javac
$ sudo update-alternatives --config java
$ sudo update-alternatives --config javaws
$ sudo update-alternatives --config javap
$ sudo update-alternatives --config jar
$ sudo update-alternatives --config jarsigner
```