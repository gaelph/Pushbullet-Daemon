//
//  PBTableView.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 14/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_PBTableView_h
#define Pushbullet_PBTableView_h
#import <Cocoa/Cocoa.h>

@interface PBTableView : NSTableView

- (id) objectValueForRow:(NSUInteger)row;

@end


#endif
