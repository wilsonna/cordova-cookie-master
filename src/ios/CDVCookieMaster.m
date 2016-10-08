//
//  CDVCookieMaster.m
//  
//
//  Created by Kristian Hristov on 12/16/14.
//
//

#import "CDVCookieMaster.h"

#import <WebKit/WKWebsiteDataStore.h>

@implementation CDVCookieMaster

 - (void)getCookieValue:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult* pluginResult = nil;
    NSString* urlString = [command.arguments objectAtIndex:0];
    __block NSString* cookieName = [command.arguments objectAtIndex:1];
    
    //if (urlString != nil) {
		//[NSSet setWithArray:@[
                        //WKWebsiteDataTypeDiskCache,
                        //WKWebsiteDataTypeOfflineWebApplicationCache,
                        //WKWebsiteDataTypeMemoryCache,
                        //WKWebsiteDataTypeLocalStorage,
                        //WKWebsiteDataTypeCookies,
                        //WKWebsiteDataTypeSessionStorage,
                        //WKWebsiteDataTypeIndexedDBDatabases,
                        //WKWebsiteDataTypeWebSQLDatabases
                        //]]
		
		[[WKWebsiteDataStore defaultDataStore] fetchDataRecordsOfTypes:[NSSet setWithObjects:WKWebsiteDataTypeCookies, nil]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
						 //NSArray* dataTypes = [records valueForKeyPath:@"dataTypes"];
						 NSMutableArray* cookies = [[NSMutableArray alloc] init]; //[records valueForKeyPath:@"description"];
						 
						 for (WKWebsiteDataRecord* record in records) {
							for (NSString *dataType in record.dataTypes) {
								[cookies addObject:dataType];
							}
						}

						NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
						NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
						NSArray* filelist = [[NSFileManager defaultManager] directoryContentsAtPath:cookiesFolderPath];
	
						 /*
						 NSArray *germanMakes = @[@"Mercedes-Benz", @"BMW", @"Porsche",
                         @"Opel", @"Volkswagen", @"Audi"];

						NSPredicate *beforeL = [NSPredicate predicateWithBlock:
							^BOOL(id evaluatedObject, NSDictionary *bindings) {
								NSComparisonResult result = [@"L" compare:evaluatedObject];
								if (result == NSOrderedDescending) {
									return YES;
								} else {
									return NO;
								}
							}];
						NSArray *makesBeforeL = [germanMakes
												 filteredArrayUsingPredicate:beforeL];
						NSLog(@"%@", makesBeforeL);    // BMW, Audi
						 */
						 
                         //for (WKWebsiteDataRecord *record in records) {
                             //NSLog(@"WKWebsiteDataRecord:%@",[record description]);
                         //}
						 //NSUInteger elements = [records count];
						 
						 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"No cookie found. %@", filelist]];
						 
						 [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                     }];
		
		
		/*
        NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:urlString]];
        //NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        NSUInteger *elements = [cookies count];
		
        __block NSString *cookieValue;
        
        [cookies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSHTTPCookie *cookie = obj;
			
            if([cookie.name isEqualToString:cookieName])
            {
                cookieValue = cookie.value;
                *stop = YES;
            }
        }];
        if (cookieValue != nil) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"cookieValue":cookieValue}];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"No cookie found. count=%d   %@", elements, cookies]];
        }

    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"URL was null"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	*/
}

 - (void)setCookieValue:(CDVInvokedUrlCommand*)command
{
    //[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    CDVPluginResult* pluginResult = nil;
    NSString* urlString = [command.arguments objectAtIndex:0];
    NSString* cookieName = [command.arguments objectAtIndex:1];
    NSString* cookieValue = [command.arguments objectAtIndex:2];

     NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
     [cookieProperties setObject:cookieName forKey:NSHTTPCookieName];
     [cookieProperties setObject:cookieValue forKey:NSHTTPCookieValue];
     [cookieProperties setObject:urlString forKey:NSHTTPCookieOriginURL];
     [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];

    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    NSArray* cookies = [NSArray arrayWithObjects:cookie, nil];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:url mainDocumentURL:nil];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Set cookie executed"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)setCookieOption:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSMutableDictionary* options = [command.arguments objectAtIndex:0];
    NSDictionary *properties = [self mapCookieProperties:options];
    NSLog(@"Setting cookie with properties: %@", properties);
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Set cookie executed"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];}

- (void)clearCookies:(CDVInvokedUrlCommand*)command
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	
/*
IOS 9
WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
[dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                 completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                     for (WKWebsiteDataRecord *record  in records)
                     {
                         if ( [record.displayName containsString:@"facebook"])
                         {
                             [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                       forDataRecords:@[record]
                                                                    completionHandler:^{
                                                                        NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                    }];
                         }
                     }
                 }];

IOS 8
NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
NSError *errors;
[[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
				 
Alternative

var libraryPath : String = NSFileManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first!.path!
libraryPath += "/Cookies"
do {
    try NSFileManager.defaultManager().removeItemAtPath(libraryPath)
} catch {
    print("error")
}
NSURLCache.sharedURLCache().removeAllCachedResponses()
*/
}


-(NSDictionary*)mapCookieProperties:(NSDictionary*)options {
    NSDictionary *cookiePropertiesMap = @{
      @"comment": NSHTTPCookieComment,
      @"commentUrl": NSHTTPCookieCommentURL,
      @"discard": NSHTTPCookieDiscard,
      @"domain": NSHTTPCookieDomain,
      @"expires": NSHTTPCookieExpires,
      @"maximumAge": NSHTTPCookieMaximumAge,
      @"name": NSHTTPCookieName,
      @"originUrl": NSHTTPCookieOriginURL,
      @"path": NSHTTPCookiePath,
      @"port": NSHTTPCookiePort,
      @"secure": NSHTTPCookieSecure,
      @"value": NSHTTPCookieValue,
      @"version": NSHTTPCookieVersion,
    };
    NSMutableDictionary* properties = [NSMutableDictionary dictionary];
    for (NSString *key in options) {
        id value = [options objectForKey:key];
        if ([key isEqual: @"expires"]) {
            NSTimeInterval time = (int) value;
            value = [[NSDate date] dateByAddingTimeInterval:time];
        }
        NSString *property = [cookiePropertiesMap objectForKey:key];
        if (value && property) {
            [properties setObject:value forKey:property];
        }
    }
    return properties;
}

@end
