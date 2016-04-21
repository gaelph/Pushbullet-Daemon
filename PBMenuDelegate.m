//
//  PBMenuDelegate.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 19/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMenuDelegate.h"

@implementation PBMenuDelegate

- (BOOL) isRunning {
    return self.running;
}

- (void) setIsRunning:(BOOL)value {
    self.running = value;
    
    if (value == true) {
        if (self.menuExtra != nil) {
            self.menuExtra.button.image = [NSImage imageNamed:@"menuIcon"];
            [self.menuExtra.button.image setTemplate:YES];
        }
    } else {
        self.menuExtra.button.image = [NSImage imageNamed:@"menuIconDisabled"];
        [self.menuExtra.button.image setTemplate:YES];
    }
    
}

- (NSDate *) timeOfRestart {
    return self._timeOfRestart;
}

- (void) setTimeOfRestart:(NSDate *)timeOfRestart {
    self._timeOfRestart = timeOfRestart;
}

- (void) clearTimeOfRestart {
    self.timeOfRestart = nil;
}

- (NSTimeInterval) lengthOfPause {
    return self._lengthOfPause;
}

- (void) setLengthOfPause:(NSTimeInterval)lengthOfPause {
    self._lengthOfPause = lengthOfPause;
    self.timeOfRestart = [[NSDate date] dateByAddingTimeInterval:self._lengthOfPause];
}

- (void) clearLengthOfPause {
    self._lengthOfPause = 0;
    self.timeOfRestart = nil;
}

static NSInteger _an_hour = 60;
static NSInteger _a_minute = 60;

- (NSString *) stringForInterval:(NSTimeInterval)interval {
    NSInteger minutes = floor(interval/60);
    NSInteger seconds = round(interval - (minutes * 60));
    NSString * minutesString;
    if (minutes > 0) {
        
        if ((_an_hour - minutes) < 5) { // 60 to 55
            minutesString = NSLocalizedStringFromTable(@"about an hour", @"StatusMenu", @"");
        } else if ((_an_hour - minutes) < 10) { // 55 to 50
            minutesString = NSLocalizedStringFromTable(@"less than an hour", @"StatusMenu", @"");
        } else if ((_an_hour - minutes) < 25) { // 50 to 35
            minutesString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"about %li minutes", @"StatusMenu", @""), minutes];
        } else if ((_an_hour - minutes) < 35) { // 35 to 25
            minutesString = NSLocalizedStringFromTable(@"about half an hour", @"StatusMenu", @"");
        } else if ((_an_hour - minutes) < 59) { // 25 to 1
            minutesString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"about %li minutes", @"StatusMenu", @""), minutes];
        } else { // 15 to 5
            minutesString = NSLocalizedStringFromTable(@"less than a minute", @"StatusMenu", @"");
        }
        
    } else {
        if ((_a_minute - seconds) < 30) {
            minutesString = NSLocalizedStringFromTable(@"less than a minute", @"StatusMenu", @"");
        } else if ((_a_minute - seconds) < 50) {
            minutesString = NSLocalizedStringFromTable(@"less than 30 seconds", @"StatusMenu", @"");
        } else {
            minutesString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%li seconds", @"StatusMenu", @""), minutes];
        }
    }
    
    return minutesString;
}

- (void) menuWillOpen:(NSMenu *)menu {
    if ([self isRunning] == YES) {
        [[menu itemWithTag:PBSocketStateTag] setTitle:NSLocalizedStringFromTable(@"SocketStatusRunning", @"StatusMenu", @"")];
        NSMenuItem * menuItem = [menu itemWithTag:PBSnoozeTag];
        [menuItem setTitle:NSLocalizedStringFromTable(@"Snooze", @"StatusMenu", @"")];
    } else if ([self lengthOfPause] > 0) {
        if ([self timeOfRestart] != nil) {
            NSDate * now = [NSDate date];
            NSTimeInterval remaining = [self._timeOfRestart timeIntervalSinceDate:now];
            NSString * formattedETA = [self stringForInterval:remaining];
            [[menu itemWithTag:PBSocketStateTag] setTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"SocketStatusPaused", @"StatusMenu", @""), formattedETA]];
            NSMenuItem * menuItem = [menu itemWithTag:PBSnoozeTag];
            [menuItem setTitle:NSLocalizedStringFromTable(@"Resume", @"StatusMenu", @"")];
        }
    } else {
        [[menu itemWithTag:PBSocketStateTag] setTitle:NSLocalizedStringFromTable(@"SocketStatusClosed", @"StatusMenu", @"")];
    }
}

- (void) menuDidClose:(NSMenu *)menu {
    return;
}


@end