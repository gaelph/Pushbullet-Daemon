//
//  PBSettings.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 15/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_PBSettings_h
#define Pushbullet_PBSettings_h
#import <Cocoa/Cocoa.h>

@interface MutableImmutableValueTransformer : NSValueTransformer

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;

- (id) transformedValue:(id)value;
- (id) reverseTransformedValue:(id)value;

@end




@interface PBSettingsWindowController : NSWindowController

@property (weak) id _delegate;

@property IBOutlet NSWindow * mainWindow;
@property IBOutlet NSWindow * urlWindow;
@property IBOutlet NSButton * cancelButton;
@property IBOutlet NSButton * saveButton;
@property (strong) IBOutlet NSTableView * tableView;
@property IBOutlet NSTextField * urlTextField;
@property IBOutlet NSButton * AutostartBox;
@property IBOutlet NSButton * MenuIconBox;
@property IBOutlet NSButton * DockIconBox;
@property IBOutlet NSUserDefaults * userDefaults;
@property IBOutlet NSUserDefaultsController *userDefaultsController;
@property IBOutlet NSTabView * tabView;
@property IBOutlet NSImageView * userImageView;

@property NSInteger currentRow;

@property (retain, strong) NSMutableArray * _packages;
- (NSMutableArray *) packages;
- (void) setPackages:(NSArray *)packages;

- (void) setDelegate:(id)delegate;
- (id) delegate;
- (void) removeDelegate;

- (void) setUserDefaults:(NSUserDefaults *)userDefaults;

- (IBAction) chooseURL:(id)sender;
- (IBAction) chooseApp:(id)sender;

- (IBAction) cancelChooseURL:(id)sender;
- (IBAction) setURL:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction) saveSettings:(id)sender;

- (IBAction)selectTab:(id)sender;

- (IBAction) updateCheckBoxes:(id)sender;

@end

@interface NSObject(PBSettingsWindowReceiver)

- (void) cancelSettings;

@end

#endif
