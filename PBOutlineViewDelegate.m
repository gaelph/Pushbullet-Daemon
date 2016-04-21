//
//  PBOutlineViewDelegate.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBDelegate.h"
#import "PBOutlineViewDelegate.h"
#import "Node.h"
#import "ImageFromPush.h"

@implementation PBOutlineViewDelegate

- (NSMutableArray*) dataSource {
    if (_dataSource == nil) {
        PBDelegate * delegate = [[NSApplication sharedApplication] delegate];
        _dataSource = [[[delegate recipientsTreeController] arrangedObjects] mutableCopy];
    }
    return _dataSource;
}

- (IBAction)expandCollapse:(id)sender {
    NSView * view = [sender superview];
    NSInteger row = [_outlineView rowForView:view];
    NSTreeNode * item = [_outlineView itemAtRow:row];
    if (![_outlineView isItemExpanded:item]) {
        [[_outlineView animator] expandItem:item];
    } else {
        [[_outlineView animator] collapseItem:item];
    }
    return;
}

- (void) outlineView:(PBOutlineView *)outlineView configureItemView:(PBOutlineViewCellItem *)view ForNode:(Node *)node {
    if ([node title] != nil) {
        [[view title] setStringValue:[node title]];
    }
    if ([node type] != kPBDeviceNode) {
        NSImage * image;
        Image24SquareFromIden * transformer = [[Image24SquareFromIden alloc] init];
        image = [[transformer transformedValue:node.iden] copy];
        [[view itemPic] setImage:image];
    } else {
        [[view itemPic] setImage:nil];
    }
    [view setRepresentedObject:node];
    [view EditSessionChange:[outlineView editSessionOnGoing]];
    
}

- (void) outlineView:(PBOutlineView *)outlineView configureHeaderView:(PBOutlineViewCellHeader *)view ForNode:(Node *)node {
    if ([node title] != nil) {
        [[view title] setStringValue:[node title]];
        [[view hideButton] setIdentifier:NSOutlineViewShowHideButtonKey];
        
        [[view hideButton] setHidden:YES];
    }
}

- (void) outlineView:(PBOutlineView *)outlineView configureView:(NSView *)view ForNode:(Node *)node {
    if ([view isKindOfClass:[PBOutlineViewCellHeader class]]) {
        [self outlineView:outlineView configureHeaderView:(PBOutlineViewCellHeader *)view ForNode:node];
    }
    if ([view isKindOfClass:[PBOutlineViewCellItem class]]) {
        [self outlineView:outlineView configureItemView:(PBOutlineViewCellItem *)view ForNode:node];
    }
}

- (void)outlineView:(NSOutlineView *)outlineView
      didAddRowView:(NSTableRowView *)rowView
             forRow:(NSInteger)row {
    NSView * view = [outlineView viewAtColumn:0 row:row makeIfNecessary:NO];
    if (view) {
        if ([view isKindOfClass:[PBOutlineViewCellHeader class]]) {
            [view addTrackingRect:[view visibleRect] owner:view userData:nil assumeInside:NO];
            [view addObserver:view forKeyPath:@"visibleRect" options:0 context:nil];
            [((PBOutlineViewCellHeader *)view) mouseExited:nil];
        }
    }
    
}

- (void)outlineView:(NSOutlineView *)outlineView
   didRemoveRowView:(NSTableRowView *)rowView
             forRow:(NSInteger)row {
    
}

-(BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    if ([((PBOutlineView *)outlineView) editSessionOnGoing] == NO) {
        return ((Node *)item).isLeaf;
    }
    return YES;
}

-(void)outlineViewSelectionDidChange:(NSNotification *)aNotification {
    
    NSInteger selectedRow = [self.outlineView selectedRow];
    
    NSTreeNode * item = [_outlineView itemAtRow:selectedRow];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBOutlineVewSelectionDidChangeNotification object:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
        isGroupItem:(id)item {
    return NO;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView
     viewForTableColumn:(NSTableColumn *)tableColumn
                   item:(id)item {
    if ([self outlineView] == nil) {
        [self setOutlineView:outlineView];
        [[self outlineView] setDelegate:self];
    }
    
    Node * node = [(NSTreeNode *)item representedObject];
    NSView * result;
    
    if ([node isLeaf] == YES) {
        PBOutlineViewCellItem * view;
        view = [outlineView makeViewWithIdentifier:@"PBOutlineViewCellItem" owner:self];
        result = view;
    } else {
        PBOutlineViewCellHeader * view;
        view = [outlineView makeViewWithIdentifier:@"PBOutlineViewCellHeader" owner:self];
        result = view;
    }
    
    [self outlineView:(PBOutlineView *)outlineView configureView:result ForNode:node];
    if ([node type] == kPBDeviceNode) {
        [outlineView expandItem:item];
    }
    return result;
}

-(NSTableRowView *) outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    PBOutlineRowView * rowView = [[PBOutlineRowView alloc] init];
    
    return rowView;
}

@end
