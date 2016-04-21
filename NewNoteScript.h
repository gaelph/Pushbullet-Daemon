//
//  NewNoteScript.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_NewNoteScript_h
#define Pushbullet_NewNoteScript_h

#import <Cocoa/Cocoa.h>

@interface NNScript : NSObject

@property NSString *source;
@property NSAppleScript *script;
@property NSAppleEventDescriptor *descriptor;

- (void) createNewNoteWithTitle:(NSString *)title WithBody:(NSString *)body;
- (void) createNewReminderWithTitle:(NSString *)title WithObjects:(NSArray *)list;

@end

#endif
