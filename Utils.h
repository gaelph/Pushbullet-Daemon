//
//  Utils.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 11/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_Utils_h
#define Pushbullet_Utils_h

#import <Cocoa/Cocoa.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface Utils : NSObject

+ (void) openURL:(NSString*)url;
+ (NSBitmapImageFileType) typeForExtension:(NSString *)extension;
+ (NSString *) computerName;
+ (NSString *) computerModel;

+ (NSString *) getDateStringFromDate:(NSDate *)date withDateFormatter:(NSDateFormatter *) formatter;

@end


#endif
