Automake -- helloworld
========================================

Summary
----------------------------------------

首先简略的说一下用automake生成Makefile的步骤：
1. 创建源代码文件，使用”autoscan”生成configure.scan文件，将其重命名为configure.ac，并做适当修改，
2. 然后使用”aclocal”命令生成aclocal.m4文件.
3. 使用”autoconf”命令由configure.ac和aclocal.m4文件生成configure文件。
4. 手工编辑Makefile.am文件，使用”automake”命令生成configure.in文件。
5. 手工编辑或由系统给定acconfig.h文件，使用”autoheader”命令生成config.h.in文件。
6. 使用”configure”命令由configure、configure.in和config.h.in文件生成Makefile文件。

从而完成Makefile文件的创建过程。

Steps
----------------------------------------

1. 使用autoscan工具生成configure.scan文件

Autoscan工具用来扫描源代码以搜寻一般的可移植性问题，比如检查编译器、库和头文件等，
并创建configure.scan文件，它会在给定目录及其子目录树中检查源文件，若没有给出目录，
就在当前目录及其子目录树中进行检查。

```
$ autoscan
$ ls
autoscan.log  configure.scan  helloworld.c  Makefile.am  README.md
```

$ cat configure.scan
```
#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([FULL-PACKAGE-NAME], [VERSION], [BUG-REPORT-ADDRESS])
AC_CONFIG_SRCDIR([helloworld.c])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CC

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
```

下面给出本文件的简要说明（所有以”#”号开始的行为注释）：
(1). AC_PREREQ宏声明本文件要求的autoconf版本，本例使用的版本为2.69.
(2). AC_INIT宏用来定义软件的名称和版本等信息，”FULL-PACKAGE-NAME”为软件包名称，
     ”VERSION”为软件版本号，”BUG-REPORT-ADDRESS”为BUG报告地址.
(3). AC_CONFIG_SRCDIR宏用来侦测所指定的源码文件是否存在，来确定源码目录的有效性。
     此处为当前目录下的hello.c。
(4). AC_CONFIG_HEADER宏用于生成config.h文件，以便autoheader使用。
(5). AC_PROG_CC用来指定编译器，如果不指定，选用默认gcc。
(6). AC_OUTPUT用来设定 configure 所要产生的文件，如果是makefile，configure
     会把它检查出来的结果带入makefile.in文件产生合适的makefile。使用Automake时，
     还需要一些其他的参数，这些额外的宏用aclocal工具产生。

此文件只是下面要使用的configure.ac文件的原型,当然我们还要对其做一定的修改：

$ cp configure.scan configure.ac
```
#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([hello], [1.0], [yudatun@gmail.com])
AM_INIT_AUTOMAKE([hello], [1.0])
AC_CONFIG_SRCDIR([helloworld.c])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CC

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

#AC_CONFIG_FILES([Makefile])
AC_OUTPUT([Makefile])
```

2．使用aclocal工具生成aclocal.m4
aclocal根据configure.ac生成aclocal.m4

```
$ aclocal
$ ls
aclocal.m4      autoscan.log  configure.scan  Makefile.am
autom4te.cache  configure.ac  helloworld.c    README.md
```

3．使用autoconf工具生成configure文件
将configure.ac中的宏展开，生成configure脚本。这个过程可能要用到aclocal.m4中定义的宏。

```
$ autoconf
$ ls
aclocal.m4      autoscan.log  configure.ac    helloworld.c  README.md
autom4te.cache  configure     configure.scan  Makefile.am
```

4. 使用autoheader 工具生成 config.h config.h.in

```
$ autoheader
$ ls
aclocal.m4      autoscan.log  configure     configure.scan  Makefile.am
autom4te.cache  config.h.in   configure.ac  helloworld.c    README.md
```

5. 创建Makefile.am文件

Automake工具会根据configure.in中的参量把Makefile.am转换成Makefile.in文件。
所以在使用automake之前我们需要自己创建Makefile.am文件

```
AUTOMAKE_OPTIONS=foreign
bin_PROGRAMS=hello
hello_SOURCES=helloworld.c
```

其中：

(1). AUTOMAKE_OPTIONS为设置automake的选项。由于GNU对自己发布的软件有严格的规范，比如必须附带
     许可证声明文件COPYING等，否则automake执行时会报错。automake提供了3种软件等级：
     foreign、gnu和gnits，供用户选择，默认等级为gnu。本例使需用foreign等级，它只检测必须的文件。
(2). bin_PROGRAMS定义要产生的执行文件名。如果要产生多个执行文件，每个文件名用空格隔开。
(3). hello_SOURCES定义”hello”这个执行程序所需要的原始文件。如果”hello”这个程序是由多个原始文件
     所产生的，则必须把它所用到的所有原始文件都列出来，并用空格隔开。
     例如：若目标体”hello”需要”hello.c”、”hello.h”两个依赖文件，则定义
     hello_SOURCES=hello.c hello.h。

6．使用automake生成Makefile.in文件
下面使用automake生成”Makefile.in”文件，使用选项”--add-missing”可以让automake
自动添加一些必需的脚本文件。如下所示：

```
$ automake --add-missing
configure.ac:6: warning: AM_INIT_AUTOMAKE: two- and three-arguments forms are deprecated.  For more info, see:
configure.ac:6: http://www.gnu.org/software/automake/manual/automake.html#Modernize-AM_005fINIT_005fAUTOMAKE-invocation
configure.ac:11: installing './compile'
configure.ac:6: installing './install-sh'
configure.ac:6: installing './missing'
Makefile.am: installing './depcomp'
$ ls
aclocal.m4      compile      configure.ac    helloworld.c  Makefile.in
autom4te.cache  config.h.in  configure.scan  install-sh    missing
autoscan.log    configure    depcomp         Makefile.am   README.md
```

7. 执行./configure 生成Makefile
