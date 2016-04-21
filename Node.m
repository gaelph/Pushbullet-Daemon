//
//  Node.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@implementation Node

@synthesize title,children,iden;

+ (instancetype) nodeWithTitle:(NSString *)title isLeaf:(BOOL)leaf {
    Node * node = [[Node alloc] init];
    [node setTitle:title];
    [node setIsLeaf:leaf];
    [node setActive:YES];
    
    return node;
}

- (void) addChild:(Node *)child {
    if (children == nil) [self setChildren:[[NSMutableArray alloc] init]];
    [children addObject:child];
}

- (void) removeChildAtIndex:(NSInteger)index {
    [children removeObjectAtIndex:index];
}

- (void) insertChild:(Node *)child AtIndex:(NSInteger)index {
    [children insertObject:child atIndex:index];
}

@end
