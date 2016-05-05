Debugging with tcpdump and other tools
================================================================================

Installing tcpdump
--------------------------------------------------------------------------------

Pushing the binary to an existing device

Download tcpdump from http://www.tcpdump.org/, then execute:

```
adb root
adb remount
adb push /wherever/you/put/tcpdump /system/xbin/tcpdump
adb shell chmod 6755 /data/local/tmp/tcpdump
```

Including tcpdump in the build image

If you are running your own build, execute:

```
mmm external/tcpdump  # install the binary in out/.../system/xbin
make snod             # build a new system.img that includes it
```

Flash the device as usual, for example, fastboot flashball.

If you want to build tcpdump by default, add CUSTOM_TARGETS += tcpdump to your buildspec.mk.
Running tcpdump

You need to have root access on your device.
Batch mode capture

The typical procedure is to capture packets to a file and then examine the file on the desktop, as illustrated below:

```
adb shell tcpdump -i any -p -s 0 -w /sdcard/capture.pcap
# "-i any": listen on any network interface
# "-p": disable promiscuous mode (doesn't work anyway)
# "-s 0": capture the entire packet
# "-w": write packets to a file (rather than printing to stdout)
```
   ...
do whatever you want to capture, then ^C to stop it ...

```
adb pull /sdcard/capture.pcap .
sudo apt-get install wireshark  # or ethereal, if you're still on dapper
wireshark capture.pcap          # or ethereal
```

   ... look at your packets and be wise ...

You can run tcpdump in the background from an interactive shell or from Terminal. By default,
tcpdump captures all traffic without filtering. If you prefer, add an expression like port 80 to the tcpdump command line.
Real time packet monitoring

Execute the following if you would like to watch packets go by rather than capturing them to a file (-n skips DNS lookups. -s 0 captures the entire packet rather than just the header):

```
adb shell tcpdump -n -s 0
```

Typical tcpdump options apply. For example, if you want to see HTTP traffic:

```
adb shell tcpdump -X -n -s 0 port 80
```

You can also monitor packets with wireshark or ethereal, as shown below:

# In one shell, start tcpdump.
```
adb shell "tcpdump -n -s 0 -w - | nc -l -p 11233"
```

# In a separate shell, forward data and run ethereal.
```
adb forward tcp:11233 tcp:11233 && nc 127.0.0.1 11233 | ethereal -k -S -i -
```

Note that you can't restart capture via ethereal. If anything goes wrong, you will need to rerun both commands.

For more immediate output, add -l to the tcpdump command line, but this can cause adb to choke (it helps to use a
nonzero argument for -s to limit the amount of data captured per packet; -s 100 is sufficient if you just want to see headers).
Disabling encryption

If your service runs over https, tcpdump is of limited use. In this case, you can rewrite some service URLs to use http, for example:

```
vendor/google/tools/override-gservices url:calendar_sync_https_proxy \
  https://www.google.com/calendar rewrite http://android.clients.google.com/proxy/calendar
```

Other network debugging commands
On the device:

```
    ifconfig interface: note that unlike Linux, you need to give ifconfig an argument
    netcfg: lists interfaces and IP addresses
    iftop: like top for network
    route: examine the routing table
    netstat: see active network connections
    nc: netcat connection utility
```

On the desktop:

    curl: fetch URLs directly to emulate device requests
