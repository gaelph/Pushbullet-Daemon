//
//  PBSignoutWindowController.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 14/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBSignoutWindowController.h"

@implementation PBSignoutWindowController

@synthesize _delegate;
@synthesize theWindow;
@synthesize signOutButton;
@synthesize cancelButton;
@synthesize removeDeviceCheckBox;

- (void) setDelegate:(id)delegate {
    self.isDelegateValid = NO;
    if ([delegate respondsToSelector:@selector(cancelSignOut)]) {
        if ([delegate respondsToSelector:@selector(userSignsOut:)]) {
            self.isDelegateValid = YES;
        }
    }
}

- (void) removeDelegate {
    _delegate = nil;
}

- (id) delegate {
    return _delegate;
}

- (IBAction) cancel:(id)sender {
    [theWindow close];
    if (self.isDelegateValid == YES) {
        [_delegate cancelSignOut];
    }
    
}

- (IBAction) signout:(id)sender {
    BOOL remove = (removeDeviceCheckBox.state == 0)?NO:YES;
    if (self.isDelegateValid == YES) {
        [_delegate userSignsOut:remove];
    }
    [theWindow close];
}

- (void) awakeFromNib {
    [theWindow orderFrontRegardless];
}


@end