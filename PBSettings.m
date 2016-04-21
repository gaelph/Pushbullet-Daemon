//
//  PBSettings.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 15/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBSettings.h"
#import "PBDefines.h"
#import <ApplicationServices/ApplicationServices.h>
#import "LaunchAtLoginController.h"


@implementation MutableImmutableValueTransformer

+ (Class)transformedValueClass {
    return [NSObject class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id) transformedValue:(id)value {
    if (value == nil) return nil;
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary * temp = [[NSMutableDictionary alloc] initWithCapacity:[value count]];
        for (NSString * key in value) {
            [temp setObject:[self transformedValue:[value objectForKey:key]] forKey:key];
        }
        return temp;
    }
    if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray * temp = [[NSMutableArray alloc] initWithCapacity:[value count]];
        for (id object in value) {
            [temp addObject:[self transformedValue:object]];
        }
        return temp;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [NSMutableString stringWithString:value];
    }
    return value;
}

- (id) reverseTransformedValue:(id)value {
    return value;
}

@end

@implementation PBSettingsWindowController
@synthesize mainWindow;
@synthesize tableView;
@synthesize _delegate;
@synthesize userDefaults;

- (NSMutableArray *) packages {
    return self._packages;
}

- (void) setPackages:(NSArray *)packages {
    self._packages = [NSMutableArray arrayWithArray:packages];
}

- (void) setDelegate:(id)delegate {
    _delegate = delegate;
}

- (id) delegate {
    return _delegate;
}

- (void) removeDelegate {
    _delegate = nil;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((self.userDefaultsController != nil) && (self.packages != nil)) {
        if (self.userDefaults == nil) {
            self.userDefaults = [NSUserDefaults standardUserDefaults];
        }
        
        NSArray * tempPackages = [self.userDefaults objectForKey:@"packages"];
        
        if ([tempPackages isNotEqualTo:[self packages]]) {
            [self.userDefaults setObject:[self packages] forKey:@"packages"];
        }
        
        [self.userDefaults synchronize];
    } else {
        return;
    }
}

- (void) awakeFromNib {
    
    if ([self.userImageView image] == nil) {
        if (self.userDefaults == nil) {
            self.userDefaults = [NSUserDefaults standardUserDefaults];
        }
        
        if (self.userDefaultsController == nil) {
            self.userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        }
        
        NSImage * profilePicture = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"user.image_url"]]];
        NSSize size = NSSizeFromString(@"{64,64}");
        [profilePicture setSize:size];
        [self.userImageView setImage:profilePicture];
        //}
        
        if ([self packages] == nil) {
            if ([[self.userDefaultsController defaults] valueForKey:@"packages"] == nil) {
                NSDictionary * defaultsPlist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]];
                
                
                [self setPackages:[[NSArray alloc] initWithArray:[defaultsPlist valueForKey:@"packages"]]];
                
                [[self.userDefaultsController defaults] setObject:self._packages forKey:@"packages"];
                [[self.userDefaultsController defaults] synchronize];
            } else {
                NSMutableArray * packs = [[NSMutableArray alloc] init];
                NSArray * packages = [[self.userDefaultsController defaults] valueForKey:@"packages"];
                for (NSDictionary * package in packages) {
                    NSMutableDictionary * pack = [NSMutableDictionary dictionaryWithDictionary:package];
                    NSMutableDictionary * action = [NSMutableDictionary dictionaryWithDictionary:[package objectForKey:@"action"]];
                    [pack setObject:action forKey:@"action"];
                    [packs addObject:pack];
                }
                [self setPackages:packs];
            }
            
            for (NSMutableDictionary * package in [self packages]) {
                for (NSString * key in package) {
                    [package addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
                }
            }
            [[self.userDefaultsController defaults] addObserver:self forKeyPath:@"packages" options:NSKeyValueObservingOptionNew context:NULL];
        }
        
        [mainWindow makeKeyWindow];
        [mainWindow orderFrontRegardless];
    }
    
}

- (void) windowDidLoad {
    
    [mainWindow makeKeyWindow];
    [mainWindow orderFrontRegardless];
    return;
    
}

- (IBAction) cancel:(id)sender {
/*    [mainWindow orderOut:sender];
    [mainWindow close];
    if ([_delegate respondsToSelector:@selector(cancelSettings)]) {
        [_delegate cancelSettings];
    }
*/
}

- (IBAction) saveSettings:(id)sender {
    NSUserDefaults * storage = [[NSUserDefaults alloc] initWithSuiteName:@"group.pushbullet"];
    
    if (self.AutostartBox.state == NSOnState)  {
        LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
        [launchController setLaunchAtLogin:YES];
        [storage setBool:YES forKey:@"autostart"];
    }
    else {
        LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
        [launchController setLaunchAtLogin:NO];
        [storage setBool:NO forKey:@"autostart"];
    }
    
    if (self.MenuIconBox.state == NSOnState) {
        [storage setBool:YES forKey:@"showmenu"];
    }
    else {
        [storage setBool:NO forKey:@"showmenu"];
    }
    
    if (self.DockIconBox.state == NSOnState) [storage setBool:YES forKey:@"showdock"];
    else [storage setBool:NO forKey:@"showdock"];
    
    
    [storage setObject:self._packages forKey:@"packages"];
    [storage synchronize];
    //[self cancel:sender];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return self._packages.count;
}

- (IBAction) chooseDoNothing:(id)sender {
    
    NSMutableDictionary * action = [[NSMutableDictionary alloc] initWithCapacity:1];
    [action setObject:[NSNumber numberWithInt:0] forKey:@"type"];
    [action removeObjectForKey:@"info"];
    [action removeObjectForKey:@"info2"];
    
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        NSTableCellView * theView = [rowView viewAtColumn:2];
        if ([theView.menu isEqualTo:((NSMenuItem *)sender).menu]) {
            self.currentRow = row;
        }
    }];
    
    [self._packages[self.currentRow] setObject:action forKey:@"action"];
    
    [tableView reloadData];
}

- (IBAction) cancelChooseURL:(id)sender {
    [self.urlTextField setStringValue:@""];
    [self.urlWindow orderOut:sender];
    [self.urlWindow close];
}

- (IBAction) setURL:(id)sender {
    NSInteger row = self.currentRow;
    NSString * url = self.urlTextField.stringValue;
    
    NSMutableDictionary * action = [self._packages[row] valueForKey:@"action"];
    [action setObject:[NSNumber numberWithInt:1] forKey:@"type"];
    [action setObject:url forKey:@"info"];
    [action removeObjectForKey:@"info2"];
    
    [self._packages[row] setObject:action forKey:@"action"];
    
    [tableView reloadData];
    [self cancelChooseURL:sender];
}

- (IBAction) chooseURL:(id)sender {
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        NSTableCellView * theView = [rowView viewAtColumn:2];
        if ([theView.menu isEqualTo:((NSMenuItem *)sender).menu]) {
            self.currentRow = row;
        }
    }];
    
    NSMutableDictionary * action = [self._packages[self.currentRow] valueForKey:@"action"];
    if ([[action valueForKey:@"type"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
        [self.urlTextField setStringValue:[action valueForKey:@"info"]];
    }
    [self.urlWindow orderFrontRegardless];
    [self.urlWindow makeKeyWindow];
}

- (IBAction) chooseApp:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowedFileTypes = @[@"app"];
    panel.allowsMultipleSelection = NO;
    
    NSURL * __block selection;
    
    [panel beginWithCompletionHandler:^(NSModalResponse returnCode) {
        if (panel.URLs.count == 0) {
            return;
        }
        selection = panel.URLs[0];
        
        NSString * localizedAppName = [[NSFileManager defaultManager] displayNameAtPath:selection.path];
        
        [self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
            NSTableCellView * theView = [rowView viewAtColumn:2];
            if ([theView.menu isEqualTo:((NSMenuItem *)sender).menu]) {
                self.currentRow = row;
            }
        }];
        
        NSMutableDictionary * action = [self._packages[self.currentRow] objectForKey:@"action"];
        [action setValue:[NSNumber numberWithInt:2] forKey:@"type"];
        [action setObject:selection.path forKey:@"info2"];
        [action setObject:localizedAppName forKey:@"info"];
        
        [self._packages[self.currentRow] setObject:action forKey:@"action"];
        
    }];
    
    
    
    return;
}

- (IBAction)selectTab:(id)sender {
    NSString * toolBarItemIdentifier = [((NSToolbarItem *)sender) itemIdentifier];
    [self.tabView selectTabViewItemWithIdentifier:toolBarItemIdentifier];
    
    if ([toolBarItemIdentifier isEqualToString:@"general"]) {
        NSRect frame = [self.mainWindow frame];
        frame.origin.y = frame.origin.y + frame.size.height - 220;
        frame.size.height = 220;
        [self.mainWindow setFrame:frame display:YES animate:YES];
    }
    if ([toolBarItemIdentifier isEqualToString:@"notifications"]) {
        NSRect frame = [self.mainWindow frame];
        frame.origin.y = frame.origin.y + frame.size.height - 400;
        frame.size.height = 400;
        [self.mainWindow setFrame:frame display:YES animate:YES];
    }
    if ([toolBarItemIdentifier isEqualToString:@"account"]) {
        NSRect frame = [self.mainWindow frame];
        frame.origin.y = frame.origin.y + frame.size.height - 260;
        frame.size.height = 260;
        [self.mainWindow setFrame:frame display:YES animate:YES];
    }
}

- (IBAction) updateCheckBoxes:(id)sender {
    if (self.DockIconBox.state == NSOffState) {
        [self.MenuIconBox setState:NSOnState];
        [self.MenuIconBox setEnabled:NO];
    } else {
        [self.MenuIconBox setEnabled:YES];
    }
    if (self.MenuIconBox.state == NSOffState) {
        [self.DockIconBox setState:NSOnState];
        [self.DockIconBox setEnabled:NO];
    } else {
        [self.DockIconBox setEnabled:YES];
    }
}

@end