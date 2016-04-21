//
//  AppDelegate.m
//  Pushbullet Daemon
//
//  Created by Gaël PHILIPPE on 08/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#import "PBDelegate.h"
#import "PBDefines.h"
#import "Utils.h"
#import "ImageLoader.h"
#import <AppKit/NSNibLoading.h>
#import <ApplicationServices/ApplicationServices.h>
#import "LaunchAtLoginController.h"
#import "Node.h"
#import "ImageFromPush.h"

@implementation NotificationCenter : NSObject

- (void)userNotificationCenter:(NSUserNotificationCenter *)center removeNotification:(NSUserNotification *)notification {
    PBDelegate * parent = [[NSApplication sharedApplication] delegate];
    NSArray * parentPushes = [NSArray arrayWithArray:parent.pushes];
    @synchronized(parent.pushes) {
        for (NSDictionary * push in parentPushes) {
            if ([notification.identifier isEqualToString:[push valueForKey:kPBIdenKey]]) {
                [parent.pushes removeObject:push];
            }
        }
        parentPushes = nil;
    }
    [center removeDeliveredNotification:notification];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
        didDeliverNotification:(NSUserNotification *)notification {
}

#pragma mark This is where we dispatch actions on notification click :
- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification {
    PBDelegate * parent = [[NSApplication sharedApplication] delegate];
    
    if (notification.activationType == NSUserNotificationActivationTypeContentsClicked) {
        //In case of message, redeliver the notification so that the user can reply
        if (notification.hasReplyButton) {
            NSUserNotification * newNotification = [notification copy];
            newNotification.soundName = nil;
            [center removeDeliveredNotification:notification];
            [center deliverNotification:newNotification];
            return;
        }
        
        //If notification neither a link, a file, a note, a reminder, nor an address
        if (notification.userInfo) {
            NSString *package_name = [notification.userInfo valueForKey:kPBPackageNameKey];
            
            //If notification has a package name \
              Look for predefined action in the settings
            if (package_name) {
                NSUserDefaults * storage = [[NSUserDefaults alloc] initWithSuiteName:PBAppGroup];
                NSArray * packages = [storage valueForKey:@"packages"];
                @synchronized(packages) {
                    for (NSDictionary * pack in packages) {
                        if ([package_name isEqualToString:[pack valueForKey:kPBPackageNameKey]]) {
                            NSDictionary * action = [pack valueForKey:@"action"];
                            //No Action
                            if ([[action valueForKey:@"type"] isEqualTo:[NSNumber numberWithInt:0]]) {
                                
                                [self userNotificationCenter:center removeNotification:notification];
                                return;
                            
                                //Launch an app
                            } else if ([[action valueForKey:@"type"] isEqualTo:[NSNumber numberWithInt:2]]) {
                                NSString * app = [action valueForKey:@"info2"];
                                [[NSWorkspace sharedWorkspace] launchApplication:app];
                                
                                [self userNotificationCenter:center removeNotification:notification];
                                return;
                                
                                //open a webpage
                            } else if ([[action valueForKey:@"type"] isEqualTo:[NSNumber numberWithInt:1]]) {
                                NSString * url = [action valueForKey:@"info"];
                                [Utils openURL:url];
                                
                                [self userNotificationCenter:center removeNotification:notification];
                                return;
                            }
                        }
                    }
                }
            }
            
            [self userNotificationCenter:center removeNotification:notification];
            return;
        }
        
        //Notification is either a link, a file, a note, a reminder, or an address
        NSArray * parentPushes = [parent.pushes copy];
        @synchronized(parent.pushes) {
            for (NSDictionary *pushDico in parentPushes) {
                if ([[pushDico valueForKey:kPBIdenKey] isEqualTo: notification.identifier]) {
                    PBPush *push = [PBPush pushWithDictionary:pushDico];
                    
                    //URL
                    if (push.url) {
                        [Utils openURL:push.url];
                        
                        //File
                    } else if (push.file_url) {
                        [Utils openURL:push.file_url];
                    }
                    
                    //Note
                    else if ([push.type isEqualToString:kPBNoteType]) {
                        NNScript *script = [NNScript alloc];
                        [script createNewNoteWithTitle:push.title WithBody:push.body];
                    }
                    
                    //Reminder
                    else if ([push.type isEqualToString:kPBListType]) {
                        NNScript *script = [NNScript alloc];
                        
                        [script createNewReminderWithTitle:push.title WithObjects:push.items];
                    }
                    
                    //Address
                    else if ([push.type isEqualToString:kPBAddressType]) {
                        NSString *searchRequest = [notification.subtitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        searchRequest = [searchRequest stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
                        NSString *mapsURL = [NSString stringWithFormat:@"https://www.google.com/maps/?q=%@", searchRequest];
                        [Utils openURL:mapsURL];
                    }
                    
                    [[PBPushHistoryController sharedPushHistoryController] dismiss:push];
                    
                    [self userNotificationCenter:center removeNotification:notification];
                    return;
                }
            }
            parentPushes = nil;
        }
    } else if (notification.activationType == NSUserNotificationActivationTypeReplied) {
        NSArray * mirroredPushes = [parent.mirroredPushes copy];
        @synchronized(parent.mirroredPushes) {
            for (NSDictionary *pushDico in mirroredPushes) {
                if ([[pushDico valueForKey:kPBConversationIdenKey] isEqualTo: notification.identifier]) {
                    PBPush *push = [PBPush pushWithDictionary:pushDico];
                    PBPush *reply = [[PBPush alloc] init];
                    reply.type = kPBPushKey;
                    PBPush *replyPush = [[PBPush alloc] init];
                    replyPush.type = kPBMessagingExtensionReplyKey;
                    replyPush.package_name = push.package_name;
                    replyPush.source_device_iden = push.source_user_iden;
                    replyPush.target_device_iden = push.source_device_iden;
                    replyPush.conversation_iden = push.conversation_iden;
                    replyPush.message = notification.response.string;
                    reply.push = replyPush;
                    
                    [[PBPushController sharedPushController] push:reply];
                    break;
                }
            }
        }
        mirroredPushes = nil;
    } else if (notification.activationType == NSUserNotificationActivationTypeActionButtonClicked) {
        if ([notification.actionButtonTitle isEqualToString:@"Copy"]) {
            NSPasteboard * pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard clearContents];
            [pasteboard writeFileContents:notification.informativeText];
            
        }
    }
    
    [self userNotificationCenter:center removeNotification:notification];
    
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification {
    return TRUE;
}


@end

@interface PBDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation PBDelegate
@synthesize _apiKey;

@synthesize storage;
@synthesize storageController;
@synthesize mirroring;
@synthesize snoozing;

//@synthesize pushes;
@synthesize devices;

@synthesize subscriptions;
@synthesize contacts;
@synthesize user;
@synthesize mirroredPushes;

@synthesize thisUserIden;
@synthesize thisDeviceIden;

@synthesize _socket;

@synthesize lastTimestamp;

@synthesize notificationCenter;

@synthesize menuDelegate;

@synthesize signInWindow;

#pragma mark -
#pragma mark LoadFinished/Will Terminate

+ (void) initialize {
    //Check if it is already running
    NSArray * apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
    if ([apps count] > 1) {
        //Kill ourself
        exit(0);
    }
}

static PBDelegate * sharedPBDelegate = nil;

+ (instancetype) sharedPBDelegate {
    @synchronized(sharedPBDelegate) {
        if (sharedPBDelegate == nil) {
            sharedPBDelegate = [[PBDelegate alloc] init];
        }
        return sharedPBDelegate;
    }
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        @synchronized(sharedPBDelegate) {
            sharedPBDelegate = self;
        }
        
        //load user settings
        storage = [[NSUserDefaults standardUserDefaults] initWithSuiteName:PBAppGroup];
        storageController = [[NSUserDefaultsController sharedUserDefaultsController] initWithDefaults:[NSUserDefaults standardUserDefaults] initialValues: [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"Defaults" ofType: @"plist"]]];
        
        //load image Cache
        _imageDataBank = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathToCacheFolder]];
        
        if ([storage valueForKey:@"apiKey"] != nil) {
            _apiKey = [storage valueForKey:@"apiKey"];
            //[self gotApiKey:[NSString stringWithString:[storage valueForKey:@"apiKey"]]];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotApiKey:) name:@"PBSignInGotApiKey" object:nil];
    }
    
    return self;
}

//TODO: move these to the Utils Class
- (NSURL *) urlToCacheFolder {
    NSFileManager * fileManager = [[NSFileManager alloc] init];
    NSURL * groupURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:PBAppGroup];
    return [groupURL URLByAppendingPathComponent:CachesFolder];
}

- (NSString *) pathToCacheFolder {
    return [[self urlToCacheFolder] path];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //Load user settings
    if (storage == nil) storage = [[NSUserDefaults alloc] initWithSuiteName:PBAppGroup];
    
    //Check for an api Key
    if (_apiKey != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PBSignInGotApiKey" object:_apiKey];
    } else {
        //TODO: Make this a function like the others
        //If no api Key, it's first lauch --> sign in is in order
        signInWindow = [[PBSignInWindowController alloc] initWithWindowNibName:@"SignInWindow" owner:[NSApplication sharedApplication]];
        signInWindow.delegate = self;
        signInWindow.menuWindow = [signInWindow window];
        [signInWindow.menuWindow setContentView:signInWindow.webview];
        
        [signInWindow.menuWindow orderFrontRegardless];
        [signInWindow.menuWindow makeKeyWindow];
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        
        if (storage == nil) storage = [[NSUserDefaults alloc] initWithSuiteName:PBAppGroup];
        
        //Let's load the defaults
        NSDictionary * defaultsPlist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]];
        
        mirroring = [[defaultsPlist valueForKey:@"mirror_enabled"] boolValue];
        NSArray * packages = [[NSArray alloc] initWithArray:[defaultsPlist valueForKey:@"packages"]];
        BOOL autostart = [[defaultsPlist valueForKey:@"autostart"] boolValue];
        
        [storage setBool:mirroring forKey:@"mirror_enabled"];
        [storage setObject:packages forKey:@"packages"];
        [storage setBool:autostart forKey:@"autostart"];
        [storage synchronize];
    }
    
    //Recover some pending notifications if any
    if ([aNotification.userInfo valueForKey:NSApplicationLaunchUserNotificationKey]) {
        if (self.pendingNotifications == nil) self.pendingNotifications = [[NSMutableArray alloc] init];
        [self.pendingNotifications addObject:[aNotification.userInfo valueForKey:NSApplicationLaunchUserNotificationKey]];
    }
    
    //TODO: Remove when done working on UI
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    
    //add main window controller observer ?
    //TODO: maybe set main window related observers only when the window is up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:nil name:@"PBRemoveRecipientFromServer" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:nil name:@"PBRemovePushFromServer" object:nil];
    
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSKeyedArchiver archiveRootObject:_imageDataBank toFile:[[self pathToCacheFolder] stringByAppendingString:@"images.db"]];
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    [_socket close];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (flag == NO) {
        [self openMainWindow:nil];
    }
    return YES;
}

#pragma mark -
#pragma mark Load Sequence
//Stuff to set up once we've got our api key
- (void) gotApiKey:(NSNotification *)notification {
    _apiKey = [notification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PBSignInGotApiKey" object:nil];
     
    //remove the signin window
    if (signInWindow != nil) signInWindow = nil;
    
    //make sure we have storage and store the api key
    if (storage == nil) storage = [[NSUserDefaults alloc] initWithSuiteName:PBAppGroup];
    [storage setObject:_apiKey forKey:@"apiKey"];
    [storage synchronize];
    
    [self loadPreferences];
    [self loadUI];
    [self initControllers];
    [self startSocket];
}

//TODO: These shouldn't be necessary
- (void) loadPreferences {
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launch = [launchController launchAtLogin];
    [storage setBool:launch forKey:@"autostart"];
    [storage synchronize];
    
    self.hasMenu = [storage boolForKey:@"showmenu"];
    self.hasDockIcon = [storage boolForKey:@"showdock"];
    if (self.hasDockIcon) {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
        SetFrontProcess(&psn);
    }
    
    [self setDevices:[[storage arrayForKey:kPBDevicesKey] mutableCopy]];
    
    [self setContacts:[storage arrayForKey:kPBContactsKey]];
    [self setUser:[storage dictionaryForKey:kPBUserKey]];
    
    [self setPushes:[[storage arrayForKey:kPBPushesKey] mutableCopy]];
    
    lastTimestamp = 0;
    NSNumber* temp = [storage objectForKey:@"modified_since"];
    lastTimestamp = [temp doubleValue];
    
    mirroring = [storage boolForKey:@"mirror_enabled"];
    snoozing = NO;
}

- (NSMenuItem *) addItemWithTitle:(NSString *)title
                   action:(SEL)action
                      tag:(NSInteger)tag
                  enabled:(BOOL)enabled
                   toMenu:(NSMenu *)menu {
    NSMenuItem * item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
    [item setEnabled:enabled];
    [item setTag:tag];
    [menu addItem:item];
    return item;
}

- (NSMenu *) makeMenu:(BOOL)forDock {
    NSMenu *menu = [[NSMenu alloc] init];
    
    if (forDock) {
        if (_dockMenu != nil) {
            return _dockMenu;
        }
    } else {
        if (_statusMenu != nil) {
            return _statusMenu;
        }
    }
    
    [self addItemWithTitle:NSLocalizedStringFromTable(@"SocketStatusClosed", @"StatusMenu", @"") action:nil tag:PBSocketStateTag enabled:NO toMenu:menu];
    
    //TODO: Localize
    [self addItemWithTitle:NSLocalizedStringFromTable(@"ViewPushes", @"StatusMenu", @"") action:@selector(openMainWindow:) tag:PBMainWindowTag enabled:YES toMenu:menu];
    
    [self addItemWithTitle:NSLocalizedStringFromTable(@"Preferences", @"StatusMenu", @"") action:@selector(openPreferences:) tag:PBPreferencesTag enabled:YES toMenu:menu];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    [self addItemWithTitle:NSLocalizedStringFromTable(@"SignOut", @"StatusMenu", @"") action:@selector(signOut:) tag:PBSignoutTag enabled:YES toMenu:menu];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    [self addItemWithTitle:NSLocalizedStringFromTable(@"Snooze", @"StatusMenu", @"") action:@selector(snooze:) tag:PBSnoozeTag enabled:YES toMenu:menu];
    
    NSMenuItem * item = [self addItemWithTitle:NSLocalizedStringFromTable(@"Mirror", @"StatusMenu", @"") action:@selector(toggleMirrorNotifications:) tag:PBMirrorTag enabled:YES toMenu:menu];
    [item setState:mirroring?NSOnState:NSOffState];
    
    if (menuDelegate == nil)
        menuDelegate = [[PBMenuDelegate alloc] init];
    
    [menu setDelegate:menuDelegate];
    [[menuDelegate menus] addObject:menu];
    
    if (!forDock) {
        //It's not for the Dock
        NSMenuItem * thirdSeparator = [NSMenuItem separatorItem];
        [menu addItem:thirdSeparator];
        
        NSMenuItem * item = [self addItemWithTitle:NSLocalizedStringFromTable(@"Quit", @"StatusMenu", @"") action:@selector(terminate:) tag:PBQuitTag enabled:YES toMenu:menu];
        [item setTarget:[NSApplication sharedApplication]];
        
        //Attach to statusbar
        NSStatusItem * menuExtra =  [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        
        [menuExtra setMenu:menu];
        [menuDelegate setMenuExtra:menuExtra];
        [menuDelegate setIsRunning:NO];
    }
    
    return menu;
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
    NSMenu * menu = [self dockMenu];
    [menuDelegate menuWillOpen:menu];
    
    return menu;
}

- (NSMenu *) statusMenu {
    return [self makeMenu:NO];
}

- (NSMenu *) dockMenu {
    return [self makeMenu:YES];
}

- (void) loadUI {
    notificationCenter = [[NotificationCenter alloc] init];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:notificationCenter];
    
    if (self.pendingNotifications.count > 0) {
        @synchronized(self.pendingNotifications) {
            for (NSUserNotification * notification in self.pendingNotifications) {
                [notificationCenter userNotificationCenter:[NSUserNotificationCenter defaultUserNotificationCenter] didActivateNotification:notification];
            }
        }
    }
    
    
    if (self.hasMenu) {
        [self statusMenu];
    }
    
    if (mirroring) {
        [self enableMirrorNotification];
    } else {
        [self disableMirrorNotification];
    }
}

- (void) initControllers {
    
    [[PBConnexion sharedPBConnexion] setApiKey:self._apiKey];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetUser:) name:PBGotUserNotification object:nil];
    [[PBUserController sharedUserController] requestUser];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSubscriptions:) name:PBGotSubscriptionsNotification object:nil];
    [[PBSubscriptionsController sharedSubscriptionsController] requestSubscriptions];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDevices:) name:PBGotDevicesNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetThisDeviceIden:) name:PBGotThisDeviceIdenNotification object:nil];
    [[PBDevicesController sharedDevicesController] requestDevices];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetContacts:) name:PBGotContactsNotification object:nil];
    [[PBContactsController sharedContactsController] requestContacts];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetPushes:) name:PBGotPushHistoryNotification object:nil];
    if (lastTimestamp == 0)
        [[PBPushHistoryController sharedPushHistoryController] requestPushesSince:0];
    else
        [[PBPushHistoryController sharedPushHistoryController] requestPushesSince:lastTimestamp];
}

#pragma mark Socket Funcs

- (void) startSocket {
    
    _socket = [[PBWebSocket alloc] initWithApiKey:_apiKey];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(devicesNeedUpdate:) name:PBSocketDeviceUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPush:) name:PBSocketPushHistoryUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPush:) name:PBSocketMirrorPushNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webSocketOpened:) name:PBSocketOpenedNotification object:nil];

}

- (void) devicesNeedUpdate:(NSNotification *)notificaction {
    PBLOG(@"Updating device list at server request");
    [[PBDevicesController sharedDevicesController] requestDevices];
}

- (void)receivedPush:(NSNotification *)notificaction {
    PBPush * push = (PBPush *)[notificaction object];
    if (push == nil) {
        [[PBPushHistoryController sharedPushHistoryController] requestPushesSince:lastTimestamp];
        return;
    } else {
        if (mirroredPushes == nil) {
            mirroredPushes = [[NSMutableArray alloc] init];
        }
        [mirroredPushes addObject:push];
        
        BOOL hasAction = NO;
        NSMutableArray * packages = [[storage valueForKey:@"packages"] mutableCopy];
        if (packages == nil) packages = [[NSMutableArray alloc] init];
        
        if (push.package_name != nil) {
            @synchronized(packages) {
                for (NSDictionary * packDict in packages) {
                    if ([push.package_name isEqualToString:[packDict valueForKey:kPBPackageNameKey]]) {
                        hasAction = YES;
                    }
                }
            }
            
            if (hasAction == NO) {
                if (push.application_name == nil) return;
                
                NSMutableDictionary * package = [[NSMutableDictionary alloc] initWithCapacity:3];
                [package setValue:push.package_name forKey:kPBPackageNameKey];
                [package setValue:push.application_name forKey:kPBApplicationNameKey];
                [package setObject:[NSNumber numberWithBool:YES] forKey:@"enabled"];
                
                NSMutableDictionary * action = [[NSMutableDictionary alloc] initWithCapacity:2];
                [action setObject:[NSNumber numberWithInt:0] forKey:kPBTypeKey];
                
                [package setObject:action forKey:@"action"];
                [packages addObject:package];
                [storage setObject:packages forKey:@"packages"];
                [storage synchronize];
            }
        }
        
    notify:
        [self notify:push];
    }
}

- (void) webSocketOpened:(NSNotification *)notification {
    
    if (snoozing == NO)
            [menuDelegate setIsRunning:YES];
    
}

- (void) webSocketClosed:(NSNotification *)notification {
    
    [menuDelegate setIsRunning:YES];
    
}

#pragma mark Notification functions

- (NSUserNotification *) notificationWithGenericPush:(PBPush *) push {
    NSUserNotification * notification = [[NSUserNotification alloc] init];
    
    notification.title = push.title;
    notification.identifier = push.iden;
    notification.soundName = NSUserNotificationDefaultSoundName;
    notification.informativeText = push.body;
    
    notification.hasActionButton = NO;
    
    return notification;
}

- (NSUserNotification *) notificationWithNotePush:(PBPush *)push {
    NSUserNotification * notification = [self notificationWithGenericPush:push];
    
    notification.subtitle = [NSString stringWithFormat:@"From %@", [self deviceNicknameFromIden:push.source_device_iden]];
    
    notification.hasActionButton = YES;
    notification.actionButtonTitle = @"Copy";
    
    return notification;
}

- (NSUserNotification *) notificationWithLinkPush:(PBPush *)push {
    NSUserNotification * notification = [self notificationWithGenericPush:push];
    
    notification.subtitle = push.url;
    
    return notification;
}

- (NSUserNotification *) notificationWithFilePush:(PBPush *)push {
    NSUserNotification * notification = [self notificationWithGenericPush:push];
    
    notification.subtitle = push.file_url;
    
    return notification;
}

- (NSUserNotification *) notificationWithSubscriptionLinkPush:(PBPush *)push {
    NSUserNotification * notification = [self notificationWithGenericPush:push];
    
    notification.subtitle = push.name;
    
    ImageFromIden * transformer = [[ImageFromIden alloc] init];
    notification.contentImage = [transformer transformedValue:push.channel_iden];
    
    return notification;
}

- (NSUserNotification *) notificationWithMirrorPush:(PBPush *)push {
    NSUserNotification * notification = [self notificationWithGenericPush:push];
    
    notification.subtitle = [NSString stringWithFormat:@"From %@", push.application_name];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:push.package_name forKey:kPBPackageNameKey];
    notification.userInfo = userInfo;
    
    notification.contentImage = [PBPush imageWithPush:push];
    
    if (push.conversation_iden) {
        notification.hasActionButton = YES;
        notification.hasReplyButton = YES;
        notification.identifier = push.conversation_iden;
    }
    
    return notification;
}

- (NSUserNotification *) notificationWithAddressPush:(PBPush *)push {
    NSUserNotification * notification = [self notificationWithGenericPush:push];
    
    notification.title = push.address;
    notification.subtitle = push.name;
    
    return notification;
}

- (void)notify:(PBPush *)push {
    NSUserNotification *notification;
    //TODO: Use shouldPresentNotification from delegate to filter out notifications
    //Ignore dismissal
    if ([push.type isEqualToString:kPBDismissalType]) {
        return;
    }
    
    //This device isn't the target
    if (push.target_device_iden != nil) {
        if (![push.target_device_iden isEqualToString: thisDeviceIden]) {
            return;
        }
    }
    
    //note notification
    if ([push.type isEqualToString:kPBNoteType]) {
        notification = [self notificationWithNotePush:push];
    }
    else if ([push.type isEqualToString:kPBLinkType]) {//Link notifications
        
        if (push.channel_iden != nil) {
            notification = [self notificationWithSubscriptionLinkPush:push];
        } else {
            notification = [self notificationWithLinkPush:push];
        }
        
    } else if ([push.type isEqualToString:kPBMirrorType]) {
        if (!mirroring) return; //Use UserNotificationCenter to filter this out
        NSArray * packages = [self.storage objectForKey:@"packages"];
        for (NSDictionary * package in packages) {
            if ([[package valueForKey:kPBApplicationNameKey] isEqualToString:push.application_name]) {
                
                if ([[package valueForKey:@"enabled"] boolValue] == NO )
                    return;
            }
        }
        notification = [self notificationWithMirrorPush:push];
        
    } else if ([push.type isEqualToString:kPBAddressKey]) {
        notification = [self notificationWithAddressPush:push];
        
    } else if ([push.type isEqualToString:kPBFileType]) {
        notification = [self notificationWithFilePush:push];
    }
    if (notification == nil) {
        PBLOGF(@"An error occured : notification is nil. push was : %@", [PBPush dictionaryWithPush:push]);
        return;
    }
    
    if ([menuDelegate timeOfRestart] != nil) {
        notification.deliveryDate = [menuDelegate timeOfRestart];
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
    } else {
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    
}

#pragma mark Devices Funcs

- (NSString *)deviceNicknameFromIden:(NSString *)iden {
    
    @synchronized(devices) {
        for (NSDictionary *device in devices) {
            if ([[device valueForKey:kPBIdenKey] isEqualTo:iden]) {
                return [device valueForKey:kPBNicknameKey];
            }
        }
    }
    return nil;
}

- (BOOL) checkThisDevice {
    BOOL deviceIsActive = NO;
    if (storage == nil) storage = [[NSUserDefaults alloc] initWithSuiteName:PBAppGroup];
    
    thisDeviceIden = [storage valueForKey:@"this_device_iden"];
    
    if (thisDeviceIden != nil) {
        
        @synchronized(devices) {
            for (NSDictionary * device in devices) {
                if ([thisDeviceIden isEqualToString:[device valueForKey:kPBIdenKey]]) {
                    deviceIsActive = YES;
                }
            }
        }
        
    } else {
        if (self.thisComputerName != nil) {
            
            @synchronized(devices) {
                for (NSDictionary *device in devices) {
                    if ([self.thisComputerName isEqualToString:[device valueForKey:kPBNicknameKey]]) {
                        
                        deviceIsActive = YES;
                        thisDeviceIden = [device valueForKey:kPBIdenKey];
                        
                        if (storage == nil) storage = [[NSUserDefaults alloc] initWithSuiteName:PBAppGroup];
                        
                        [storage setObject:self.thisDeviceIden forKey:@"this_device_iden"];
                        [storage synchronize];
                        
                        
                    }
                }
            }
        }
    }
    
    if (deviceIsActive == NO) //This shouldn't happen
        PBLOG(@"This device isn't active");
    
    return deviceIsActive;
}

#pragma mark PBControllers Notifications

- (void) didGetDevices:(NSNotification *)notification {
    
    [self setDevices:[((NSArray *)[notification object]) mutableCopy]];
    
    if ([self checkThisDevice] == YES) {
        [storage setObject:[notification object] forKey:kPBDevicesKey];
        [storage synchronize];

    } else {
        self.thisComputerName = [Utils computerName];
        self.thisComputerModel = [Utils computerModel];
        [[PBDevicesController sharedDevicesController] createDeviceNamed:self.thisComputerName withModel:self.thisComputerModel];
    }
}

- (void) didGetThisDeviceIden:(NSNotification *)notification {
    self.thisDeviceIden = [notification object];
    
    if (storage == nil) storage = [[NSUserDefaults alloc] initWithSuiteName:PBAppGroup];
    [storage setObject:self.thisDeviceIden forKey:@"this_device_iden"];
    [storage synchronize];
}

- (void) didGetSubscriptions:(NSNotification *)notification {
    if (((NSArray *)[notification object]).count == 0) {
        PBLOG(@"No subscriptions on server");
        return;
    }
    if (storage == nil) storage = [[NSUserDefaults alloc] initWithSuiteName:PBAppGroup];
    NSArray * currentSubscriptions = [storage valueForKey:@"subscriptions"];
    
    for (NSDictionary *subscription in ((NSArray *)[notification object])) {
        BOOL active = [[subscription valueForKey:@"active"] boolValue];
        if (!active) {
            continue;
        }
        BOOL needsRefresh = NO;
        NSDictionary * channel = [subscription valueForKey:@"channel"];
        NSString * channelIden = [channel valueForKey:@"iden"];
        
        if ((currentSubscriptions == nil) || (currentSubscriptions.count == 0)) {
            PBLOG(@"No Subscriptions in storage");
            needsRefresh = YES;
        } else {
            for (NSDictionary * cSubscription in currentSubscriptions) {
                if ([[subscription valueForKey:kPBIdenKey] isEqualTo:[cSubscription valueForKey:kPBIdenKey]]) {
                    if (![[subscription valueForKey:@"modified"] isEqualTo:[cSubscription valueForKey:@"modified"]]) {
                        needsRefresh = YES;
                        PBLOGF(@"Subscription %@ needs updatin'", [subscription valueForKeyPath:@"channel.name"]);
                    }
                }
            }
        }
        
        if (needsRefresh == NO) {
            ImageFromIden * transformer = [[ImageFromIden alloc] init];
            NSImage * image = [transformer transformedValue:channelIden];
            
            if (image == nil) {
                PBLOGF(@"%@ not found, needs updatin'", [subscription valueForKeyPath:@"channel.image_url"]);
                needsRefresh = YES;
            }
        }
        
        if (needsRefresh == YES) {
            NSString * imageUrl = [subscription valueForKeyPath:@"channel.image_url"];
            NSString * extension = [imageUrl pathExtension];
            PBLOGF(@"Channel %@, Retreiving image with URL : %@", [subscription valueForKeyPath:@"channel.name"], imageUrl);
            
            PBImageLoader * imageLoader __strong = [[PBImageLoader alloc] init];
            [imageLoader loadImageFromURL:[NSURL URLWithString:imageUrl] ofType:extension withName:channelIden];
        }
    }
    
    if (storage == nil) storage = [[NSUserDefaults alloc] initWithSuiteName:PBAppGroup];
    [self setSubscriptions:(NSArray *)[notification object]];
    [storage setObject:subscriptions forKey:@"subscriptions"];
    [storage synchronize];
    
}


- (void) didGetContacts:(NSNotification *)notification {
    [self setContacts:[notification object]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->storage setObject:self->contacts forKey:kPBContactsKey];
    });
    [storage synchronize];
}

- (void) updateModifiedTimestamp:(double)newTimestamp {
    if (newTimestamp > lastTimestamp) {
        lastTimestamp = newTimestamp;
    }
    NSNumber *modified_since = [NSNumber numberWithDouble:lastTimestamp];
    [storage setObject:modified_since forKey:@"modified_since"];
    [storage synchronize];
}

- (void) didGetPushes:(NSNotification *)notification {
    if (_pushes == nil)
        _pushes = [NSMutableArray arrayWithArray:((NSArray *)[notification object])];
    
    @synchronized(_pushes) {
        for (NSDictionary *pushDico in (NSArray *)[notification object]) {
            PBPush* push = [PBPush pushWithDictionary:pushDico];
            
            BOOL exists = NO;
            BOOL active = [push.active boolValue];
            
            for (NSDictionary * hPush in _pushes) {
                if ([push.iden isEqualTo:[hPush valueForKey:kPBIdenKey]])
                    exists = YES;
            }
            
            if ((!exists) && (active)) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PBTableAddItemNotification object:pushDico];
                //TODO:Find a way to store pushes on disk without having to load the whole database everytime
                [_pushes insertObject:pushDico atIndex:0];
                [storage setObject:_pushes forKey:kPBPushesKey];
                [storage synchronize];
                
                double stamp = push.modified;
                [self updateModifiedTimestamp:stamp];
                
                //TODO: Use User Notification Center Delegate to filter this out
                if (![push.dismissed boolValue] && [push.active boolValue]) {
                    PBLOGF(@"New Push %@ %@", [pushDico valueForKey:kPBTypeKey], [pushDico valueForKey:kPBIdenKey]);
                    [self notify:push];
                } else {
                    PBLOGF(@"Push with title \"%@\" not notified", push.title);
                }
            }
        }
    }
}
- (void) didGetUser:(NSNotification *)notification {
    user = [notification object];
    thisUserIden = [user valueForKey:kPBIdenKey];
    [storage setObject:user forKey:@"user"];
    [storage synchronize];
}

- (void) didReceiveImage:(NSNotification *)notification {
    PBImageLoader * sender = ((PBImageLoader *)[notification object]);
    NSFileManager * fileManager = [[NSFileManager alloc] init];
    NSURL * groupURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:PBAppGroup];
    NSURL * cachesURL = [groupURL URLByAppendingPathComponent:CachesFolder];
    NSURL * fileURL = [cachesURL URLByAppendingPathComponent:sender._name];
    
    
    NSData * imageData = [sender._image representationUsingType:[Utils typeForExtension:sender._extension] properties:nil];
    [imageData writeToFile:fileURL.path atomically:NO];
    
    //TODO:Make the image dataBank one file
    [_imageDataBank setObject:sender._image forKey:sender._name];
    
    [NSKeyedArchiver archiveRootObject:_imageDataBank toFile:[[cachesURL URLByAppendingPathComponent:@"images.db"] path]];
}

#pragma mark -
#pragma mark Removal from server funcs

- (void) removePushFromServer:(NSArray *)pushes {
    [pushes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSDictionary * push, NSUInteger idx, BOOL *stop) {
        PBLOGF(@"Sending remove request for push %@", [push valueForKey:kPBIdenKey]);
        [[PBPushController sharedPushController] delete:push];
    }];
}

- (void) removeSourceFromServer:(Node *)source {
    NSDictionary * sourceDictionary = [NSDictionary dictionaryWithObjectsAndKeys:source.iden, kPBIdenKey, nil];
    
    if (source.type == kPBDeviceNode) {
        PBLOGF(@"Sending remove request for device %@", source.iden);
        [[PBDevicesController sharedDevicesController] delete:sourceDictionary];
    }
    if (source.type == kPBContactsNode) {
        PBLOGF(@"Sending remove request for contact %@", source.iden);
        [[PBContactsController sharedContactsController] delete:sourceDictionary];
    }
    if (source.type == kPBSubscriptionNode) {
        PBLOGF(@"Sending remove request for subscription %@", source.iden);
        [[PBSubscriptionsController sharedSubscriptionsController] delete:sourceDictionary];
    }
}

-(void) shouldRemovePushFromServer:(NSNotification *)notification {
    [self removePushFromServer:[[notification userInfo] valueForKey:@"array"]];
}

-(void) shouldRemoveSourceFromServer:(NSNotification *)notification {
    [self removeSourceFromServer:[[notification userInfo] valueForKey:@"object"]];
}

#pragma mark -
#pragma mark Interaction Functions

#define SECONDS(x) x*1
#define ASECOND SECONDS(1)
#define MINUTES(x) SECONDS(60*x)
#define AMINUTE MINUTES(1)
#define HOURS(x) MINUTES(60*x)
#define ANHOUR HOURS(1)

- (void) unsnooze {
    snoozing = NO;
    self.deliveryDate = nil;
    
    [menuDelegate setIsRunning:YES];
    [menuDelegate clearLengthOfPause];
    
    
    NSArray * scheduledNotifications = [NSUserNotificationCenter defaultUserNotificationCenter].scheduledNotifications;
    
    for (NSUserNotification * notification in scheduledNotifications) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeScheduledNotification:notification];
        notification.deliveryDate = nil;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    
}

- (IBAction) snooze:(id)sender {
    if (snoozing == NO) {
        
        [self performSelector:@selector(unsnooze) withObject:nil afterDelay:(ANHOUR)];
        
        snoozing = YES;
        
            [menuDelegate setIsRunning:NO];
            [menuDelegate setLengthOfPause:(NSTimeInterval)ANHOUR];
            self.deliveryDate = [menuDelegate timeOfRestart];
        
        
    } else {
        [self unsnooze];
        
    }
}

- (void) enableMirrorNotification {
    if (self.hasMenu) {
        [[_statusMenu itemWithTag:PBMirrorTag] setState:NSOnState];
    }
    
    mirroring = YES;
    [storage setBool:YES forKey:@"mirror_enabled"];
    [storage synchronize];
}

- (void) disableMirrorNotification {
    if (self.hasMenu) {
        [[_statusMenu itemWithTag:PBMirrorTag] setState:NSOffState];
    }
    mirroring = NO;
    [storage setBool:NO forKey:@"mirror_enabled"];
    [storage synchronize];
}

- (IBAction) toggleMirrorNotifications:(id)sender {
    mirroring = [storage boolForKey:@"mirror_enabled"];
    if (!mirroring) {
        [self enableMirrorNotification];
    } else {
        [self disableMirrorNotification];
    }
}

- (void) cancelSignOut {
    if (_signOutWindow != nil) {
        _signOutWindow = nil;
    }
}

- (IBAction) signOut:(id)sender {
    if (_signOutWindow.theWindow == nil) {
        _signOutWindow = [[PBSignoutWindowController alloc] initWithWindowNibName:@"SignoutWindow" owner:[NSApplication sharedApplication]];
        [_signOutWindow setDelegate:self];
        _signOutWindow.theWindow = [_signOutWindow window];
    }
    [_signOutWindow.theWindow orderFrontRegardless];
    [_signOutWindow.theWindow makeKeyWindow];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void) userSignsOut:(BOOL)removeDevice {
    
    if (storage == nil) storage = [[NSUserDefaults alloc] initWithSuiteName:PBAppGroup];
    [storage removeObjectForKey:@"apiKey"];
    [storage removeObjectForKey:@"devices"];
    [storage removeObjectForKey:@"subscriptions"];
    [storage removeObjectForKey:@"contacts"];
    [storage removeObjectForKey:@"user"];
    [storage removeObjectForKey:@"pushes"];
    [storage removeObjectForKey:@"modified_since"];
    [storage removeObjectForKey:@"mirror_enabled"];
    if (removeDevice) {
        
        [[PBDevicesController sharedDevicesController] delete:[NSDictionary dictionaryWithObjectsAndKeys:[storage valueForKey:@"this_device_iden"], kPBIdenKey, nil]];
        [storage removeObjectForKey:@"this_device_iden"];
    }
    [storage synchronize];
    [[NSApplication sharedApplication] terminate:self];
}


- (IBAction) openPreferences:(id)sender {
    if (_settingsWindow.mainWindow == nil) {
        _settingsWindow = [[PBSettingsWindowController alloc] initWithWindowNibName:@"Settings" owner:[NSApplication sharedApplication]];
        [_settingsWindow setDelegate:self];
        [_settingsWindow setUserDefaults:storage];
        _settingsWindow.mainWindow = [_settingsWindow window];
    }
    [_settingsWindow.mainWindow orderFrontRegardless];
    [_settingsWindow.mainWindow makeKeyWindow];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void) cancelSettings {
    if (_settingsWindow != nil)
        _settingsWindow = nil;
}

//TODO: add a setting to show this at start up
- (IBAction) openMainWindow:(id)sender {
    if (_mainWindowController == nil) {
        
        _mainWindowController = [[PBMainWindowController alloc] initWithWindowNibName:@"MainMenu" owner:[NSApplication sharedApplication]];
        
        [_mainWindowController setDelegate:self];
        [_mainWindowController setMainWindow:[_mainWindowController window]];
    }
    
    [_mainWindowController.mainWindow orderFrontRegardless];
    [_mainWindowController.mainWindow  makeKeyWindow];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.bidou.Whatever" in the user's Application Support directory.
    NSURL * groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:PBAppGroup];
    NSURL * appSupportURL = [groupURL URLByAppendingPathComponent:AppSupportFolder];
    return [appSupportURL URLByAppendingPathComponent:@"com.bidou.pushbullet"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PushbulletModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
            shouldFail = YES;
        }
    } else if ([error code] == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:[applicationDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"OSXCoreDataObjC.storedata"];
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

@end
