//
//  PBPush.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 11/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBKeys.h"
#import "PBPush.h"

#import "PBDefines.h"

@implementation PBPush

@synthesize type;
@synthesize subtype;

@synthesize push;

@synthesize title;
@synthesize body;

@synthesize url;

@synthesize address;
@synthesize name;

@synthesize items;

@synthesize file_name;
@synthesize file_type;
@synthesize file_url;

@synthesize device_iden;
@synthesize email;

@synthesize channel_iden;
@synthesize channel_tag;
@synthesize client_iden;

@synthesize source_device_iden;
@synthesize target_device_iden;

//-------------------------------------

@synthesize iden;
@synthesize created;
@synthesize modified;
@synthesize active;
@synthesize dismissed;
@synthesize sender_iden;
@synthesize sender_email;
@synthesize sender_email_normalized;
@synthesize receiver_iden;
@synthesize receiver_email;
@synthesize receiver_email_normalized;

//--------------------------------------

@synthesize application_name;
@synthesize client_version;
@synthesize conversation_iden;
@synthesize dismissable;
@synthesize has_root;
@synthesize icon;
@synthesize notification_id;
@synthesize notification_tag;
@synthesize package_name;
@synthesize source_user_iden;
@synthesize message;

//--------------------------------------

+ (NSDictionary *) dictionaryWithPush:(PBPush*)push  {
    NSMutableDictionary* dico = [[NSMutableDictionary alloc] init];
    
    if (push.type != nil) [dico setObject:push.type forKey:kPBTypeKey];
    if (push.subtype !=nil) [dico setObject:push.subtype forKey:kPBSubtypeKey];
    
    if (push.push != nil) {
        NSDictionary *pushDico = [PBPush dictionaryWithPush:push.push];
        [dico setObject:pushDico forKey:kPBPushKey];
    }
    
    if (push.title != nil) [dico setObject:push.title forKey:kPBTitleKey];
    if (push.body != nil) [dico setObject:push.body forKey:kPBBodyKey];
    
    if (push.url != nil) [dico setObject:push.url forKey:kPBUrlKey];
    
    if (push.address != nil) [dico setObject:push.address forKey:kPBAddressKey];
    if (push.name != nil) [dico setObject:push.name forKey:kPBNameKey];
    
    if (push.items != nil) [dico setObject:push.items forKey:kPBItemsKey];
    
    if (push.file_name != nil) [dico setObject:push.file_name forKey:kPBFileNameKey];
    if (push.file_type != nil) [dico setObject:push.file_type forKey:kPBFileTypeKey];
    if (push.file_url != nil) [dico setObject:push.file_url forKey:kPBFileUrlKey];
    
    if (push.device_iden != nil) [dico setObject:push.device_iden forKey:kPBDeviceIdenKey];
    if (push.email != nil) [dico setObject:push.email forKey:kPBEmailKey];
    
    if (push.channel_iden != nil) [dico setObject:push.channel_iden forKey:kPBChannelIdenKey];
    if (push.channel_tag != nil) [dico setObject:push.channel_tag forKey:kPBChannelTagKey];
    if (push.client_iden != nil) [dico setObject:push.client_iden forKey:kPBClientIdenKey];
    
    if (push.source_device_iden != nil) [dico setObject:push.source_device_iden forKey:kPBSourceDeviceIdenKey];
    if (push.target_device_iden != nil) [dico setObject:push.target_device_iden forKey:kPBTargetDeviceIdenKey];
    
    if (push.file_content != nil) [dico setObject:push.file_content forKey:kPBFileContentKey];
    
    //-------------------------------------
    
    if (push.iden != nil) [dico setObject:push.iden forKey:kPBIdenKey];
    
    if (push.created != 0) {
        NSNumber *created = [NSNumber numberWithDouble:push.created];
        [dico setValue:created forKey:kPBCreatedKey];
    }
    
    if (push.modified != 0) {
        NSNumber *modified = [NSNumber numberWithDouble:push.modified];
        [dico setObject:modified forKey:kPBModifiedKey];
    }
    
    if (push.active != nil) [dico setObject:push.active forKey:kPBActiveKey];
    if (push.dismissed != nil) [dico setObject:push.dismissed forKey:kPBDismissedKey];
    
    if (push.sender_iden != nil) [dico setObject:push.sender_iden forKey:kPBSenderIdenKey];
    if (push.sender_email != nil) [dico setObject:push.sender_email forKey:kPBSenderEmailKey];
    if (push.sender_email_normalized != nil) [dico setObject:push.sender_email_normalized forKey:kPBSenderEmailNormalizedKey];
    if (push.receiver_iden != nil) [dico setObject:push.receiver_iden forKey:kPBReceiverIdenKey];
    if (push.receiver_email != nil) [dico setObject:push.receiver_email forKey:kPBReceiverEmailKey];
    if (push.receiver_email_normalized != nil) [dico setObject:push.receiver_email_normalized forKey:kPBReceiverEmailNormalizedKey];
    
    //--------------------------------------
    
    if (push.application_name != nil) [dico setObject:push.application_name forKey:kPBApplicationNameKey];
    if (push.client_version != nil) [dico setObject:push.client_version forKey:kPBClientVersionKey];
    if (push.conversation_iden != nil) [dico setObject:push.conversation_iden forKey:kPBConversationIdenKey];
    if (push.dismissable != nil) [dico setObject:push.dismissable forKey:kPBDismissableKey];
    if (push.has_root != nil) [dico setObject:push.has_root forKey:kPBHasRootKey];
    if (push.icon != nil) [dico setObject:push.icon forKey:kPBIconKey];
    if (push.notification_id != nil) [dico setObject:push.notification_id forKey:kPBNotificationIDKey];
    if (push.notification_tag != nil) [dico setObject:push.notification_tag forKey:kPBNotificationTagKey];
    if (push.package_name != nil) [dico setObject:push.package_name forKey:kPBPackageNameKey];
    if (push.source_user_iden != nil) [dico setObject:push.source_user_iden forKey:kPBSourceUserIdenKey];
    if (push.message != nil) [dico setObject:push.message forKey:kPBMessageKey];
    
    return dico;
}



+ (NSData *) dataWithPush:(PBPush*)push {
    NSDictionary * dico = [PBPush dictionaryWithPush:push];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dico options:0 error:&error];
    if (error) {
        PBLOGE(error);
        return nil;
    }
    //PBLOGF(@"dataWithPush : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])
    if (data != nil)
        return data;
    else
        return nil;
}


+ (instancetype) pushWithDictionary:(NSDictionary*)dico {
    PBPush *push = [[PBPush alloc] init];
    
    push.type = [dico valueForKey:kPBTypeKey];
    push.subtype = [dico valueForKey:kPBSubtypeKey];
    
    if ([dico valueForKey:kPBPushKey]) {
        push.push = [PBPush pushWithDictionary:[dico valueForKey:kPBPushKey]];
    }//dictionary
    
    push.title = [dico valueForKey:kPBTitleKey];
    push.body = [dico valueForKey:kPBBodyKey];
    
    push.url = [dico valueForKey:kPBUrlKey];//URL
    
    push.address = [dico valueForKey:kPBAddressKey];
    push.name = [dico valueForKey:kPBNameKey];
    
    push.items = [dico valueForKey:kPBItemsKey];//array
    
    push.file_name = [dico valueForKey:kPBFileNameKey];
    push.file_type = [dico valueForKey:kPBFileTypeKey];
    push.file_url = [dico valueForKey:kPBFileUrlKey]; //URL
    
    push.device_iden = [dico valueForKey:kPBDeviceIdenKey];
    push.email = [dico valueForKey:kPBEmailKey];
    
    push.channel_iden = [dico valueForKey:kPBChannelIdenKey];
    push.channel_tag = [dico valueForKey:kPBChannelTagKey];
    push.client_iden = [dico valueForKey:kPBClientIdenKey];
    
    push.source_device_iden = [dico valueForKey:kPBSourceDeviceIdenKey];
    push.target_device_iden = [dico valueForKey:kPBTargetDeviceIdenKey];
    
    //-------------------------------------
    
    push.iden = [dico valueForKey:kPBIdenKey];
    push.created = [[dico valueForKey:kPBCreatedKey] doubleValue];
    push.modified = [[dico valueForKey:kPBModifiedKey] doubleValue];
    push.active = [dico valueForKey:kPBActiveKey];
    push.dismissed = [dico valueForKey:kPBDismissedKey];
    push.sender_iden = [dico valueForKey:kPBSenderIdenKey];
    push.sender_email = [dico valueForKey:kPBSenderEmailKey];
    push.sender_email_normalized = [dico valueForKey:kPBSenderEmailNormalizedKey];
    push.receiver_iden = [dico valueForKey:kPBReceiverIdenKey];
    push.receiver_email = [dico valueForKey:kPBReceiverEmailKey];
    push.receiver_email_normalized = [dico valueForKey:kPBReceiverEmailNormalizedKey];
    
    //--------------------------------------
    
    push.application_name = [dico valueForKey:kPBApplicationNameKey];
    push.client_version = [dico valueForKey:kPBClientVersionKey];
    push.conversation_iden = [dico valueForKey:kPBConversationIdenKey];
    push.dismissable = [dico valueForKey:kPBDismissableKey];
    push.has_root = [dico valueForKey:kPBHasRootKey];
    push.icon = [dico valueForKey:kPBIconKey];
    push.notification_id = [dico valueForKey:kPBNotificationIDKey];
    push.notification_tag = [dico valueForKey:kPBNotificationTagKey];
    push.package_name = [dico valueForKey:kPBPackageNameKey];
    push.source_user_iden = [dico valueForKey:kPBSourceUserIdenKey];
    push.message = [dico valueForKey:kPBMessageKey];
    
    return push;
}

+ (instancetype) pushWithData:(NSData *)data {
    NSError * error __autoreleasing = nil;
    NSDictionary * dico = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        PBLOGE(error);
        NSLog(@"%@ : %s : Error(%li) : %@", [self className], __PRETTY_FUNCTION__, error.code, error.localizedDescription);
        return nil;
    }
    return [PBPush pushWithDictionary:dico];
}


+ (NSImage *) imageWithPush:(PBPush *)push {
    if (push.icon != nil){
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:push.icon options:NSDataBase64DecodingIgnoreUnknownCharacters];
        return [[NSImage alloc] initWithData:imageData]; //image
    }
    return nil;
}
                                    

- (instancetype) init {
    self = [super init];
    
    self.type = nil;
    
    self.push = nil;
    
    self.title = nil;
    self.body = nil;
    
    self.url = nil;
    
    self.address = nil;
    self.name = nil;
    
    self.items = nil;
    
    self.file_name = nil;
    self.file_type = nil;
    self.file_url = nil;
    self.upload_url = nil;
    
    self.device_iden = nil;
    self.email = nil;
    
    self.channel_tag = nil;
    self.client_iden = nil;
    
    self.source_device_iden = nil;
    self.target_device_iden = nil;
    
    //-------------------------------------
    
    self.iden = nil;
    self.created = 0;
    self.modified = 0;
    self.active = nil;
    self.dismissed = nil;
    self.sender_iden = nil;
    self.sender_email = nil;
    self.sender_email_normalized = nil;
    self.receiver_iden = nil;
    self.receiver_email = nil;
    self.receiver_email_normalized = nil;
    
    //--------------------------------------
    
    self.application_name = nil;
    self.client_version = nil;
    self.conversation_iden = nil;
    self.dismissable = nil;
    self.has_root = nil;
    self.icon = nil;
    self.notification_id = nil;
    self.notification_tag = nil;
    self.package_name = nil;
    self.source_user_iden = nil;
    
    self.file_content = nil;
    
    
    return self;
}

@end