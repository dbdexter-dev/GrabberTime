ARCHS = arm64 armv7
TARGETS = iphone:clang:latest

include theos/makefiles/common.mk

TWEAK_NAME = GrabberTime
GrabberTime_FILES = Tweak.xm
GrabberTime_FRAMEWORKS = UIKit
GrabberTime_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
