#!/bin/bash
# bochs调试linux 0.11内核，出现"Insert root floppy and press ENTER".
# 出现"kernel panic:Unable to mount root"
# 点击bochs中(注意:bochs配置文件中，鼠标不要禁用)config按钮，更换软盘，
# 解决:
# 1.修改Makefile:RAMDISK= #-DRAMDISK =2048 -> RAMDISK= -DRAMDISK = 2048
# 2.点击config按钮时，将第一个软盘(即bootimage,此时引导程序已经将内核装入内存，完成了它的任务)换成rootimage(根文件系统).
bochs -f bochsrc.bxrc
