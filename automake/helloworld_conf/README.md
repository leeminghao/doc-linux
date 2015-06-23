Automake -- have sub directories.
========================================

Construction
----------------------------------------

```
liminghao@liminghao:~/big/leeminghao/doc-linux/automake/helloworld_conf$ ls */
conf/:

src/:
helloworld.c
```

Steps:
----------------------------------------

1. 执行autoscan命令

```
$ autoscan
$ ls
autoscan.log  conf  configure.scan  README.md  src
```

2. configure.scan --> configure.ac

```
$ cp configure.scan configure.ac
$ cat configure.ac
#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([hello], [1.0], [yudatun@gmail.com])
AM_INIT_AUTOMAKE([hello], [1.0])
AC_CONFIG_SRCDIR([src/helloworld.c])
#AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CC

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_OUTPUT([Makefile src/Makefile conf/Makefile])
```

3. aclocal --> aclocal.m4

```
$ aclocal
$ ls
aclocal.m4  autom4te.cache  autoscan.log  conf  configure.ac  configure.scan  README.md  src
```

4. autoconf

```
$ autoconf
$ ls
aclocal.m4      autoscan.log  configure     configure.scan  src
autom4te.cache  conf          configure.ac  README.md
```

5. Makefile.am

```
helloworld_conf$ cat Makefile.am
SUBDIRS=src conf

helloworld_conf/src$ cat Makefile.am
bin_PROGRAMS=hello
hello_SOURCES=helloworld.c

helloworld_conf/conf$ cat Makefile.am
configdir=/etc # 这个数据文件将要移动到的目录
config_DATA=test.conf # 数据文件名，如果有多个文件则这样写config_DATA = test1.dat test2.dat
```

6. automake

```
helloworld_conf$ automake --add-missing
configure.ac:6: warning: AM_INIT_AUTOMAKE: two- and three-arguments forms are deprecated.  For more info, see:
configure.ac:6: http://www.gnu.org/software/automake/manual/automake.html#Modernize-AM_005fINIT_005fAUTOMAKE-invocation
configure.ac:11: installing './compile'
configure.ac:6: installing './install-sh'
configure.ac:6: installing './missing'
Makefile.am: installing './INSTALL'
Makefile.am: error: required file './NEWS' not found
Makefile.am: error: required file './README' not found
Makefile.am: error: required file './AUTHORS' not found
Makefile.am: error: required file './ChangeLog' not found
Makefile.am: installing './COPYING' using GNU General Public License v3 file
Makefile.am:     Consider adding the COPYING file to the version control system
Makefile.am:     for your code, to avoid questions about which license your project uses
configure.ac:8: error: required file 'config.h.in' not found
src/Makefile.am: installing './depcomp'
helloworld_conf$ touch NEWS README AUTHORS ChangeLog
helloworld_conf$ ls
aclocal.m4      autoscan.log  conf          configure.scan  INSTALL      missing  README.md
AUTHORS         ChangeLog     configure     COPYING         install-sh   NEWS     src
autom4te.cache  compile       configure.ac  depcomp         Makefile.am  README
helloworld_conf$ automake
configure.ac:6: warning: AM_INIT_AUTOMAKE: two- and three-arguments forms are deprecated.  For more info, see:
configure.ac:6: http://www.gnu.org/software/automake/manual/automake.html#Modernize-AM_005fINIT_005fAUTOMAKE-invocation
```
