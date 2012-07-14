//
//  UIDevice+deviceInfo.m
//  Puttio
//
//  Created by orta therox on 08/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "UIDevice+deviceInfo.h"

@implementation UIDevice (deviceInfo)

+ (NSString *)deviceString {
    if ([self isPad]) {
        return @"iPad";
    }
    return @"iPhone";
}

+ (BOOL)isPad {
    return UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone;
}

+ (BOOL)isPhone {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+ (int)deviceType {
#if TARGET_IPHONE_SIMULATOR
    return DeviceOther;
#endif
    bool isRetina = [[UIScreen mainScreen] scale] > 1;
    if ([self isPad]) {
        if (isRetina) {
            return DeviceIpad3Plus;
        } else {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerCameraDeviceFront]) {
                return DeviceIpad2;
            }
            return DeviceIpad1;
        }
    } else {
        if (isRetina) {
            return DeviceIphone4Plus;
        }else {
            return DeviceIphone3GS;
        }
    }
}
@end
