//
//  FileController.h
//  Puttio
//
//  Created by orta therox on 26/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileInfoViewController;
@protocol FileController <NSObject>

+ (id)controller;

+ (BOOL)fileSupportedByController:(File *)file;

@property  FileInfoViewController *infoController;
@property  File *file;

- (NSString *)primaryButtonText;
- (void)primaryButtonAction:(id)sender;

- (BOOL)supportsSecondaryButton;
- (NSString *)secondaryButtonText;
- (void)secondaryButtonAction:(id)sender;

-(NSString *)descriptiveTextForFile;
- (void)viewWillDissapear;
@end
