//
//  OAuthController.h
//  Puttio
//
//  Created by orta therox on 13/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PutIOOAuthHelper;
@protocol PutIOOAuthHelperDelegate <NSObject>

- (void)authHelperDidLogin:(PutIOOAuthHelper *)helper;
- (void)authHelperLoginFailedWithDesription:(NSString *)errorDescription;

@end

@interface PutIOOAuthHelper : NSObject <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak) IBOutlet NSObject <PutIOOAuthHelperDelegate> *delegate;

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password;

@end
