//
//  AppDelegate.h
//  Pushbullet Daemon
//
//  Created by Gaël PHILIPPE on 08/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>
#import "SRWebSocket.h"
#import "Pushbullet.h"
#import "NewNoteScript.h"
#import "PBSignInWindowController.h"
#import "PBSignoutWindowController.h"
#import "PBSettings.h"
#import "MainWindowController.h"
#import "PBMenuDelegate.h"
#import "PBOutlineView.h"

static NSString * PBAppGroup = @"group.pushbullet";
static NSString * CachesFolder = @"Library/Caches/";
static NSString * AppSupportFolder = @"Library/Application Support/";




@interface NotificationCenter : NSObject<NSUserNotificationCenterDelegate>

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
        didDeliverNotification:(NSUserNotification *)notification;

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification;

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification;

@end

@interface PBDelegate : NSObject <NSApplicationDelegate>

//Core Data Stuff
@property (readonly, strong, nonatomic) IBOutlet NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) IBOutlet NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) IBOutlet NSPersistentStoreCoordinator *persistentStoreCoordinator;

//Settings
@property (retain) NSString *_apiKey;
@property IBOutlet NSUserDefaults *storage;
@property IBOutlet NSUserDefaultsController * storageController;
@property BOOL mirroring;
@property NSDate * deliveryDate;
@property BOOL snoozing;
@property double lastTimestamp;

//data
@property NSMutableArray *devices;
@property NSArray *subscriptions;
@property NSArray *contacts;
@property IBOutlet NSMutableArray *pushes;
@property NSMutableArray *mirroredPushes;
@property NSDictionary *user;
@property NSMutableDictionary *imageDataBank;
@property IBOutlet NSMutableArray *recipients;

@property NSString *thisUserIden;
@property NSString *thisDeviceIden;
@property NSString *thisComputerName;
@property NSString *thisComputerModel;

//socket
@property PBWebSocket * _socket;

//notification stuff
@property NotificationCenter *notificationCenter;
@property NSMutableArray *pendingNotifications;


//menus
@property PBMenuDelegate * menuDelegate;
@property BOOL hasMenu;
@property BOOL hasDockIcon;
@property (nonatomic) NSMenu *statusMenu;
@property (nonatomic) NSMenu *dockMenu;

//Window Controllers
@property IBOutlet PBSignoutWindowController *signOutWindow;
@property IBOutlet PBSignInWindowController *signInWindow;
@property IBOutlet PBSettingsWindowController *settingsWindow;
@property IBOutlet PBMainWindowController *mainWindowController;

//All this shoudl go to future main window controller
@property NSPredicate * devicesPredicate;
@property NSPredicate * pushesPredicate;
@property IBOutlet NSArrayController * devicesArrayController;
@property IBOutlet NSArrayController * pushesArrayController;
@property IBOutlet NSTreeController * recipientsTreeController;

@property IBOutlet NSTableView * pushesTable;
@property IBOutlet PBOutlineView * recipientsOutlineView;

@property IBOutlet NSWindow * mainWindow;

+ (void) initialize;
+ (instancetype) sharedPBDelegate;
- (instancetype) init;

//TODO: Have more functions declared in the header ?
- (IBAction) toggleMirrorNotifications:(id)sender;
- (IBAction) snooze:(id)sender;
- (void) cancelSignOut;
- (IBAction) signOut:(id)sender;
- (void) userSignsOut:(BOOL)removeDevice;

-(void) shouldRemovePushFromServer:(NSNotification *)notification;

-(void) shouldRemoveSourceFromServer:(NSNotification *)notification;

@end


