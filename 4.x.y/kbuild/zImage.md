zImage
========================================

zImage的生成过程可以由下图概括:

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/kbuild/res/zImage.gif

1.zImage
----------------------------------------

生成zImage文件的Makefile位于arch/arm下，它通过
include $(srctree)/arch/$(SRCARCH)/Makefile
被包含进主目录下的Makefie中。另外通过
include $(srctree)/scripts/Kbuild.include
一系列的通用编译器处理函数和变量被包含到主目录下的Makefile中。

根目录下的Makefile:

path: Makefile
```
...
# We need some generic definitions (do not try to remake the file).
$(srctree)/scripts/Kbuild.include: ;
include $(srctree)/scripts/Kbuild.include
...
include $(srctree)/arch/$(SRCARCH)/Makefile
...
```

用于生成zImage的Makefile中的依赖定义如下:

path: arch/arm/Makefile
```
...
# Default target when executing plain make
ifeq ($(CONFIG_XIP_KERNEL),y)
KBUILD_IMAGE := xipImage
else
KBUILD_IMAGE := zImage
endif
...
all:  $(KBUILD_IMAGE) $(KBUILD_DTBS)

boot := arch/arm/boot
...
BOOT_TARGETS = zImage Image xipImage bootpImage uImage
...
$(BOOT_TARGETS): vmlinux
	$(Q)$(MAKE) $(build)=$(boot) MACHINE=$(MACHINE) $(boot)/$@
...
```

由此可以看出zImage依赖于vmlinux文件。当然其他格式的Image文件也
无独有偶的源于vmlinux. 其编译过程如下所示:

https://github.com/leeminghao/doc-linux/blob/master/4.x.y/kbuild/vmlinux.md

### Q变量

其中Q变量位于主目录下, Makefile对Q变量进行了定义:

path: Makefile
```
...
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

Q的命运由KBUILD_VERBOSE的值来决定，而螳螂捕蝉，黄雀在后。V最终决定了
Q的命运，通过在make命令参数中提供V=1可以开启V，V是Verbose的缩写，打开
了V，所有的编译信息都将打印出来，关闭V，将获得Beautify output。V选项
对于分析内核的编译很有帮助。

### boot变量

boot := arch/arm/boot 直接指明该架构的boot文件生成路径.

path: arch/arm/Makefile
```
...
boot := arch/arm/boot
...
```

### MACHEINE变量

MACHINE是由用户配置来决定，毕竟一个ARM CPU可以和各类外设组成不同的
机器架构。

path: arch/arm/Makefile
```
# The first directory contains additional information for the boot setup code
ifneq ($(machine-y),)
MACHINE  := arch/arm/mach-$(word 1,$(machine-y))/
else
MACHINE  :=
endif
ifeq ($(CONFIG_ARCH_MULTIPLATFORM),y)
MACHINE  :=
endif
```

### build变量

$(build)=$(boot)被扩展为了scripts/Makefile.build obj=arch/arm/boot，
这看起来有点不太专业。build是scripts/Kbuild.include中定义的变量：

path: scripts/Kbuild.include
```
...
###
# Shorthand for $(Q)$(MAKE) -f scripts/Makefile.build obj=
# Usage:
# $(Q)$(MAKE) $(build)=dir
build := -f $(srctree)/scripts/Makefile.build obj
...
```

### 生成zImage的命令行

一个完整的生成zImage的命令行如下:

```
make -f ./scripts/Makefile.build obj=arch/arm/boot MACHINE= arch/arm/boot/zImage
```

-f指定了实际使用的Makefile文件，obj和MACHINE则是传递给Makefile.build
的参数，它们分别由变量$(boot)和$(MACHINE)决定。$@指参数zImage，
它在Makefile语法中指代生成的目标。

3.Makefile.build
----------------------------------------

path: scripts/Makefile.build
```
...
src := $(obj)
...
# The filename Kbuild has precedence over Makefile
kbuild-dir := $(if $(filter /%,$(src)),$(src),$(srctree)/$(src))
kbuild-file := $(if $(wildcard $(kbuild-dir)/Kbuild),$(kbuild-dir)/Kbuild,$(kbuild-dir)/Makefile)
include $(kbuild-file)
...
```

kbuild-file既是src指定路径下的Makefile文件，此时就是
arch/arm/boot/Makefile，它包含了构建arch/arm/boot/zImage的规则。

### zImage

path: arch/arm/boot/Makefile
```
...
$(obj)/zImage:	$(obj)/compressed/vmlinux FORCE
	$(call if_changed,objcopy)
	@$(kecho) '  Kernel: $@ is ready'
...
```

变量obj的值即是arch/arm/boot.
zImage此时又依赖于$(obj)/compressed/vmlinux.

### $(obj)/compressed/vmlinux

path: arch/arm/boot/Makefile
```
...
$(obj)/compressed/vmlinux: $(obj)/Image FORCE
	$(Q)$(MAKE) $(build)=$(obj)/compressed $@
...
```

扩展开的命令如下:

```
make -f scripts/Makefile.build obj=arch/arm/boot/compressed arch/arm/boot/compressed/vmlinux
```

变量obj的值即是arch/arm/boot.
arch/arm/boot/compressed/vmlinux此时由依赖于$(obj)/Image.

### $(obj)/Image

path: arch/arm/boot/Makefile
```
$(obj)/Image: vmlinux FORCE
	$(call if_changed,objcopy)
	@$(kecho) '  Kernel: $@ is ready'
```

变量obj的值即是arch/arm/boot.

arch/arm/boot/Image此时依赖当前工作目录的vmlinux文件.
