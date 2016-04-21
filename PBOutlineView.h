//
//  PBOutlineViewDelegate.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "PBOutlineViewCell.h"

static NSString * PBOutlineVewSelectionDidChangeNotification;

@interface PBOutlineView : NSOutlineView

@property (assign) BOOL editSessionOnGoing;

@property IBOutlet PBOutlineViewCellHeader *dummyHeader;
@property IBOutlet PBOutlineViewCellItem *dummyItem;
@property IBOutlet NSButton *globalEditButton;

- (IBAction) showEditButtons:(id)sender;
- (NSView *) viewForItem:(id)item;

@end
