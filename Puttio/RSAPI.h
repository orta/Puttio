// RSAPI.h
//
// Copyright (c) 2012 Michael Dinerstein
// Written for Boundabout (http://www.boundaboutwith.us)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "RSModelHelper.h"
#import "RSDataFetcher.h"
#import "AFNetworking.h"
#import "NSString+Matching.h"

#define kAllTokensKey         @"RSAPIAllTokenStorage"
#define kRSAPITokenKey        @"RSAPITokenKey"
#define kRSAPITokenNameKey    @"RSAPITokenNameKey"

typedef enum {
  RSRequestTypeObject,
  RSRequestTypeData,
  RSRequestTypeMany
} RSRequestType;

typedef enum{
  RSHTTPRequestTypeGet,
  RSHTTPRequestTypePost
}RSHTTPRequestType;

@class RSAPI;
@protocol RSAPIDelegate;

@interface RSAPI : NSObject { 
  NSString *_developmentBase;   //Development URL
  NSString *_productionBase;    //Production URL
  BOOL _useProduction;          //Flag to usethe production URL
  NSString *_baseURL;           //Changes based on the flag.
  
  NSManagedObjectContext *_context;
  NSPersistentStoreCoordinator *_persistentStoreCoordinator;
  
  NSMutableDictionary *_delegates;
  NSMutableDictionary *_requests;
  NSMutableDictionary *_routes;
  NSMutableDictionary *_pMap;
  NSMutableDictionary *_rMap;
  
  NSString *_apiToken;
  NSString *_apiTokenName;
  
  //Global Dict for processing core data calls
  NSMutableDictionary *_allClassesDict;
}

+ (id)setupWithManagedObjContext:(NSManagedObjectContext*)moc withPersistentStoreCoord:(NSPersistentStoreCoordinator*)psc withManagedObjModel:(NSManagedObjectModel*)mom withDevelopmentBase:(NSString*)devBase withProductionBase:(NSString*)prodBase;
+ (id)sharedAPI;

- (void)setUseProduction:(BOOL)useProduction;
- (void)setAPIToken:(NSString*)token named:(NSString*)paramName;
- (NSString*)apiToken;

- (void)setToken:(id)val forKey:(NSString*)key;
- (id)tokenForKey:(NSString*)key;

- (void)logOut;
- (void)refreshPersistentStoreCoord:(NSPersistentStoreCoordinator*)coord andManagedObjectContext:(NSManagedObjectContext*)context;

- (void)setPath:(NSString*)path forClass:(NSString*)theClass requestType:(RSHTTPRequestType)requestType;
- (void)call:(NSString*)routeName params:(NSDictionary *)params withDelegate:(id<RSAPIDelegate>)theDelegate;
- (void)call:(NSString*)routeName params:(NSDictionary *)params withDelegate:(id<RSAPIDelegate>)theDelegate withDataFetcher:(RSDataFetcher*)dataFetcher;
- (void)cancelRequestForPath:(NSString*)path;

+(NSDictionary*)encodeObject:(id)object;
+(NSDictionary*)encodeObjectAsURLParam:(id)object;
+(NSDictionary*)encodePostedData:(NSData *)data forFileType:(NSString*)fileType withFilename:(NSString *)filename;
@end

@protocol RSAPIDelegate <NSObject>
@optional
-(void)apiDidReturn:(id)arrOrDict forRoute:(NSString*)action;
-(void)apiDidFail:(NSError*)error forRoute:(NSString*)action;
@end

