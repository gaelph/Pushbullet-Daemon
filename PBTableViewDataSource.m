//
//  PBTableViewDataSource.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 12/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBTableViewDataSource.h"
#import "PBTableView.h"

@implementation PBTableViewDataSource

-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return [tableView numberOfRows];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    id result;
    
    if ([tableView isKindOfClass:[PBTableView class]]) {
        result = [((PBTableView *)tableView) objectValueForRow:row];
    }
    
    return result;
}

-(void) setContent:(NSArray *)content {
    self._content = content;
}

-(NSArray *) content {
    return self._content;
}

-(id)objectAtIndex:(NSUInteger)index {
    if (index < [[self.arrayController arrangedObjects] count]) {
        return [[self.arrayController arrangedObjects] objectAtIndex:index];
    }
    return nil;
}

@end

