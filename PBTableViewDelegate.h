//
//  PBTableViewDelegate.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 08/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_PBTableViewDelegate_h
#define Pushbullet_PBTableViewDelegate_h
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "PBTableViewCell.h"

static NSString * PBTableRemoveItemNotification = @"PBTableRemoveItemNotification";
static NSString * PBTableAddItemNotification = @"PBTableAddItemNotification";


@interface PBTableViewDelegate : NSObject <NSTableViewDelegate>

@property NSTableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property IBOutlet PBTableViewCell *dummy;
@property IBOutlet NSDateFormatter * dateFormatter;
@property NSMutableArray * views;

- (NSMutableArray *) dataSource;
- (IBAction)showMenu:(id)sender;
- (void)tableView:(NSTableView*)tableView deletePushForView:(NSView *)view;


@end

@interface NSObject(NSTableViewDelegate)

- (void) tableView:(NSTableView *)tableView configureView:(PBTableViewCell *)view atRow:(NSInteger)row;

@end

#endif
