//
//  PBTableView.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 14/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBTableView.h"
#import "PBTableViewCell.h"
#import "PBTableViewDelegate.h"

@implementation PBTableView

- (id) objectValueForRow:(NSUInteger)row {
    PBTableViewCell * view = [self viewAtColumn:0 row:row makeIfNecessary:NO];
    return [view objectValue];
}

@end