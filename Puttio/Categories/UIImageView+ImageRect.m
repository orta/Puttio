//
//  UIImageView+ImageFrame.m
//  Puttio
//
//  Created by orta therox on 19/04/2012.
//  Copyright (c) 2012 http://art.sy. All rights reserved.
//  http://stackoverflow.com/questions/389342/how-to-get-the-size-of-a-scaled-uiimage-in-uiimageview

#import "UIImageView+ImageRect.h"

@implementation UIImageView (ImageFrame)

- (CGRect)frameForImage {
    float imageRatio = self.image.size.width / self.image.size.height;
    float viewRatio = self.frame.size.width / self.frame.size.height;
    
    if(imageRatio < viewRatio) {
        float scale = self.frame.size.height / self.image.size.height;
        float width = scale * self.image.size.width;
        float topLeftX = (self.frame.size.width - width) * 0.5;
        
        return CGRectMake(topLeftX, 0, width, self.frame.size.height);
        
    } else {
        float scale = self.frame.size.width / self.image.size.width;
        float height = scale * self.image.size.height;
        float topLeftY = (self.frame.size.height - height) * 0.5;
        
        return CGRectMake(0, topLeftY, self.frame.size.width, height);
    }
}

@end
