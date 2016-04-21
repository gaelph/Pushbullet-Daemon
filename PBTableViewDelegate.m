//
//  PBTableViewDelegate.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 08/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBTableViewDelegate.h"
#import "PBTableViewCell.h"
#import "PBDelegate.h"
#import "ImageFromPush.h"
#import "DateFromTimestamp.h"
#import "DateTools.h"
#import "Utils.h"

@implementation PBTableViewDelegate

//Is this supposed to be here ?
- (IBAction)showMenu:(id)sender {
    [sender mouseDown:nil];
}

- (void)tableView:(NSTableView*)tableView deletePushForView:(NSView *)view {
    NSInteger row = [tableView rowForView:view];
    NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndex:row];
    NSNumber * rowNumber = [NSNumber numberWithInteger:row];
    [tableView beginUpdates];
    [tableView removeRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationEffectFade];
    [tableView endUpdates];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBTableRemoveItemNotification object:rowNumber];
}

#import "PBTableViewDataSource.h"

- (void) tableView:(NSTableView *)theTableView configureView:(PBTableViewCell *)view atRow:(NSInteger)row {
    NSDictionary * push = [((NSArray *)[theTableView dataSource]) objectAtIndex:row];
    
    if (push != nil)
        [view setObjectValue:push];
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([self tableView] == nil) {
        [self setTableView:tableView];
        [[self tableView] setDelegate:self];
    }
    PBTableViewCell * view;
    if ([tableView.identifier isEqualToString:@"OneItemTableView"]) {
        view = [tableView makeViewWithIdentifier:@"PBOneItemCell" owner:nil];
    } else {
        view = [tableView makeViewWithIdentifier:@"PBTableViewCell" owner:nil];
    }
    
    [self tableView:tableView configureView:view atRow:row];
    
    NSDictionary * push = [((NSArray *)[tableView dataSource]) objectAtIndex:row];
    
    NSString * Date = @"";
    if ([push valueForKey:kPBModifiedKey]) {
        NSTimeInterval interval = [[push valueForKey:kPBModifiedKey] floatValue];
        
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:interval];
        Date = [Utils getDateStringFromDate:date withDateFormatter:[self dateFormatter]];
        if (Date == nil) Date = @"";
    }
    [[view DateView] setStringValue:Date];
    [view fetchImage];
    
    return view;
}


- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    CGSize size;
    if ([self tableView] == nil) {
        [self setTableView:tableView];
        [[self tableView] setDelegate:self];
    }
    
    if ([self dummy] == nil) {
        PBTableViewCell * view;
        if ([tableView.identifier isEqualToString:@"OneItemTableView"]) {
            view = [tableView makeViewWithIdentifier:@"PBOneItemCell" owner:nil];
        } else {
            view = [tableView makeViewWithIdentifier:@"PBTableViewCell" owner:nil];
        }
        [self setDummy:view];
    }
    
    [self tableView:tableView configureView:[self dummy] atRow:row];
    
    [[self dummy] layout];
    
    size = [[self dummy] fittingSize];
    return size.height;
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification {
    
}

- (void) tableViewColumnDidMove:(NSNotification *)notification {
    
}

- (void) tableViewColumnDidResize:(NSNotification *)notification {
    
}

- (void) tableViewSelectionIsChanging:(NSNotification *)notification {
    
}

@end