//
//  PBKeys.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_PBKeys_h
#define Pushbullet_PBKeys_h

#import <Cocoa/Cocoa.h>

//------------------------------- Pushes Keys

extern NSString * const kPBTypeKey;
extern NSString * const kPBSubtypeKey;

extern NSString * const kPBPushKey;

extern NSString * const kPBTitleKey;
extern NSString * const kPBBodyKey;

extern NSString * const kPBUrlKey;

extern NSString * const kPBAddressKey;
extern NSString * const kPBNameKey;

extern NSString * const kPBItemsKey;

extern NSString * const kPBFileNameKey;
extern NSString * const kPBFileTypeKey;
extern NSString * const kPBFileUrlKey;
extern NSString * const kPBUploadUrlKey;

extern NSString * const kPBDeviceIdenKey;
extern NSString * const kPBEmailKey;

extern NSString * const kPBChannelIdenKey;
extern NSString * const kPBChannelTagKey;
extern NSString * const kPBClientIdenKey;

extern NSString * const kPBSourceDeviceIdenKey;
extern NSString * const kPBTargetDeviceIdenKey;

//-------------------------------------

extern NSString * const kPBIdenKey;
extern NSString * const kPBCreatedKey;
extern NSString * const kPBModifiedKey;
extern NSString * const kPBActiveKey;
extern NSString * const kPBDismissedKey;
extern NSString * const kPBSenderIdenKey;
extern NSString * const kPBSenderEmailKey;
extern NSString * const kPBSenderEmailNormalizedKey;
extern NSString * const kPBReceiverIdenKey;
extern NSString * const kPBReceiverEmailKey;
extern NSString * const kPBReceiverEmailNormalizedKey;

//--------------------------------------

extern NSString * const kPBApplicationNameKey;
extern NSString * const kPBClientVersionKey;
extern NSString * const kPBConversationIdenKey;
extern NSString * const kPBDismissableKey;
extern NSString * const kPBHasRootKey;
extern NSString * const kPBIconKey;
extern NSString * const kPBNotificationIDKey;
extern NSString * const kPBNotificationTagKey;
extern NSString * const kPBPackageNameKey;
extern NSString * const kPBSourceUserIdenKey;
extern NSString * const kPBMessageKey;

extern NSString * const kPBFileContentKey;

//--------------------------------------



//-------------------------------------- Global Respones

extern NSString * const kPBUserKey;
extern NSString * const kPBPushesKey;
extern NSString * const kPBContactsKey;
extern NSString * const kPBDevicesKey;
extern NSString * const kPBSubscriptionsKey;
extern NSString * const kPBDataKey;

//-------------------------------------- Devices Keys

extern NSString * const kPBNicknameKey;

//-------------------------------------- Pushes Types

extern NSString * const kPBLinkType;
extern NSString * const kPBNoteType;
extern NSString * const kPBListType;
extern NSString * const kPBAddressType;
extern NSString * const kPBFileType;

extern NSString * const kPBDismissalType;
extern NSString * const kPBMirrorType;

extern NSString * const kPBMessagingExtensionReplyKey;



#endif
