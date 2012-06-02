//
//  NetworkConstants.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

NSString *const PTCallbackOriginal = @"puttio://callback";
NSString *const PTCallbackModified = @"puttio://callback/%3Fcode";

NSString *const PTRootURL = @"https://put.io/";
NSString *const PTSettingsURL = @"https://put.io/account/settings";
NSString *const PTLoginURL = @"https://put.io/login";

NSString *const PTFormatOauthTokenURL = @"https://api.put.io/v2/oauth2/access_token?client_id=%@&client_secret=%@&grant_type=%@&redirect_uri=%@&code=%@";
NSString *const PTFormatOauthLoginURL = @"https://api.put.io/v2/oauth2/authenticate?client_id=%@&response_type=code&redirect_uri=%@";
NSString *const PTFormatOauthURL = @"https://api.put.io/v2/oauth2/authenticate?client_id=%@&response_type=code&redirect_uri=%@";
