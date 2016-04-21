//
//  PBTableViewCell.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 08/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBTableViewDelegate.h"
#import "PBTableViewCell.h"
#import "Utils.h"
#import "Pushbullet.h"
#import "ImageFromPush.h"
#import "DateTools.h"

@implementation PBBackgroundView

- (void)drawRect:(NSRect)dirtyRect {
    // set any NSColor for filling, say white:
    [_backgroundColor setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end


@implementation PBLinkField

- (void) mouseDown:(NSEvent *)theEvent {
    [Utils openURL:[self stringValue]];
}
- (void) mouseEntered:(NSEvent *)theEvent {
    NSRange range = NSMakeRange(0, [[self attributedStringValue] length]);
    NSMutableAttributedString * attrString = [[self attributedStringValue] mutableCopy];
    
    [attrString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
    
    [self setAttributedStringValue:attrString];
    
}
- (void) mouseExited:(NSEvent *)theEvent {
    NSRange range = NSMakeRange(0, [[self attributedStringValue] length]);
    NSMutableAttributedString * attrString = [[self attributedStringValue] mutableCopy];
    
    [attrString removeAttribute:NSUnderlineStyleAttributeName range:range];
    
    [self setAttributedStringValue:attrString];
}

@end

@implementation PBTitleField

- (void) mouseDown:(NSEvent *)theEvent {
    [[[self superview] superview] mouseDown:theEvent];
    //[super mouseDown:theEvent];
}

@end

@implementation PBPushActionButton
@synthesize menu;

- (void) makeMenu {
    self.menu = [[NSMenu alloc] initWithTitle:@"PushPopoverMenu"];
    [[self menu] setAutoenablesItems:NO];
    NSMenuItem * deleteMenuItem = [[NSMenuItem alloc] initWithTitle:@"Delete" action:@selector(deletePush:) keyEquivalent:@""];
    [[self menu] addItem:deleteMenuItem];
    [deleteMenuItem setEnabled:YES];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (IBAction)deletePush:(id)sender {
    NSView * backgroundView = [self superview];
    NSView * view = [backgroundView superview];
    if ([view respondsToSelector:@selector(deletePush)]) {
        [(PBTableViewCell *)view deletePush];
    }
}

- (void) mouseDown:(NSEvent *)theEvent {
    //[self highlight:YES];
    if ([self menu] == nil) {
        [self makeMenu];
    }
    [NSMenu popUpContextMenu:[self menu] withEvent:theEvent forView:self];
}

@end



@implementation PBTableViewCell
@synthesize value;
@synthesize expanded;

- (NSString *) getDateStringFromDate:(NSDate *)date {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) {
        return date.timeAgoSinceNow;
    } else {
        [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        // read out the format string
        NSString *format = [self.dateFormatter dateFormat];
        format = [format stringByReplacingOccurrencesOfString:@"y" withString:@""];
        [self.dateFormatter setDateFormat:format];
    }
    return [[self dateFormatter] stringFromDate:otherDate];
}


- (void) setObjectValue:(id)objectValue {
    if (value != nil && objectValue == nil)
        return;
    
    value = objectValue;
    NSDictionary * push = (NSDictionary *)objectValue;
    
    //[self collapse];
    
    NSString * Title = @"";
    if ([push valueForKey:kPBTitleKey] != nil)
        Title = [push valueForKey:kPBTitleKey];
    [[self Title] setStringValue:Title];
    
    NSString * URL = @"";
    if ([push valueForKey:kPBUrlKey] != nil)
        URL = [push valueForKey:kPBUrlKey];
    else if ([push valueForKey:kPBFileUrlKey])
        URL = [push valueForKey:kPBFileUrlKey];
    [[self URL] setStringValue:URL];
    [[self URL] addTrackingRect:[[self URL] visibleRect] owner:[self URL] userData:nil assumeInside:NO];
    
    NSString * Body = @"";
    if ([push valueForKey:kPBBodyKey] != nil) {
        Body = [push valueForKey:kPBBodyKey];
        [[self Body] setHidden:NO];
    } else {
        NSRect frame = [[self Body] frame];
        frame.size.height = 0;
        [[self Body] setFrame:frame];
        [[self Body] setHidden:YES];
    }
    [[self Body] setStringValue:Body];
    
    NSString * Sender = @"";
    if ([push valueForKey:@"sender_name"] != nil)
        Sender = [NSString stringWithFormat:@"From %@", [push valueForKey:@"sender_name"]];
    [[self Sender] setStringValue:Sender];
    
    [[self Background] setBackgroundColor:[NSColor whiteColor]];
    
    [self layout];
}

- (void) setDateString:(NSString *)dateString {
    if (dateString) {
        [[self DateView] setStringValue:dateString];
    }
}

- (id) objectValue {
    return value;
}

- (void) fetchImage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * push = [self objectValue];
        Image32SquareFromPush * transformer = [[Image32SquareFromPush alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self ProfilePicture] setImage:[transformer transformedValue:push]];
        });
    });
}

- (void)mouseDown:(NSEvent *)theEvent {
    if ([theEvent clickCount] == 2) {
        //PBLOG(@"DoubleClick")
    } else {
        //PBLOGF(@"View received %ld clicks", [theEvent clickCount])
    }
    
    [super mouseDown:theEvent];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBTableShowOneItem" object:[self objectValue]];
}

- (void) deletePush {
    NSTableRowView * rowView = (NSTableRowView *)[self superview];
    NSView * parent = [rowView superview];
    NSTableView * tableView;
    if ([parent isKindOfClass:[NSTableView class]]) {
        tableView = (NSTableView *)parent;
    }
    NSNumber * row = [NSNumber numberWithInteger:[tableView rowForView:rowView]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBTableRemoveItemNotification object:row];
}

@end