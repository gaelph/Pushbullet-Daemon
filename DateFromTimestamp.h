//
//  DateFromTimestamp.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 11/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_DateFromTimestamp_h
#define Pushbullet_DateFromTimestamp_h
#import <Cocoa/Cocoa.h>

@interface DateFromTimestamp : NSValueTransformer

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;

- (id) transformedValue:(id)value;
- (id) reverseTransformedValue:(id)value;

@end

#endif
