//
//  UIDevice+deviceInfo.h
//  Puttio
//
//  Created by orta therox on 08/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (deviceInfo)

enum DeviceType {
    DeviceIpad1,
    DeviceIpad2,
    DeviceIpad3Plus,
    DeviceIphone3GS,
    DeviceIphone4Plus,
    DeviceOther
};

+ (NSString *)deviceString;
+ (int)deviceType;
+ (BOOL)isPad;
+ (BOOL)isPhone;
@end
