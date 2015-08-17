Uboot Kbuild  -- vexpress_ca9x4_defconfig
============================================================

General:
------------------------------------------------------------

```
$ make ARCH=arm CROSS_COMPILE=arm-eabi- vexpress_ca9x4_defconfig
$ make ARCH=arm CROSS_COMPILE=arm-eabi-
```

Config:
------------------------------------------------------------

make ARCH=arm CROSS_COMPILE=arm-eabi- vexpress_ca9x4_defconfig

配置过程如下所示:

path: Makefile
```
%config: scripts_basic outputmakefile FORCE
	+$(Q)$(CONFIG_SHELL) $(srctree)/scripts/multiconfig.sh $@
```

接着执行multiconfig.sh脚本文件来进行配置:

path: scripts/multiconfig.sh
```
progname=$(basename $0)
target=$1

case $target in
*_defconfig)
	do_board_defconfig $target;;
...
```

调用do_board_defconfig函数来完成defconfig的配置工作.

path: scripts/multiconfig.sh
```
# Usage:
#  do_board_defconfig <board>_defconfig
do_board_defconfig () {
	defconfig_path=$srctree/configs/$1
	tmp_defconfig_path=configs/.tmp_defconfig

	if [ ! -r $defconfig_path ]; then
		echo >&2 "***"
		echo >&2 "*** Can't find default configuration \"configs/$1\"!"
		echo >&2 "***"
		exit 1
	fi

	mkdir -p arch configs
	# defconfig for Normal:
	#  pick lines without prefixes and lines starting '+' prefix
	#  and rip the prefixes off.
	sed -n -e '/^[+A-Z]*:/!p' -e 's/^+[A-Z]*://p' $defconfig_path \
						> configs/.tmp_defconfig

	run_make_config .tmp_defconfig || {
		cleanup_after_defconfig
		exit 1
	}

	for img in $(get_enabled_subimages)
	do
		symbol=$(echo $img | cut -c 1 | tr '[a-z]' '[A-Z]')
		# defconfig for SPL, TPL:
		#   pick lines with 'S', 'T' prefix and rip the prefixes off
		sed -n -e 's/^[+A-Z]*'$symbol'[A-Z]*://p' $defconfig_path \
						> configs/.tmp_defconfig
		run_make_config .tmp_defconfig $img || {
			cleanup_after_defconfig
			exit 1
		}
	done

	cleanup_after_defconfig
}
```

文件.tmp_defconfig如下所示:
```
CONFIG_ARM=y
CONFIG_TARGET_VEXPRESS_CA9X4=y
```

主要的配置工作在run_make_config函数中完成，如下所示：

path: scripts/multiconfig.sh
```
# Useful shorthands
build () {
	debug $progname: $MAKE -f $srctree/scripts/Makefile.build obj="$@"
	$MAKE -f $srctree/scripts/Makefile.build obj="$@"
}

...

# Make a configuration target
# Usage:
#   run_make_config <target> <objdir>
# <target>: Make target such as "config", "menuconfig", "defconfig", etc.
# <objdir>: Target directory where the make command is run.
#           Typically "", "spl", "tpl" for Normal, SPL, TPL, respectively.
run_make_config () {
	target=$1
	objdir=$2

	# Linux expects defconfig files in arch/$(SRCARCH)/configs/ directory,
	# but U-Boot has them in configs/ directory.
	# Give SRCARCH=.. to fake scripts/kconfig/Makefile.
	options="SRCARCH=.. KCONFIG_OBJDIR=$objdir"
	if [ "$objdir" ]; then
		options="$options KCONFIG_CONFIG=$objdir/$KCONFIG_CONFIG"
		mkdir -p $objdir
	fi

	build scripts/kconfig $options $target
}
```

接下来执行Makefile.build make脚本文件，参数为obj="scripts/kconfig $options $target"

path: scripts/Makefile.build
```
# Modified for U-Boot
prefix := tpl
src := $(patsubst $(prefix)/%,%,$(obj))
...
# The filename Kbuild has precedence over Makefile
kbuild-dir := $(if $(filter /%,$(src)),$(src),$(srctree)/$(src))
kbuild-file := $(if $(wildcard $(kbuild-dir)/Kbuild),$(kbuild-dir)/Kbuild,$(kbuild-dir)/Makefile)
include $(kbuild-file)
```

最终，include进scripts/kconfig/Makefile文件寻找到最终目标，如下所示：

path: scripts/kconfig/Makefile
```
ifdef KBUILD_KCONFIG
Kconfig := $(KBUILD_KCONFIG)
else
Kconfig := Kconfig
endif
...
# 其中conf是通过scripts/Makefile.host文件build出来的.
%_defconfig: $(obj)/conf
	$(Q)$< --defconfig=arch/$(SRCARCH)/configs/$@ $(Kconfig)
```

最终所有配置信息将保存在.config文件中.

Make -- u-boot:
------------------------------------------------------------

path: Makefile
```
libs-y		:= $(patsubst %/, %/built-in.o, $(libs-y))
...
u-boot-main := $(libs-y)
...
# Rule to link u-boot
# May be overridden by arch/$(ARCH)/config.mk
quiet_cmd_u-boot__ ?= LD      $@
      cmd_u-boot__ ?= $(LD) $(LDFLAGS) $(LDFLAGS_u-boot) -o $@ \
      -T u-boot.lds $(u-boot-init)                             \
      --start-group $(u-boot-main) --end-group                 \
      $(PLATFORM_LIBS) -Map u-boot.map
...
u-boot:	$(u-boot-init) $(u-boot-main) u-boot.lds
	$(call if_changed,u-boot__)
ifeq ($(CONFIG_KALLSYMS),y)
	$(call cmd,smap)
	$(call cmd,u-boot__) common/system_map.o
endif
...
u-boot.bin: u-boot FORCE
	$(call if_changed,objcopy)
	$(call DO_STATIC_RELA,$<,$@,$(CONFIG_SYS_TEXT_BASE))
	$(BOARD_SIZE_CHECK)
...
# Always append ALL so that arch config.mk's can add custom ones
ALL-y += u-boot.srec u-boot.bin System.map binary_size_check
...
all:		$(ALL-y)
...
```

Supplements:
------------------------------------------------------------

### if_changed

path: scripts/Kbuild.include
```
###
# Name of target with a '.' as filename prefix. foo/bar.o => foo/.bar.o
dot-target = $(dir $@).$(notdir $@)
...
# 代表规则中的目标文件名。如果目标是一个文档(Linux中,一般称.a文件为文档),那么
# 它代表这个文档的文件名。在多目标的模式规则中,它代表的是哪个触发规则被执行的目标文件名。
ifneq ($(KBUILD_NOCMDDEP),1)
# Check if both arguments has same arguments. Result is empty string if equal.
# User may override this check using make KBUILD_NOCMDDEP=1
arg-check = $(strip $(filter-out $(cmd_$(1)), $(cmd_$@)) \
                    $(filter-out $(cmd_$@),   $(cmd_$(1))) )
else
arg-check = $(if $(strip $(cmd_$@)),,1)
endif

# Find any prerequisites that is newer than target or that does not exist.
# PHONY targets skipped in both cases.
# $?: 所有比目标文件更新的依赖文件列表,空格分割.如果目标是静态库文件名,
#     代表的是库成员(.o文件)的更新情况.
# $^: 规则的所有依赖文件列表,使用空格分隔。如果目标是静态库文件名,它所代表的只能是
#     所有库成员(.o文件)名。一个文件可重复的出现在目标的依赖中,变量“$^”只记录它的
#     一次引用情况。就是说变量“$^”会去掉重复的依赖文件。
any-prereq = $(filter-out $(PHONY),$?) $(filter-out $(PHONY) $(wildcard $^),$^)

# Execute command if command has changed or prerequisite(s) are updated.
#
if_changed = $(if $(strip $(any-prereq) $(arg-check)),                       \
	@set -e;                                                             \
	$(echo-cmd) $(cmd_$(1));                                             \
	printf '%s\n' 'cmd_$@ := $(make-cmd)' > $(dot-target).cmd)
```

* if_changed函数在当发现规则的依赖有更新，或是目依赖不存在时，再或者是对应目标的命令行参数发生
  改变时($(strip $(any-prereq) $(arg-check)) 语句结果不为空)，执行后面的语句
* set -e表示如果命令执行有错那么命令停止执行并退出.
* 接着$(echo-cmd)用来打印出相关的编译命令，接着执行$(cmd_$(1)里的命令。
* 最后 echo 'cmd_$@ := $(make-cmd)' > $(dot-target).cmd 将上面执行的命令写入一个叫
  $(dot-target).cmd 的文件中，该文件为隐藏文件，在编译后的内核源码目录及其子目录下随处可见.

### echo_cmd

path: scripts/Kbuild.include

```
squote  := '
...
###
# Escape single quote for use in echo statements
escsq = $(subst $(squote),'\$(squote)',$1)
...
# echo command.
# Short version is used, if $(quiet) equals `quiet_', otherwise full one.
echo-cmd = $(if $($(quiet)cmd_$(1)),\
	echo '  $(call escsq,$($(quiet)cmd_$(1)))$(echo-why)';)

# printing commands
cmd = @$(echo-cmd) $(cmd_$(1))
```

* $(quiet)

上面的$(quiet)变量定义在顶层Makefile中：
在编译内核时,当不指定V变量时,$(quiet)就为quiet_. 一般的，编译的每个命令都定义有quiet_xxx
这种样式.

path: Makefile
```
ifeq ("$(origin V)", "command line")
  KBUILD_VERBOSE = $(V)
endif
ifndef KBUILD_VERBOSE
  KBUILD_VERBOSE = 0
endif

ifeq ($(KBUILD_VERBOSE),1)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif
...
```
