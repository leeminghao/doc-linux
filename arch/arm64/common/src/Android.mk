LOCAL_PATH := $(my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := test.c
LOCAL_MODULE := test64
LOCAL_MODULE_TAGS := optional
LOCAL_CFLAGS := -g -O0

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := test.c
LOCAL_MODULE := test32
LOCAL_MODULE_TAGS := optional
LOCAL_CFLAGS := -g -O0
LOCAL_32_BIT_ONLY := true

include $(BUILD_EXECUTABLE)
