//
//  PBPush.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 10/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_PBPush_h
#define Pushbullet_PBPush_h

#import <Cocoa/Cocoa.h>

@interface PBPush : NSObject

@property NSString* type;
@property NSString* subtype;

@property PBPush* push;

@property NSString* title;
@property NSString* body;

@property NSString* url;

@property NSString* address;
@property NSString* name;

@property NSArray* items;

@property NSString* file_name;
@property NSString* file_type;
@property NSString* file_url;
@property NSString* upload_url;

@property NSString* device_iden;
@property NSString* email;

@property NSString* channel_iden;
@property NSString* channel_tag;
@property NSString* client_iden;

@property NSString* source_device_iden;
@property NSString* target_device_iden;

//-------------------------------------

@property NSString* iden;
@property double created;
@property double modified;
@property NSNumber* active;
@property NSNumber* dismissed;
@property NSString* sender_iden;
@property NSString* sender_email;
@property NSString* sender_email_normalized;
@property NSString* receiver_iden;
@property NSString* receiver_email;
@property NSString* receiver_email_normalized;

//--------------------------------------

@property NSString* application_name;
@property NSString* client_version;
@property NSString* conversation_iden;
@property NSNumber* dismissable;
@property NSNumber* has_root;
@property NSString* icon;
@property NSString* notification_id;
@property NSString* notification_tag;
@property NSString* package_name;
@property NSString* source_user_iden;
@property NSString* message;

//----------------------------------------

@property NSData *file_content;


+ (NSDictionary *) dictionaryWithPush:(PBPush*)push;
+ (NSData *) dataWithPush:(PBPush*)push;

+ (instancetype) pushWithDictionary:(NSDictionary*)dico;
+ (instancetype) pushWithData:(NSData*)data;

+ (NSImage *) imageWithPush:(PBPush *)push;

- (instancetype) init;

@end



#endif
