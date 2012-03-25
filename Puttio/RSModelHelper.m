// RSModelHelper.m
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

/* PLEASE READ THIS TO ENSURE YOU ARE SETTING EVERYTHING UP PROPERLY.
 * This is an example of how you should set up your routes
 * You must replace the implementation of jsonIdKeyForClass and jsonPropertyMapForClass with your own object model
 * Instructions for jsonIdKeyForClass:(NSString*)className
 * ------------
 * For each Core Data Object, you must return the JSON key your server returns for that particular object.
 * For example, if you have a Core Data Object called User. And let's assume when you download a User object from your server, the 
 * id is labeled as user_id. When jsonIdKeyForClass passes @"User" as the className, you must return @"user_id".
 * Best Practice:
 * On your web server, make the id key for all of your objects @"id". That way, you can always return @"id" no matter what the
 * className is. Then, if there are exceptions, you can construct an if or switch statement that will handle these exceptions.
 *
 * Instructions for jsonPropertyMapForClass:(NSString*)className
 * ------------
 * When you make a request to the server for an object, RSAPI needs to match your JSON data with your Core Data model. 
 * If the names of your JSON attributes exactly match your Core Data attributes, congratulations, you are done.
 * If not, you need to do some customization. In these cases, you must return an NSDictionary that encodes your model's JSON 
 * attributes as objects and your model's Core Data attributes as keys. 
 * For example, if you have a User object that is set up the following way: 
 * User (JSON from Web Server): id, email, hashed_password
 * User (Core Data Model): userID, email, hashedPassword
 * You would write the following:  
 * if ([className isEqualToString:@"User"]){
 *    return [NSDictionary dictionaryWithObjectsAndKeys:
              @"id",@"userID",
              @"hashed_password",@"hashedPassword",
              nil];
 * Note that I did not include the email attribute because the JSON and Core Data match here
 */

#import "RSModelHelper.h"

@implementation RSModelHelper

+ (NSString*)jsonIdKeyForClass:(NSString*)className{
  if ([className isEqualToString:@"CoreDataClassName"])
    return @"specialized_json_id_key_for_class";
  return @"default_json_id_key";
}

+ (NSDictionary*)jsonPropertyMapForClass:(NSString*)className{
  if ([className isEqualToString:@"File"]){
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"id",@"id",
            @"name",@"name", 
            nil];
  }
  else if ([className isEqualToString:@"Folder"]){
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"id",@"id",
            @"name",@"name", 
            nil];
  }
  ///etc.
  [NSException raise:@"Core Data Class Does Not Exist" format:@"Class Does Not Exist: %@", className];
  return nil;
}

@end
