LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := overflow.c
LOCAL_MODULE := overflow
LOCAL_STATIC_LIBRARIES := libstdc++ libc
LOCAL_FORCE_STATIC_EXECUTABLE := true

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := nooverflow.c
LOCAL_MODULE := nooverflow
LOCAL_STATIC_LIBRARIES := libstdc++ libc
LOCAL_FORCE_STATIC_EXECUTABLE := true

include $(BUILD_EXECUTABLE)
