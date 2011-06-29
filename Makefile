include theos/makefiles/common.mk

TWEAK_NAME = GrayPix
GrayPix_FILES = Tweak.xm
GrayPix_FRAMEWORKS=CoreGraphics UIKit
include $(THEOS_MAKE_PATH)/tweak.mk
