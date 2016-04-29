Linux下设置CPU核心数和频率
========================================

现在的Android手机双核、四核变得非常普遍，同时CPU频率经常轻松上2G，功耗肯定会显著增加。
而大多数的ARM架构的CPU采用的是对称多处理（SMP）的方式处理多CPU。这就意味着每个CPU核心
是被平等对待的，同时打开又同时关闭。显然，这样的做法在Mobile Device上显得很耗能。
所以，Qualcomm的Snapdragon CPU使用了一种叫非对称多处理（aSMP）的技术，每个CPU核心
可以独立的开启和关闭，也能设置不同的频率。因此，针对使用Snapdragon CPU的Android手机，
我们可以通过限制CPU核心数或者限制CPU的频率达到节能的目的。

关闭mpdecision
----------------------------------------

Snapdragon有一个叫做mpdecision的程序管理CPU各个核心的开、关和频率。所以如果想手动开关
CPU的核心或者设置CPU核心的频率就必须把这个程序关闭。

stop mpdecision
需要注意的是，这个程序会在每次启动后执行，所以每次重启后都需要重新执行上面的命令停止mpdecisiopn。

设置CPU的核心数
----------------------------------------

在/sys/devices/system/cpu目录下可以看到你的CPU有几个核心，如果是双核，就是cpu0和cpu1，
如果是四核，还会加上cpu2和cpu3。随便进一个文件夹，比如cpu1，里面有个online文件。
我们可以用cat命令查看该文件的内容

```
# cat /sys/devices/system/cpu/cpu1/online
```

这个文件只有一个数字，0或1。0表示该核心是offline状态的，1表示该核心是online状态的。
所以，如果你想关闭这个核心，就把online文件的内容改为“0”；如果想打开该核心，就把文件内容改为“1”。

```
# echo "0" > /sys/devices/system/cpu/cpu1/online # 关闭该CPU核心
# echo "1" > /sys/devices/system/cpu/cpu1/online # 打开该CPU核心
```

还能通过设置掩码mask值来设定:

假设要关闭cpu3,可以如下设置.

```
# echo 8 > /sys/module/msm_thermal/core_control/cpus_offlined
```

设置CPU的频率
----------------------------------------

首先我们要修改governor的模式，但在修改前需要查下CPU支持哪些governor的模式

```
# cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
interactive ondemand userspace powersave performance
```

* performance表示不降频
* ondemand表示使用内核提供的功能，可以动态调节频率.
* powersvae表示省电模式，通常是在最低频率下运行
* userspace表示用户模式，在此模式下允许其他用户程序调节CPU频率。

在这里，我们将模式调整为“userspace”。

```
# echo "userspace" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

然后我们对CPU的频率进行修改，CPU的频率不是可以任意设置的，需要查看scaling_available_frequencies
文件，看CPU支持哪些频率。

```
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
384000 486000 594000 702000 810000 918000 1026000 1134000 1242000 1350000 1458000 1512000
```

这里的频率是以Hz为单位的，我准备将cpu0设置为1.242GHz，那就将1242000写入scaling_setspeed即可。

```
# echo "1242000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
```

设置好后，我们可以通过scaling_cur_freq文件查看当前这个核心的频率

```
# cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
```

最后我们也可以设置下CPU的最大和最小频率，只需要将需要设置的频率值写入
scaling_max_freq和scaling_min_freq即可

```
# echo "1350000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq # 设置最大频率
# echo "384000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq # 设置最小频率
```

这里要注意的是“最大值”需要大于等于“最小值”。

注意，这里设置的仅为某个CPU核心的频率，你需要对每个online的CPU核心都进行设置，
同时以上对文件的修改均需要root权限。

通过减少online的核心数和限制CPU频率固然可以起到节省电量的目的，但是性能也是显著降低，
所以需要做一个权衡。