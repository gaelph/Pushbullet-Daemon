//
//  NSTextViewWithPlaceHolder.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 18/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSTextViewWithPlaceHolder.h"

@implementation NSTextViewWithPlaceHolder
@synthesize placeHolderAttributedString;
@synthesize placeHolderString;
@synthesize placeHolderStringAttributes;


- (instancetype) init {
    self = [super init];
    
    if (self) {
        
        if (placeHolderString == nil) placeHolderString = @"Message";
    }
    
    return self;
}


- (BOOL)becomeFirstResponder
{
    [self setNeedsDisplay:YES];
    return [super becomeFirstResponder];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    if ([[self string] isEqualToString:@""]) {
        if (placeHolderStringAttributes == nil) {
            NSColor *txtColor = [NSColor colorWithCalibratedWhite:0.5 alpha:0.7];
            NSMutableParagraphStyle * paragrapheStyle = [[NSMutableParagraphStyle alloc] init];
            [paragrapheStyle setParagraphSpacing:0];
            [paragrapheStyle setParagraphSpacingBefore:0];
            [paragrapheStyle setLineSpacing:0];
            placeHolderStringAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:txtColor, NSForegroundColorAttributeName, paragrapheStyle, NSParagraphStyleAttributeName, [NSFont fontWithName:@"Helvetica Neue" size:13], NSFontAttributeName, nil];
        }
        if (placeHolderAttributedString == nil) {
            placeHolderAttributedString = [[NSMutableAttributedString alloc] initWithString:placeHolderString attributes:placeHolderStringAttributes];
        }
        [placeHolderAttributedString drawAtPoint:rect.origin];
    }
}

- (BOOL)resignFirstResponder
{
    [self setNeedsDisplay:YES];
    return [super resignFirstResponder];
}


@end