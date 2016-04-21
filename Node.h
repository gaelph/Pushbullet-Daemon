//
//  Node.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_Node_h
#define Pushbullet_Node_h
#import <Cocoa/Cocoa.h>

enum {
    kPBAllNode = 0,
    kPBDeviceNode = 1,
    kPBContactsNode = 2,
    kPBSubscriptionNode = 3
};

@interface Node : NSObject

@property (strong) NSString * title;
@property (assign) BOOL isLeaf;
@property (strong) NSMutableArray * children;
@property (strong) Node * parent;
@property (strong) NSString * iden;
@property (assign) BOOL active;
@property (assign) NSInteger type;

+ (instancetype) nodeWithTitle:(NSString *)title isLeaf:(BOOL)leaf;

- (void) addChild:(Node *)child;
- (void) removeChildAtIndex:(NSInteger)index;
- (void) insertChild:(Node *)child AtIndex:(NSInteger)index;

@end

#endif
