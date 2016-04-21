//
//  MainWindowController.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 12/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_MainWindowController_h
#define Pushbullet_MainWindowController_h

#import <Cocoa/Cocoa.h>
#import "PBOutlineView.h"
#import "PBTableViewDelegate.h"
#import "PBTableViewDataSource.h"
#import "PBTableView.h"

#import "NSTextViewWithPlaceHolder.h"

@interface PBMainWindowController : NSWindowController <NSTableViewDelegate, NSOutlineViewDelegate, NSTableViewDataSource, NSOutlineViewDataSource, NSWindowDelegate>

@property IBOutlet NSWindow * mainWindow;

@property (nonatomic) IBOutlet id _delegate;

@property IBOutlet NSUserDefaultsController *userDefaultsController;

@property IBOutlet NSArrayController * pushesArrayController;
@property IBOutlet NSTreeController * recipientsTreeController;
@property IBOutlet NSMutableArray * recipientsArray;
@property IBOutlet NSArrayController *recipientsArrayController;
@property (strong) PBTableViewDataSource * dataSource;

@property IBOutlet NSScrollView * pushesScrollView;
@property IBOutlet NSScrollView * oneItemScrollView;

@property IBOutlet PBTableView * pushesTable;
@property IBOutlet PBTableView * oneItemTable;
@property IBOutlet PBOutlineView * recipientsOutlineView;

@property IBOutlet NSSegmentedControl *segmentedToolBarItem;
@property IBOutlet NSButton *createPushButton;
@property IBOutlet NSSearchField *searchField;

@property (assign) BOOL isShowingOneItem;

@property IBOutlet NSMenu * createPushMenu;
@property IBOutlet NSWindow * createPushSheet;
@property IBOutlet NSPopUpButton * pushSheetRecpipientButton;
@property IBOutlet NSTabView * pushSheetTabView;
@property IBOutlet NSTextField * pushSheetTitleTextField, * pushSheetUrlTextField;
@property IBOutlet NSTextViewWithPlaceHolder *pushSheetNoteBodyTextField, *pushSheetLinkBodyTextField;

-(NSPredicate *) defaultPredicate;

+(instancetype) sharedWindowController;

- (void) setDelegate:(id)delegate;
- (id) delegate;
- (void) removeDelegate;

- (IBAction) segmentedControlClicked:(id)sender;
- (IBAction)searchPushesTable:(id)sender;

- (IBAction) showCreatePushSheet:(id)sender;
- (IBAction) closeCreatePushSheet:(id)sender;
- (IBAction) sendPushAndCloseCreatePushSheet:(id)sender;

@end
#endif
