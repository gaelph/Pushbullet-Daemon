//
//  RecipientNameFromIden.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 17/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_RecipientNameFromIden_h
#define Pushbullet_RecipientNameFromIden_h
#import <Cocoa/Cocoa.h>

@interface RecipientNameFromIden : NSValueTransformer

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;

- (id) transformedValue:(id)value;

@end

#endif
