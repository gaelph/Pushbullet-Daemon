//
//  PBMenuDelegate.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 19/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_PBMenuDelegate_h
#define Pushbullet_PBMenuDelegate_h

#import <Cocoa/Cocoa.h>

enum NSUInteger {
    PBSocketStateTag = 0,
    PBSignoutTag = 3,
    PBSnoozeTag = 5,
    PBMirrorTag = 6,
    PBQuitTag = 8,
    PBPreferencesTag = 9,
    PBMainWindowTag = 10
};

@interface PBMenuDelegate : NSObject<NSMenuDelegate>

@property (assign) BOOL running;

@property NSDate * _timeOfRestart;
@property (assign) NSTimeInterval _lengthOfPause;
@property (retain) NSStatusItem * menuExtra;
@property NSMutableArray * menus;

- (BOOL) isRunning;
- (void) setIsRunning:(BOOL)value;

- (NSDate *) timeOfRestart;
- (void) setTimeOfRestart:(NSDate *)timeOfRestart;
- (void) clearTimeOfRestart;

- (NSTimeInterval) lengthOfPause;
- (void) setLengthOfPause:(NSTimeInterval)lengthOfPause;
- (void) clearLengthOfPause;


- (void) menuWillOpen:(NSMenu *)menu;
- (void) menuDidClose:(NSMenu *)menu;

@end
#endif
