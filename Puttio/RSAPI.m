// RSAPI.m
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

#import "RSAPI.h"

@implementation RSAPI

static RSAPI *api = nil;

- (id)initWithMOC:(NSManagedObjectContext*)moc PSC:(NSPersistentStoreCoordinator*)psc MOM:(NSManagedObjectModel*)mom dev:(NSString*)d prod:(NSString*)p{
  self = [super init];
  if (self){    
    //Delegate storage
    _delegates = [[NSMutableDictionary alloc] init];
    _requests = [[NSMutableDictionary alloc] init];
    
    //Setup Routes
    _routes = [[NSMutableDictionary alloc] init];
    
    _rMap = [[NSMutableDictionary alloc] init];
    _pMap = [[NSMutableDictionary alloc] init];
    
    _useProduction = NO;
    _developmentBase = d;
    _productionBase = p;
    _baseURL = _productionBase;
    
    _context = moc;
    _persistentStoreCoordinator = psc;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Check to see if the allTokensArray has been initialized
    NSMutableArray *allTokensArr = [defaults objectForKey:kAllTokensKey];
    if (!allTokensArr){
      allTokensArr = [[NSMutableArray alloc] init];
      [defaults setObject:allTokensArr forKey:kAllTokensKey];
      [allTokensArr release];
    }
    
    //Fetch APIToken Variables
    NSString *apiToken = [defaults objectForKey:kRSAPITokenKey];
    NSString *apiTokenName = [defaults objectForKey:kRSAPITokenNameKey];
    if (apiToken)   _apiToken = [[NSString alloc] initWithString:apiToken];
    if (apiTokenName) _apiTokenName = [[NSString alloc] initWithString:apiTokenName];
    
    NSArray *entitiesArray = [mom entities];
    for (NSEntityDescription *entityDesc in entitiesArray){
      NSString *entityName = [entityDesc name];
      NSArray *entityProps = [entityDesc properties];
      NSDictionary *entityRelations = [entityDesc relationshipsByName];
      //Set all properties and match with json keys
      NSMutableDictionary *jsonToObjCDict = [[NSMutableDictionary alloc] initWithCapacity:[entityProps count]];
      for (NSAttributeDescription *attrDesc in entityProps){
        NSString *jsonProp = [[RSModelHelper jsonPropertyMapForClass:entityName] objectForKey:[attrDesc name]];
        if (!jsonProp)  jsonProp = [attrDesc name];
        
        [jsonToObjCDict setObject:[attrDesc name] forKey:jsonProp];
      }
      [_pMap setObject:jsonToObjCDict forKey:entityName];
      [jsonToObjCDict release];
      
      //Set all relationships matching with objCId
      NSMutableDictionary *objCKeyToRelationshipClassDict = [[NSMutableDictionary alloc] initWithCapacity:[entityRelations count]];
      for (NSString *relKey in entityRelations){
        NSRelationshipDescription *relDesc = [entityRelations objectForKey:relKey];
        NSString *objCKey = [relDesc name];
        NSString *relClass = [[relDesc destinationEntity] name];
        [objCKeyToRelationshipClassDict setObject:relClass forKey:objCKey];
      }
      [_rMap setObject:objCKeyToRelationshipClassDict forKey:entityName];
      [objCKeyToRelationshipClassDict release];
    }
  }
  return self;
}

- (void)setUseProduction:(BOOL)useProduction{
  _useProduction = useProduction;
  _baseURL = (_useProduction ? _productionBase : _developmentBase);
}

+(id)setupWithManagedObjContext:(NSManagedObjectContext*)moc withPersistentStoreCoord:(NSPersistentStoreCoordinator*)psc withManagedObjModel:(NSManagedObjectModel*)mom withDevelopmentBase:(NSString*)devBase withProductionBase:(NSString*)prodBase{
  @synchronized(self) {
    if(api == nil)
      api = [[self alloc] initWithMOC:moc PSC:psc MOM:mom dev:devBase prod:prodBase];
  }
  return api;
}

+ (id)sharedAPI{
  if (api){
    return api;
  }
  [NSException raise:@"Did not initialize RSAPI" format:@"You must call setupManagedObjContext:withPersistentStoreCoord:withManagedObjModel:withDevelopmentBase:withProductionBase: method before accessing the sharedAPI"];
  return nil;
}
- (id)retain {
  return self;
}
- (unsigned)retainCount {
  return UINT_MAX; //denotes an object that cannot be released
}
- (void)dealloc{
  return;
  //  [NSException raise:@"Singleton released" format:@"Your RSAPI singleton instance was released. What did you do??"];
  [super dealloc];
}
- (id)autorelease {
  return self;
}

#pragma mark - Relationship Setters
/* Specify path with the appropriate Class and requestType */
- (void)setPath:(NSString*)path forClass:(NSString*)theClass requestType:(RSHTTPRequestType)requestType{
  [_routes setObject:[NSDictionary dictionaryWithObjectsAndKeys:path,@"path",theClass,@"class",[NSNumber numberWithInt:requestType],@"requestType",nil] forKey:path];
}

- (void)setAPIToken:(NSString*)token named:(NSString*)paramName{
  if (token == nil || paramName == nil) return;
  if (_apiToken) [_apiToken release];
  if (_apiTokenName) [_apiTokenName release];
  _apiToken = [[NSString alloc] initWithString:token];
  _apiTokenName = [[NSString alloc] initWithString:paramName];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:_apiToken forKey:kRSAPITokenKey];
  [defaults setObject:_apiTokenName forKey:kRSAPITokenNameKey];
  [defaults synchronize];
}

- (NSString*)apiToken{
  return _apiToken;
}

#pragma mark - Key Value Encoding for NSDefaults
- (void)setToken:(id)val forKey:(NSString*)key{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:val forKey:key];
  [[defaults objectForKey:kAllTokensKey] addObject:key];    //Add to tokens key array
  [defaults synchronize];
}

- (id)tokenForKey:(NSString*)key{
  return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

#pragma mark - URL Builders
- (NSString*)requestStringURLForRoute:(NSString *)routeName forParams:(NSDictionary*)params{
  NSString *path = [[_routes objectForKey:routeName] objectForKey:@"path"];
  
  //If the path has a colon, we can bind a param to the path itself
  NSRange pathIDRange = [path rangeOfString:@":"];
  while (pathIDRange.length > 0){
    NSString *rest = [path substringFromIndex:pathIDRange.location+1];
    
    NSRange bindingRange = [rest rangeOfString:@"/"];
    NSString *binding;
    if (bindingRange.length > 0){
      binding = [rest substringToIndex:[rest rangeOfString:@"/"].location];
    }
    else{
      binding = rest;
    }
    
    id tempVal = [params objectForKey:binding];
    id bindingVal = ([tempVal isKindOfClass:[NSDictionary class]] ? [tempVal objectForKey:@"value"] : tempVal);
    
    if (!bindingVal)  [NSException raise:@"Invalid URL binding" format:@"You are trying to bind: %@ but no request parameter by the name of %@ was set.",path,bindingVal];
    
    //Now bind the var to the URL
    NSString *firstHalf = [path substringToIndex:pathIDRange.location];
    NSString *secondHalf = [path substringFromIndex:pathIDRange.location+binding.length+1];
    path = [NSString stringWithFormat:@"%@%@%@",firstHalf,bindingVal,secondHalf];
    pathIDRange = [path rangeOfString:@":"];    //Repeat for future variables until all variables are gone
  }
  
  RSHTTPRequestType requestType = (RSHTTPRequestType)[[[_routes objectForKey:routeName] objectForKey:@"requestType"] intValue];
  NSString *urlString = path;
  if (requestType == RSHTTPRequestTypeGet){
    if (_apiToken)  urlString = [NSString stringWithFormat:@"%@?%@=%@",urlString,_apiTokenName,_apiToken];
    else            urlString = [NSString stringWithFormat:@"%@?",urlString];
    if (params != nil){
      NSEnumerator *enumerator = [params keyEnumerator];
      NSString *key;
      while(key = (NSString*)[enumerator nextObject]){
        id tempParamDict = [params objectForKey:key];
        
        id paramValue;
        if ([tempParamDict isKindOfClass:[NSDictionary class]]){
          if ([tempParamDict objectForKey:@"urlParam"])   continue;
          paramValue = [tempParamDict objectForKey:@"value"];
        } 
        else{
          paramValue = tempParamDict;
        }
        
        urlString = [NSString stringWithFormat:@"%@&%@=%@",urlString,key,paramValue];
      }      
    }
  }
  return urlString;
}

#pragma mark - Add/Remove/Cancel requests from management
- (void)addRequest:(AFURLConnectionOperation*)request forPath:(NSString*)path{
  AFURLConnectionOperation *existingRequest = [_requests objectForKey:path];
  if (!existingRequest){
    [_requests setObject:request forKey:path];
  }
}

- (void)removeRequestForPath:(NSString*)path cancel:(BOOL)cancel{  
  AFURLConnectionOperation *existingRequest = [_requests objectForKey:path];
  if (!existingRequest)  return;
  
  if (cancel){
    [existingRequest cancel];
  }
  [_requests removeObjectForKey:path];
}

- (void)cancelRequestForPath:(NSString*)path{
  for (NSString *activePath in [_delegates allKeys]){
    //Modify active path for URLs with question marks in them.
    NSRange qMarkRange = [activePath rangeOfString:@"?"];
    if (qMarkRange.location != NSNotFound){      
      activePath = [activePath substringToIndex:qMarkRange.location+qMarkRange.length];
    }
    
    if ([activePath matches:path]){
      [self removeRequestForPath:path cancel:YES];
      return;
    }
  }
}

#pragma mark - Delegate for Requests and LoadingViews for requests
//Get the delegate from the Dictionary
- (id<RSAPIDelegate>)delegateForKey:(NSString*)key{
  id<RSAPIDelegate> theDel = (id<RSAPIDelegate>)[_delegates objectForKey:key];
  [_delegates removeObjectForKey:key];
  
  if (!theDel || [theDel isKindOfClass:[NSNull class]])  return nil;
  return theDel;
}

- (void)setDelegate:(id<RSAPIDelegate>)del forKey:(NSString*)key{
  if (![_delegates objectForKey:key]){    
    if (del)  [_delegates setObject:del forKey:key];
    else      [_delegates setObject:[NSNull null] forKey:key];
  }
}

// New function for getting the route dictionary 
- (NSString*)getRequestClassForRoute:(NSString*)route{
  NSDictionary *retDict = [_routes objectForKey:route];
  if (retDict)
    return [retDict objectForKey:@"class"];
  
  NSArray *routeKeys = [_routes allKeys];
  for (int i = 0; i < [routeKeys count]; i++){
    NSString *path = [routeKeys objectAtIndex:i];
    if( [path matches:route] ){
      return [[_routes objectForKey:path] objectForKey:@"class"];
    }
  }
  return nil;
}

- (id)importDictionary:(NSDictionary*)jsonDict forManagedObjectClass:(NSString*)class{  
  NSMutableDictionary *dictListing = [_allClassesDict valueForKey:@"dicts"];
  
  //Look to see if we have class objects already. If not, create the dictionary
  NSMutableDictionary *allObjsDict = [dictListing objectForKey:class];
  if (!allObjsDict){
    [dictListing setValue:[[[NSMutableDictionary alloc] init] autorelease] forKey:class];
    allObjsDict = [dictListing valueForKey:class];
  }
  
  //Get the objCIDKey
  NSString *jsonIdKey = [RSModelHelper jsonIdKeyForClass:class];
  if ([[jsonDict objectForKey:jsonIdKey] isKindOfClass:[NSNull class]]) return nil;       //If the id key is null, we can't save the object
  
  BOOL jsonKeyIsString = [[jsonDict objectForKey:jsonIdKey] isKindOfClass:[NSString class]];
  NSString *jsonId = ( jsonKeyIsString ? [jsonDict objectForKey:jsonIdKey] : [[jsonDict objectForKey:jsonIdKey] stringValue]);
  //Look to see if we have that particular object for that class. If not, create a new holding dictionary
  NSMutableDictionary *objDict = [allObjsDict objectForKey:jsonId];
  if (!objDict){
    [allObjsDict setValue:[[[NSMutableDictionary alloc] init] autorelease] forKey:jsonId];
    objDict = [allObjsDict valueForKey:jsonId];
  }
  
  if (![objDict objectForKey:@"properties"]){
    [objDict setValue:[[[NSMutableDictionary alloc] init] autorelease] forKey:@"properties"];    
  }
  if (![objDict objectForKey:@"relations"]){
    [objDict setValue:[[[NSMutableDictionary alloc] init] autorelease] forKey:@"relations"];
  }
  
  NSDictionary *curObjPropMap = [_pMap objectForKey:class]; //Object's property mapping
  NSDictionary *curObjRelMap = [_rMap objectForKey:class]; //Object's relationship mapping
  
  //Match the values up
  NSEnumerator *enumerator = [jsonDict keyEnumerator];
  NSString *jsonKey;
  while(jsonKey = (NSString*)[enumerator nextObject]){
    id jsonProp = [jsonDict objectForKey:jsonKey];
    NSString *curObjCKey = [curObjPropMap objectForKey:jsonKey];
    
    if ([jsonProp isKindOfClass:[NSDictionary class]]){
      NSString *nextClass = [curObjRelMap objectForKey:curObjCKey];
      NSString *nextClassKey = [curObjPropMap objectForKey:jsonKey];
      
      NSString *dictID = [self importDictionary:jsonProp forManagedObjectClass:nextClass];
      if (dictID != nil)
        [[objDict valueForKey:@"relations"] setValue:dictID forKey:nextClassKey];
    }
    else if ([jsonProp isKindOfClass:[NSArray class]]){
      NSString *nextClass = [curObjRelMap objectForKey:curObjCKey];
      NSString *nextClassKey = [curObjPropMap objectForKey:jsonKey];
      
      NSMutableSet *subsetIDs = [[NSMutableSet alloc] init];
      for (NSDictionary *propDict in jsonProp){
        NSString *dictId = [self importDictionary:propDict forManagedObjectClass:nextClass];
        if (dictId != nil)
          [subsetIDs addObject:dictId];
      }
      //We have all the added properties right now.
      
      NSMutableSet *existSet = [[objDict valueForKey:@"relations"] valueForKey:nextClassKey];
      if(!existSet){
        [[objDict valueForKey:@"relations"] setValue:[[[NSMutableSet alloc] initWithSet:subsetIDs] autorelease] forKey:nextClassKey];
      }
      else{
        [[[objDict valueForKey:@"relations"] valueForKey:nextClassKey] unionSet:subsetIDs];
      }
      
      [subsetIDs release];
    }
    else{
      if (jsonProp == nil || [jsonProp isKindOfClass:[NSNull class]]) continue;
      
      NSString *objCKey = [curObjPropMap objectForKey:jsonKey];
      if (objCKey != nil){ 
        //It's a regular property. We need to treat this particularly differently.
        NSEntityDescription *objEntity = [NSEntityDescription entityForName:class inManagedObjectContext:_context];
        NSAttributeDescription *attrDesc = (NSAttributeDescription*)[[objEntity attributesByName] objectForKey:objCKey];
        
        /* NSDate Setting with Strings */
        if ([[attrDesc attributeValueClassName] isEqualToString:@"NSDate"] && [jsonProp isKindOfClass:[NSString class]]){
          NSString *jsonString = (NSString*)jsonProp;
          jsonString = [[jsonString substringToIndex:(jsonString.length-1)] stringByAppendingString:@"-0000"];
          NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
          [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
          jsonProp = [dateFormat dateFromString:jsonString];
          [dateFormat release];
        }
        else if ([[attrDesc attributeValueClassName] isEqualToString:@"NSNumber"]){
          if ([jsonProp isKindOfClass:[NSString class]]){
            NSString *jsonString = (NSString*)jsonProp;
            NSNumber *jsonNumber = [NSNumber numberWithFloat:[jsonString floatValue]];
            jsonProp = jsonNumber;
          }
          else if ([attrDesc attributeType] == NSBooleanAttributeType){
            if (![jsonProp isKindOfClass:[NSNull class]] && [jsonProp intValue] == 1){
              jsonProp = [NSNumber numberWithBool:YES];
            }
            else{
              jsonProp = [NSNumber numberWithBool:NO];
            }
          }
        }
        /* If we have a NSNull class, we need to edit it to nil */
        if ([jsonProp isKindOfClass:[NSNull class]]){
          jsonProp = nil;
        }
        [[objDict valueForKey:@"properties"] setValue:jsonProp forKey:objCKey]; 
        continue; 
      }
      
      //If it's nil, we might have an ID on our hands
      //If our key length is <= 3 or it doesn't end with _id, continue
      if ([jsonKey length] <= 3 || ![[jsonKey substringFromIndex:[jsonKey length]-3] isEqualToString:@"_id"])   continue;
      
      NSString *relationKey = [jsonKey substringToIndex:[jsonKey length]-3];
      NSString *relClass = [curObjRelMap objectForKey:relationKey];
      if (!relClass)    continue;
      
      //A relation exists and we can just store this thing as the ID 
      NSString *insertKey = [curObjPropMap objectForKey:relationKey];
      if (!insertKey) continue;
      [[objDict valueForKey:@"relations"] setValue:jsonProp forKey:insertKey];
    }
  }
  
  
  NSString *objcIdKey = [[_pMap objectForKey:class] objectForKey:jsonIdKey];
  return [[objDict valueForKey:@"properties"] objectForKey:objcIdKey];
}

- (void)setupManagedObjectRelations{
  NSMutableDictionary *dictListing = [_allClassesDict valueForKey:@"dicts"];
  NSMutableDictionary *mobmListing = [_allClassesDict valueForKey:@"mobms"];
  
  //Loop through managed objects
  for (NSString *class in mobmListing){
    NSDictionary *dictObjsForClass = [dictListing valueForKey:class];
    NSDictionary *mobmsForClass = [mobmListing valueForKey:class];
    for (NSString *theID in mobmsForClass){
      NSDictionary *dictRels = [[dictObjsForClass objectForKey:theID] objectForKey:@"relations"];
      NSManagedObject *mobm = [mobmsForClass objectForKey:theID];
      
      for (NSString *relKey in dictRels){
        id possRelID = [dictRels objectForKey:relKey];
        NSString *relClass = [_rMap objectForKey:relKey];
        
        if ([possRelID isKindOfClass:[NSSet class]]){     //Loop through a set for the dictionary
          for (id relID in possRelID){
            NSString *strID = [relID isKindOfClass:[NSString class]] ? (NSString*)relID : [(NSNumber*)relID stringValue];
            NSManagedObject *relVal = [[mobmListing valueForKey:relClass] valueForKey:strID];
            if (relVal == nil)  continue;
            [[mobm mutableSetValueForKey:relKey] addObject:relVal];
          }
        }
        else{                                         //Set a single object
          NSString *strID = ([possRelID isKindOfClass:[NSString class]]) ? (NSString*)possRelID : [(NSNumber*)possRelID stringValue];
          NSManagedObject *relVal = [[mobmListing valueForKey:relClass] objectForKey:strID];
          if (relVal == nil){
            continue;
          }
          [mobm setValue:relVal forKey:relKey];
        }
      }
    }
  }
}

- (void)insertRelationsIntoManagedObjectDictionary{
  NSMutableDictionary *dictListing = [_allClassesDict valueForKey:@"dicts"];
  NSMutableDictionary *mobmListing = [_allClassesDict valueForKey:@"mobms"];
  
  NSMutableDictionary *fetchDict = [[NSMutableDictionary alloc] init];
  for (NSString *class in dictListing){
    NSArray *allObjsForClass = [[dictListing objectForKey:class] allValues];
    for (NSDictionary *objDict in allObjsForClass){
      NSDictionary *objRels = [objDict valueForKey:@"relations"];
      for (NSString *relProp in objRels){
        NSString *relClass = [[_rMap objectForKey:class] objectForKey:relProp];
        id relations = [objRels objectForKey:relProp];
        //Now, make sure fetchDict has an NSSet initialized to take in the IDs
        if ([fetchDict objectForKey:relClass] == nil){
          [fetchDict setObject:[[[NSMutableSet alloc] init] autorelease] forKey:relClass];
        }
        //Now, let's place these relations in the fetch dict
        if ([relations isKindOfClass:[NSSet class]]){
          [(NSMutableSet*)[fetchDict objectForKey:relClass] unionSet:(NSSet*)relations];
        }
        else if (relations){
          [(NSMutableSet*)[fetchDict objectForKey:relClass] addObject:relations];
        }
      }
    }
  }
  
  //All the relations are now in fetchDict
  NSError *error;
  for (NSString *class in fetchDict){
    if (![fetchDict valueForKey:class] || ![[fetchDict valueForKey:class] isKindOfClass:[NSSet class]])   continue;
    NSString *jsonIdKey = [RSModelHelper jsonIdKeyForClass:class];
    NSString *objcIdKey = [[_pMap objectForKey:class] objectForKey:jsonIdKey];
    
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] initWithEntityName:class];
    [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"self.%@ IN %@",objcIdKey,[fetchDict valueForKey:class]]];
    NSArray *retClassObjs = [_context executeFetchRequest:fetchReq error:&error];
    for (NSManagedObject *manObj in retClassObjs){
      NSString *manObjId = [[manObj valueForKey:objcIdKey] isKindOfClass:[NSString class]] ? 
      [manObj valueForKey:objcIdKey] : [NSString stringWithFormat:@"%@",[manObj valueForKey:objcIdKey]];
      
      if ( ![mobmListing valueForKey:class]){
        [mobmListing setValue:[[[NSMutableDictionary alloc] init] autorelease] forKey:class];
      }
      if ( ![[mobmListing valueForKey:class] objectForKey:manObjId] ){
        [[mobmListing valueForKey:class] setObject:manObj forKey:manObjId];
      }
    }
    [fetchReq release];
  }
  //Now, we've inserted every relation into the mobmListing dictionary
  [fetchDict release];
}

- (void)createManagedObjectDictionary{
  NSMutableDictionary *dictListing = [_allClassesDict valueForKey:@"dicts"];
  NSMutableDictionary *mobmListing = [_allClassesDict valueForKey:@"mobms"];
  
  NSManagedObjectContext *importContext = _context;
  NSError *error;
  
  for (NSString *class in dictListing){
    
    NSDictionary *allObjsDict = [dictListing objectForKey:class];
    NSDictionary *allMobsDict = [mobmListing objectForKey:class];
    if (!allMobsDict){
      [mobmListing setValue:[[[NSMutableDictionary alloc] init] autorelease] forKey:class];
      allMobsDict = [mobmListing valueForKey:class];
    }
    
    //Figure out what type of ID key we have NSString or NSNumber
    NSString *jsonIdKey = [RSModelHelper jsonIdKeyForClass:class];
    NSString *objcIdKey = [[_pMap objectForKey:class] objectForKey:jsonIdKey];
    NSEntityDescription *objEntity = [NSEntityDescription entityForName:class inManagedObjectContext:_context];
    NSAttributeDescription *attrDesc = (NSAttributeDescription*)[[objEntity attributesByName] objectForKey:objcIdKey];
    BOOL classHasNumericID = [[attrDesc attributeValueClassName] isEqualToString:@"NSNumber"] ? YES : NO;
    
    NSArray *allObjsIDs = [[allObjsDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      if (classHasNumericID){
        NSNumber *id1 = [NSNumber numberWithInt:[obj1 intValue]];
        NSNumber *id2 = [NSNumber numberWithInt:[obj2 intValue]];
        return [id1 compare:id2];        
      }
      //Otherwise, it's a atring and return accordingly
      return [(NSString*)obj1 compare:(NSString*)obj2];
    }];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:class];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.%@ IN %@",objcIdKey,allObjsIDs]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:objcIdKey ascending:YES]]];
    NSArray *manObjs = [importContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    //We always loop through all of the current objects. We increment m if there's no match.
    int m = 0;
    for (int a = 0; a < [allObjsDict count]; a++){
      NSString *curObjID = [allObjsIDs objectAtIndex:a];
      NSDictionary *curObj = [allObjsDict objectForKey:curObjID];
      if (m == [manObjs count]){
        //If we reached the end of our managed objects before the dictionary objects, we insert the rest
        NSManagedObject *manObj = [NSEntityDescription insertNewObjectForEntityForName:class inManagedObjectContext:importContext];
        [manObj setValuesForKeysWithDictionary:[curObj valueForKey:@"properties"]];
        [allMobsDict setValue:manObj forKey:curObjID];
        continue;
      }
      
      NSManagedObject *manObj = [manObjs objectAtIndex:m];
      id manObjID = [manObj valueForKey:objcIdKey];
      if ( (classHasNumericID && [manObjID intValue] != [curObjID intValue]) || (!classHasNumericID && ![manObjID isEqualToString:curObjID]) ){
        //OR if the managed object id does not equal the current id, insert new and keep m where it is because we haven't found it yet.
        manObj = [NSEntityDescription insertNewObjectForEntityForName:class inManagedObjectContext:importContext];
      }
      else{
        //We have a match. Increment m and set properties below.
        m++;
      }
      //Add the manObj to the parent dictionary
      [manObj setValuesForKeysWithDictionary:[curObj valueForKey:@"properties"]];
      [allMobsDict setValue:manObj forKey:curObjID];
    }
    
    //Now, we've gone through ALL of the fetches for the class.
    //Save the context, drawin the pool, and re-init it.
    if(![importContext save:&error]){
      NSLog(@"ERROR: %@",[error description]);
      exit(-1);
    }
  }
  //And finally, we've done all of the classes.
}

#pragma mark - Log Out Functionality
// Wipes NSUserDefaults for your tokens, destroys all Core Data stores.
// Meant to be used in conjunction with a user log out script so that users can easily log out of your app and not worry about
// leaving personal data behind.

-(void)logOut{
  NSError *error = nil;
  
  if ([_persistentStoreCoordinator persistentStores] == nil)
    return;
  
  // FIXME: dirty. If there are many stores...
  NSPersistentStore *store = [[_persistentStoreCoordinator persistentStores] lastObject];
  
  if (![_persistentStoreCoordinator removePersistentStore:store error:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }  
  
  // Delete file
  if ([[NSFileManager defaultManager] fileExistsAtPath:store.URL.path]) {
    if (![[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    } 
  }
  
  //We also need to remove the api key access across keychains
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:kRSAPITokenKey];
  [defaults removeObjectForKey:kRSAPITokenNameKey];
  NSMutableArray *allOtherKeys = [defaults objectForKey:kAllTokensKey];
  for (NSString *key in allOtherKeys){
    [defaults removeObjectForKey:key];
  }
  [defaults removeObjectForKey:kAllTokensKey];
  [defaults synchronize];
}

- (void)refreshPersistentStoreCoord:(NSPersistentStoreCoordinator*)coord andManagedObjectContext:(NSManagedObjectContext*)context{
  _persistentStoreCoordinator = coord;
  _context = context;
}

#pragma mark - Main API Calling Functionality
- (void)call:(NSString*)routeName params:(NSDictionary *)params withDelegate:(id<RSAPIDelegate>)theDelegate withDataFetcher:(RSDataFetcher *)dataFetcher{
  NSDictionary *route = (NSDictionary*)[_routes objectForKey:routeName];
  if (!route){
    [NSException raise:@"Invalid Route Exception" format:@"The route: %@ does not exist",routeName];
    return;
  }
  
  RSHTTPRequestType requestType = (RSHTTPRequestType)[[route objectForKey:@"requestType"] intValue];
  NSString *requestClass = (NSString*)[route objectForKey:@"class"];
  NSString *requestStringURL = [self requestStringURLForRoute:routeName forParams:params];
  
  if ([_delegates objectForKey:routeName]){
    return;   //Block all repeat requests
  }
  
  //Set the delegate in the dictionary with a key based on the absolute path of the requestURL
  if (theDelegate == nil)   [self setDelegate:nil forKey:routeName];
  else                      [self setDelegate:theDelegate forKey:routeName];
  
  //If the loading message is not nil, then we need to construct a UILoadingView in the same manner as the delegate dictionary
  AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:_baseURL]];
  NSMutableURLRequest *request;
  
  if (requestType == RSHTTPRequestTypeGet){
    request = [httpClient requestWithMethod:@"GET" path:requestStringURL parameters:nil];
  }
  else if (requestType == RSHTTPRequestTypePost){
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithCapacity:[params count]];
    NSMutableDictionary *postDataParams = [[NSMutableDictionary alloc] init];
    
    if (_apiToken)  [postParams setObject:_apiToken forKey:_apiTokenName];    //Set API Token
    
    NSEnumerator *enumerator = [params keyEnumerator];
    NSString *key;
    while(key = (NSString*)[enumerator nextObject]){
      //TODO: Fix this section to support the automatic insertion of values into the data request
      NSDictionary *paramDict = (NSDictionary*)[params objectForKey:key];
      //Skips parameters that are a part of the URL request
      if ([paramDict objectForKey:@"urlParam"] && [[paramDict objectForKey:@"urlParam"] boolValue] == YES)      continue; //This is already in the URL
      
      if ([paramDict objectForKey:@"isPostParam"] && [[paramDict objectForKey:@"isPostParam"] boolValue] == YES){
        //For post parameters, we need a fileName and fileType along with the data in order to post
        [postDataParams setObject:paramDict forKey:key];
      }
      else{
        //This is a regular parameter
        [postParams setObject:[[params objectForKey:key] objectForKey:@"value"] forKey:key];
      }        
    }
    request = [httpClient multipartFormRequestWithMethod:@"POST" path:requestStringURL parameters:postParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
      NSEnumerator *enumerator = [postDataParams keyEnumerator];
      NSString *key;
      while (key = (NSString*)[enumerator nextObject]){
        NSDictionary *paramDict = (NSDictionary*)[postDataParams objectForKey:key];
        NSData *fileData = [paramDict objectForKey:@"value"];
        NSString *fileName = [paramDict objectForKey:@"fileName"];
        NSString *fileType = [paramDict objectForKey:@"fileType"];
        if ([fileData bytes] != 0){     //If we have a file of a given length
          if (fileName != nil && fileType != nil){
            [formData appendPartWithFileData:fileData name:key fileName:fileName mimeType:fileType];
          }
          else{
            [formData appendPartWithFormData:fileData name:key];
          }                      
        }
      }
      [postDataParams release];
    }];
    [postParams release];
  }
  
  //This is the massive request we are sending out
  AFJSONRequestOperation *jsonRequestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    //Get the returned request, remove the delegate, the request object, and the loadingView
    [self removeRequestForPath:routeName cancel:NO];
    id<RSAPIDelegate> theDel = [self delegateForKey:routeName];
    
    RSRequestType reqType = RSRequestTypeObject;
    if ([requestClass isEqualToString:@"DATA"]){
      reqType = RSRequestTypeData;
    }
    else if ([requestClass isEqualToString:@"MANY"]){
      reqType = RSRequestTypeMany;
    }
    
    //Failure cases. Return the delegate immediately.
    NSError *failureErr = nil;
    if ([JSON isKindOfClass:[NSDictionary class]] && [(NSDictionary*)JSON objectForKey:@"failure"])
      failureErr = [NSError errorWithDomain:[(NSDictionary*)JSON objectForKey:@"failure"] code:000 userInfo:nil];
    else if (![JSON isKindOfClass:[NSDictionary class]] && (reqType == RSRequestTypeData))
      failureErr = [NSError errorWithDomain:@"Unexpected reply from server. Expected dictionary and an array was returned." code:001 userInfo:nil];
    else if (!JSON)
      failureErr = [NSError errorWithDomain:@"Server returned nil object." code:002 userInfo:nil];
    
    if (failureErr){
      if (theDel && [theDel respondsToSelector:@selector(apiDidFail:forRoute:)]){
        [theDel apiDidFail:failureErr forRoute:routeName];
      }
      return;
    }
    
    if (reqType == RSRequestTypeData){
      if (theDel && [theDel respondsToSelector:@selector(apiDidReturn:forRoute:)]){
        [theDel apiDidReturn:JSON forRoute:routeName];
      }
      return;
    }
    
    _allClassesDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [_allClassesDict setValue:[[[NSMutableDictionary alloc] init] autorelease] forKey:@"dicts"];
    [_allClassesDict setValue:[[[NSMutableDictionary alloc] init] autorelease] forKey:@"mobms"];
    
    if (reqType == RSRequestTypeObject){
      NSString *requestClass = [self getRequestClassForRoute:routeName];               //Get object class for binding
      if ([JSON isKindOfClass:[NSDictionary class]]){
        [self importDictionary:JSON forManagedObjectClass:requestClass];      
      }
      else{
        for (NSDictionary *dict in JSON){
          [self importDictionary:dict forManagedObjectClass:requestClass];        
        }
      }    
    }
    else if (reqType == RSRequestTypeMany){
      for (NSString *requestClass in (NSDictionary*)JSON){
        id importDictOrArr = [(NSDictionary*)JSON objectForKey:requestClass];
        if ([importDictOrArr isKindOfClass:[NSDictionary class]]){
          [self importDictionary:importDictOrArr forManagedObjectClass:requestClass];      
        }
        else{
          for (NSDictionary *dict in importDictOrArr){
            [self importDictionary:dict forManagedObjectClass:requestClass];        
          }
        }            
      }
    }
    
    [self createManagedObjectDictionary];  //Create Managed Object Dictionary that mirrors the data with just objects
    [self insertRelationsIntoManagedObjectDictionary];
    [self setupManagedObjectRelations];    //We have all of the dictionaries and managed objects. Set up relations.
    
    NSError *error;
    if (![_context save:&error]) {   
      // Update to handle the error appropriately.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      exit(-1);  // Fail
    }
    [_allClassesDict release];
    _allClassesDict = nil;
    
    //Return
    if (dataFetcher) [dataFetcher performUpdate];
    
    if (theDel && [theDel respondsToSelector:@selector(apiDidReturn:forRoute:)]){
      [theDel apiDidReturn:JSON forRoute:routeName];
    }
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
    id<RSAPIDelegate> theDel = [self delegateForKey:routeName];
    
    if (theDel != nil && [theDel respondsToSelector:@selector(apiDidFail:forRoute:)]){
      [theDel apiDidFail:[NSError errorWithDomain:@"Request Failed." code:[response statusCode] userInfo:nil] forRoute:routeName];
    }
  }];
  [jsonRequestOperation start];
  
  //We process both the requests in the same way
  [self addRequest:jsonRequestOperation forPath:routeName];
}

- (void)call:(NSString*)routeName params:(NSDictionary *)params withDelegate:(id<RSAPIDelegate>)theDelegate{
  [self call:routeName params:params withDelegate:theDelegate withDataFetcher:nil];
}

#pragma mark - Helpers
+(NSDictionary*)encodeObject:(id)object{
  return [NSDictionary dictionaryWithObjectsAndKeys:object,@"value",nil];
}

+(NSDictionary*)encodeObjectAsURLParam:(id)object{
  return [NSDictionary dictionaryWithObjectsAndKeys:object,@"value",[NSNumber numberWithBool:YES],@"urlParam",nil];
}

+(NSDictionary*)encodePostedData:(NSData *)data forFileType:(NSString*)fileType withFilename:(NSString *)filename{
  return [NSDictionary dictionaryWithObjectsAndKeys:data,@"value",[NSNumber numberWithBool:YES],@"isPostParam",filename,@"fileName",fileType,@"fileType",nil];
}

@end
