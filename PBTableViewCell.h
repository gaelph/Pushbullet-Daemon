//
//  PBTableViewCell.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 08/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_PBTableViewCell_h
#define Pushbullet_PBTableViewCell_h
#import <Cocoa/Cocoa.h>

@interface PBBackgroundView : NSView

@property (assign) NSColor* backgroundColor;

@end


@interface PBLinkField : NSTextField

- (void) mouseDown:(NSEvent *)theEvent;
- (void) mouseEntered:(NSEvent *)theEvent;
- (void) mouseExited:(NSEvent *)theEvent;

@end


@interface PBTitleField : NSTextField

- (void) mouseDown:(NSEvent *)theEvent;

@end


@interface PBPushActionButton : NSButton

- (void) mouseDown:(NSEvent *)theEvent;

@end


@interface PBTableViewCell : NSTableCellView

@property (nonatomic) IBOutlet PBTitleField *Title;
@property (nonatomic) IBOutlet PBLinkField *URL;
@property (nonatomic) IBOutlet NSTextField *Sender;
@property (nonatomic) IBOutlet PBBackgroundView *Background;
@property (nonatomic) IBOutlet NSImageView *ProfilePicture;
@property (nonatomic) IBOutlet NSTextField *Body;
@property (nonatomic) IBOutlet NSTextField *DateView;
@property (nonatomic) IBOutlet NSDate * date;
@property (nonatomic) IBOutlet PBPushActionButton * actionButton;
@property IBOutlet NSDateFormatter * dateFormatter;
@property (strong) NSLayoutConstraint * bodyHeightConstraint;
@property (strong) id value;
@property (assign) BOOL expanded;

- (void) setObjectValue:(id)objectValue;
- (id) objectValue;

- (void) fetchImage;

- (void) deletePush;


@end


#endif
