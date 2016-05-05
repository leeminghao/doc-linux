Problem

Affected versions:

Lotus Protector for Mail Security Firmware 2.8.1 / SLES 11

A bug in the Linux kernel causes the kernel swapper daemon (kswapd) to start
consuming all available CPU resources for an indefinite period of time if the following conditions are met:

- The system is equipped with 4GB of RAM or more
- The system is under high load for a prolonged period of time

The problem becomes more likely to occur the more RAM the system has installed.
The problem mainly occurs on virtualized hardware such as VMWare but can rarely also occur on physical hardware.

This problem is neither restricted to the product itself nor the Linux distribution it is based upon (see external references).

Symptom

If the issue occurs the system stops being responsive and running "top" reveals one or more kswapd processes (depending on number of CPU cores) are running at 99% CPU usage the entire time. Other processes, such as the mailsec binary, will not receive the necessary CPU cycles to run and appear to be hanging or crash

Resolving the problem

At the time of writing there was no fix available.


If the issue is currently present one can usually solve it by stopping resource-intensive processes, such as the mailsec binary, to allow the kswapd to settle down.
Some users report having the kernel drop the caches also seems to fix the issue temporarily. To drop the caches run as "root" on the shell:

"echo 1 > /proc/sys/vm/drop_caches"


If this does not work a reboot of the system is required to restore functionality.
The likelihood of occurrence can be decreased significantly by reducing the amount of RAM installed/available to the machine to 4 GB or less.
If currently running on virtualized hardware migrating to physical hardware can also lower the likelihood of occurrence.
