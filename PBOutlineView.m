//
//  PBOutlineViewDelegate.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//


#import "PBOutlineView.h"
#import "PBDelegate.h"
#import "Node.h"
#import "PBOutlineViewCell.h"
#import "ImageFromPush.h"
#import "PBOutlineViewDelegate.h"

@implementation PBOutlineView

- (id)init
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

- (NSView *) makeViewWithIdentifier:(NSString *)identifier owner:(id)owner {
    if ([identifier isEqualToString:NSOutlineViewDisclosureButtonKey]) {
        return nil;
    }
    
    return [super makeViewWithIdentifier:identifier owner:owner];
}

//TODO:Localization
- (void) expandItem:(id)item {
    [super expandItem:item];
    NSInteger row = [self rowForItem:item];
    
    if ((row > 0) && (row < [self numberOfRows])) {
        PBOutlineViewCellHeader * view = [self viewAtColumn:0 row:row makeIfNecessary:NO];
        NSButton * showHodeButton = [view hideButton];
        [showHodeButton setTitle:@"Hide"];
    }
}

- (void) collapseItem:(id)item {
    [super collapseItem:item];
    NSInteger row = [self rowForItem:item];
    PBOutlineViewCellHeader * view = [self viewAtColumn:0 row:row makeIfNecessary:NO];
    NSButton * showHodeButton = [view hideButton];
    [showHodeButton setTitle:@"Show"];
    
}

- (IBAction)expandCollapse:(id)sender {
    NSView * view = [sender superview];
    NSInteger row = [self rowForView:view];
    NSTreeNode * item = [self itemAtRow:row];
    if (![self isItemExpanded:item]) {
        [[self animator] expandItem:item];
    } else {
        [[self animator] collapseItem:item];
    }
    return;
}

- (IBAction) showEditButtons:(id)sender {
    //update self value
    self.editSessionOnGoing = self.editSessionOnGoing ? NO : YES;
    
    //modify the UI
    [((NSButton *)sender) setTitle:([self editSessionOnGoing]?@"Finished":@"Edit")];
    
    //Enumerate the views to apply the change
    [self enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        [[rowView subviews] enumerateObjectsUsingBlock:^(NSView *view, NSUInteger idx, BOOL *stop) {
            //Make sure we have the appropriate view class
            if ([view isKindOfClass:[PBOutlineViewCellItem class]]) {
                PBOutlineViewCellItem * itemView = (PBOutlineViewCellItem *)view;
                [itemView EditSessionChange:self->_editSessionOnGoing];
            }
        }];
    }];
}

- (NSView *) viewForItem:(id)item {
    __block PBOutlineViewCellItem * result;
    [self enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        [[rowView subviews] enumerateObjectsUsingBlock:^(PBOutlineViewCellItem * view, NSUInteger idx, BOOL *stop) {
            if ([view respondsToSelector:@selector(representedObject)]) {
                if ([[view representedObject] isEqualTo:item]) {
                    result = view;
                }
            }
        }];
    }];
    return result;
}

@end