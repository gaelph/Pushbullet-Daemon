//
//  PBOutlineViewCell.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBOutlineViewCell.h"
#import "PBOutlineView.h"


@implementation PBOutlineViewCellHeader

- (void) mouseEntered:(NSEvent *)theEvent {
    [[self hideButton] setHidden:NO];
}

- (void) mouseExited:(NSEvent *)theEvent {
    [[self hideButton] setHidden:YES];
}

- (void) updateTrackingAreas {
    [[self trackingAreas] enumerateObjectsUsingBlock:^(NSTrackingArea * area, NSUInteger index, BOOL *stop) {
        [self removeTrackingArea:area];
        [self addTrackingRect:[self visibleRect] owner:self userData:nil assumeInside:NO];
    }];
}
@end


@implementation PBOutlineViewCellItem

- (void) showRemoveButton {
    if (((Node *)[self representedObject]).type == kPBAllNode) {
        [self hideRemoveButton];
        return;
    }
    
    [[NSAnimationContext currentContext] setDuration:0.4];
    [[[self settingsButton] animator] setHidden:NO];
}

- (void) hideRemoveButton {
    [[NSAnimationContext currentContext] setDuration:0.4];
    [[[self settingsButton] animator] setHidden:YES];
}

- (void) EditSessionChange:(BOOL)newValue {
    [self setShouldShowRemoveButton:newValue];
    
    if (newValue == YES) {
        [self showRemoveButton];
    } else {
        [self hideRemoveButton];
    }
}

- (IBAction)removeDevice:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBRemoveDevice" object:[self representedObject]];
}


@end

@implementation PBOutlineRowView


- (void)drawBackgroundInRect:(NSRect)dirtyRect {
    if (self.selected) {
        [self setEmphasized:NO];
    }
    [super drawBackgroundInRect:dirtyRect];
}

@end
