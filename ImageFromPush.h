//
//  ImageFromPush.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_ImageFromPush_h
#define Pushbullet_ImageFromPush_h
#import <Cocoa/Cocoa.h>

@interface ImageFromIden : NSValueTransformer

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;

- (id) transformedValue:(id)value;

@end

@interface ImageFromPush : ImageFromIden

- (id) transformedValue:(id)value;

@end

@interface Image16SquareFromPush : ImageFromPush

- (id) transformedValue:(id)value;

@end

@interface Image24SquareFromPush : ImageFromPush

- (id) transformedValue:(id)value;

@end

@interface Image32SquareFromPush : ImageFromPush

- (id) transformedValue:(id)value;

@end

@interface Image48SquareFromPush : ImageFromPush

- (id) transformedValue:(id)value;

@end

@interface Image64SquareFromPush : ImageFromPush

- (id) transformedValue:(id)value;

@end

@interface Image16SquareFromIden : ImageFromIden

- (id) transformedValue:(id)value;

@end

@interface Image24SquareFromIden : ImageFromIden

- (id) transformedValue:(id)value;

@end

@interface Image32SquareFromIden : ImageFromIden

- (id) transformedValue:(id)value;

@end

@interface Image48SquareFromIden : ImageFromIden

- (id) transformedValue:(id)value;

@end

@interface Image64SquareFromIden : ImageFromIden

- (id) transformedValue:(id)value;

@end

#endif
