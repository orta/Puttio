//
//  UIDevice+deviceInfo.m
//  Puttio
//
//  Created by orta therox on 08/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "UIDevice+deviceInfo.h"

@implementation UIDevice (deviceInfo)
+ (BOOL)isPad {
    return UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone;
}

+ (BOOL)isPhone {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}
@end
