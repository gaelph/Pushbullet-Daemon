//
//  PBOutlineViewDelegate.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_PBOutlineViewDelegate_h
#define Pushbullet_PBOutlineViewDelegate_h
#import <Cocoa/Cocoa.h>
#import "PBOutlineViewCell.h"

@interface PBOutlineViewDelegate : NSObject <NSOutlineViewDelegate>

@property (nonatomic, strong) NSMutableArray * dataSource;
@property IBOutlet PBOutlineViewCellHeader *dummyHeader;
@property IBOutlet PBOutlineViewCellItem *dummyItem;
@property NSOutlineView * outlineView;


- (NSMutableArray *) dataSource;

- (IBAction)expandCollapse:(id)sender;

@end


#endif
