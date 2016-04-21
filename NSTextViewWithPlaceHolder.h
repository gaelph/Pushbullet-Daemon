//
//  NSTextViewWithPlaceHolder.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 18/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_NSTextViewWithPlaceHolder_h
#define Pushbullet_NSTextViewWithPlaceHolder_h
#import <Cocoa/Cocoa.h>

@interface NSTextViewWithPlaceHolder : NSTextView

@property NSMutableAttributedString * placeHolderAttributedString;
@property NSString * placeHolderString;
@property NSMutableDictionary * placeHolderStringAttributes;

@end

#endif
