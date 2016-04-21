//
//  PBSignoutWindowController.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 14/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_PBSignoutWindowController_h
#define Pushbullet_PBSignoutWindowController_h

#import <Cocoa/Cocoa.h>

@interface PBSignoutWindowController : NSWindowController

@property BOOL isDelegateValid;
@property IBOutlet id _delegate;
@property IBOutlet NSWindow *theWindow;
@property IBOutlet NSButton *signOutButton;
@property IBOutlet NSButton *cancelButton;
@property IBOutlet NSButton *removeDeviceCheckBox;


- (void) setDelegate:(id)delegate;
- (void) removeDelegate;
- (id) delegate;

- (IBAction) cancel:(id)sender;
- (IBAction) signout:(id)sender;

@end

@interface NSObject(PBSignoutWindowControllerDelegate)

- (void) userSignsOut:(BOOL)removeDevice;
- (void) cancelSignOut;

@end

#endif
