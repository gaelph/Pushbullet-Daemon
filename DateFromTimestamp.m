//
//  DateFromTimestamp.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 11/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateFromTimestamp.h"

@implementation DateFromTimestamp

+ (Class)transformedValueClass {
    return [NSDate class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id) transformedValue:(id)value {
    NSDate * result;
    NSString * stringValue = (NSString *)value;
    NSTimeInterval timestamp = [stringValue doubleValue];
    result = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    return result;
}
- (id) reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSDate class]]) {
        NSTimeInterval interval = [((NSDate *)value) timeIntervalSince1970];
        return [NSNumber numberWithDouble:interval];
    }
    return value;
}

@end