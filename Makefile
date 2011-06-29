include theos/makefiles/common.mk

TWEAK_NAME = GrayPix
GrayPix_FILES = Tweak.xm
GrayPix_FRAMEWORKS=CoreGraphics UIKit

TARGET_IPHONEOS_DEPLOYMENT_VERSION = 4.0

include $(THEOS_MAKE_PATH)/tweak.mk
