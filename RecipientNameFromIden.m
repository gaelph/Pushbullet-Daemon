//
//  RecipientNameFromIden.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 17/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecipientNameFromIden.h"
#import "PBDelegate.h"
#import "MainWindowController.h"

@implementation RecipientNameFromIden : NSValueTransformer

+ (Class)transformedValueClass {
    return [NSArray class];
}
+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id) transformedValue:(id)value {
    __block NSMutableArray * result = nil;
    
    if ([value isKindOfClass:[NSArray class]]) {
        PBDelegate * delegate;
        id appDelegate = [[NSApplication sharedApplication] delegate];
        if ([appDelegate isKindOfClass:[PBDelegate class]])
            delegate = (PBDelegate *)appDelegate;
        
        PBMainWindowController * mainWindowController = [delegate mainWindowController];
        NSArray * recipients = [mainWindowController recipientsArray];
        for (NSString * iden in value) {
            result = [NSMutableArray array];
            [recipients enumerateObjectsUsingBlock:^(NSDictionary * item, NSUInteger idx, BOOL *stop) {
                if ([item valueForKey:@"name"]) {
                    [result addObject:[item valueForKey:@"name"]];
                } else if ([item valueForKey:@"nickname"]) {
                    [result addObject:[item valueForKey:@"nickname"]];
                }
            }];
        }
    }
    
    return result;
}

@end