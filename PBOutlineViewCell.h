//
//  PBOutlineView.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_PBOutlineViewCell_h
#define Pushbullet_PBOutlineViewCell_h
#import <Cocoa/Cocoa.h>
#import "Node.h"

@interface PBOutlineViewCellHeader : NSTableCellView

@property (nonatomic) IBOutlet NSTextField * title;
@property (nonatomic) IBOutlet NSButton * hideButton;

@end

@interface PBOutlineViewCellItem : NSTableCellView

@property (nonatomic) id representedObject;
@property (assign) BOOL shouldShowRemoveButton;
@property (nonatomic) IBOutlet NSImageView * itemPic;
@property (nonatomic) IBOutlet NSTextField * title;
@property (nonatomic) IBOutlet NSButton * settingsButton;

- (void) EditSessionChange:(BOOL)newValue;

@end

@interface PBOutlineRowView : NSTableRowView
@end

#endif
