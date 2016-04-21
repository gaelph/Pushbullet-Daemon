//
//  PBTableViewDataSource.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 12/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_PBTableViewDataSource_h
#define Pushbullet_PBTableViewDataSource_h
#import <Cocoa/Cocoa.h>

@interface PBTableViewDataSource : NSObject <NSTableViewDataSource>

@property (nonatomic) NSArray * _content;
@property NSArrayController * arrayController;


-(void) setContent:(NSArray *)content;
-(NSArray *) content;
-(id) objectAtIndex:(NSUInteger)index;

@end

#endif
