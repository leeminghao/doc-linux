LOCAL_PATH := $(my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := greet.c
LOCAL_MODULE := libgreet
LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := main.c
LOCAL_SHARED_LIBRARIES := libgreet
LOCAL_MODULE := greet
LOCAL_MODULE_TAGS := optional

include $(BUILD_EXECUTABLE)
