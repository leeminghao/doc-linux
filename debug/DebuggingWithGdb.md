Debugging with GDB
================================================================================

The current version of envsetup.sh has a gdbclient command that handles much of the setup.
For example, to attach the already-running globaltime application, execute the following,
making sure that:
1) you do this from the same window used to build the software on the device you are debugging and
2) verify that the symbols in the object files in the build tree match up with what is installed on the device or emulator.

```
gdbclient app_process :5039 globaltime
```

Debugging
Short Instructions

Android runs gdbserver on the device and an ARM aware gdb, named arm-eabi-gdb, on the desktop machine.
    First you need to run gdbserver on the device:

```
          gdbserver :5039 /system/bin/executable
```

The :5039 tells gdbserver to listen on port 5039 on the localhost, which adb bridges from the host to the device.
executable represents the command to debug, a common one being runtime -s which starts the entire system all running in a single process.

Launch gdb on the desktop. This can be done easily with the following command in the shell from which you built:

```
    gdbclient executable
```

At this point gdb will connect with your device and you should be able to enter c to have the device start executing inside of the desktop gdb session.
Detailed Instructions

If the short instructions don't work, these detailed instructions should:

    On the device, launch a new command:

```
    gdbserver :5039 /system/bin/executable
```

    or attach to an existing process:

```
    gdbserver :5039 --attach pid
```

    On your workstation, forward port 5039 to the device with adb:

```
    adb forward tcp:5039 tcp:5039
```

    Start a special version of gdb that lives in the "prebuilt" area of the source tree:

```
    prebuilt/Linux/toolchain-eabi-4.2.1/bin/arm-eabi-gdb (for Linux)
    prebuilt/darwin-x86/toolchain-eabi-4.2.1/bin/arm-eabi-gdb (for Darwin)
```

    If you can't find either special version of gdb, run find prebuilt -name arm-eabi-gdb in your source tree to find and run the latest version:
    prebuilt/Linux/toolchain-eabi-4.2.1/bin/arm-eabi-gdb  out/target/product/product-name/symbols/system/bin/executable

    Where product-name is the name of the device product that you're building (for example, sooner), and executable is the program to debug (usually app_process for an application).

    Make sure to use the copy of the executable in the symbols directory, not the primary android directory, because the one in the primary directory has been stripped of its debugging information.
    In gdb, Tell gdb where to find the shared libraries that will get loaded:

```
    set solib-absolute-prefix /absolute-source-path/out/target/product/product-name/symbols
    set solib-search-path /absolute-source-path/out/target/product/product-name/symbols/system/lib
```

    absolute-source-path is the path to your source tree; for example, /work/device or /Users/hoser/android/device.
    product-name is the same as above; for example, sooner.

    Make sure you specify the correct directories—gdb may not tell you if you make a mistake.
    Connect to the device by issuing the gdb command:

```
    target remote :5039
```

    The :5039 tells gdb to connect to the localhost port 5039, which is bridged to the device by adb.
    You may need to inspire gdb to load some symbols by typing:
    shared

You should be connected and able to debug as you normally would. You can ignore the error about not finding the location for the thread creation breakpoint.
It will be found when the linker loads libc into your process before hitting main(). Also note that the gdb remote protocol doesn't have a way for the device
to tell the host about newly created threads so you will not always see notifications about newly created threads. Info about other threads will be queried
from the device when a breakpoint is hit or you ask for it by running info thread.

Just-In-Time Debug Feature

If you see the red LED flashing it means a process is in that new state (crashed and waiting for GDB connection).
If this happens to the system process, most likely your device will be frozen at this point. Do not press the home key.
Bring the device to someone who can debug native crashes and ask for advice. If you're in the field and just want your
device to continue as it would have without this feature (like cylonning), press home (a tombstone will be recorded as usual).
To enable a process to be debugged this way, you need to set a property:

```
adb shell setprop debug.db.uid 10000
```

and all processes with a uid <= 10000 will be trapped in this manner. When one of them crashes, the tombstone is processed as usual,
an explicit message is printed into the log, and the red LED starts flashing waiting for the Home key to be depressed (in which case it continues execution as usual).

I/DEBUG   (   27): ********************************************************
I/DEBUG   (   27): * process 82 crashed. debuggerd waiting for gdbserver
I/DEBUG   (   27): *
I/DEBUG   (   27): *     adb shell gdbserver :port --attach 82 &
I/DEBUG   (   27): *
I/DEBUG   (   27): * and press the HOME key.
I/DEBUG   (   27): ********************************************************

When you see the entry above, make sure adb is forwarding port 5039 (you only need to do this once, unless the ADB server dies) and execute:

```
% adb forward tcp:5039 tcp:5039
```

Execute the line shown in the debug output, substituting 5039 for the proper port:

```
% adb shell gdbserver :5039 --attach 82 &
```

If the crashing process is based off zygote (that is, system_server and all applications), the default values for the gdbclient command, app_process binary and port 5039, are correct, so you can execute:

```
% cd <top of device source tree>
% gdbclient
```

Otherwise you need to determine the path of the crashing binary and follow the steps as mentioned above (for example, gdbclient hoser :5039 if the hoser command has failed).
