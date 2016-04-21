//
//  ImageFromPush.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageFromPush.h"
#import "Pushbullet.h"
#import "PBDelegate.h"

@implementation ImageFromIden

+ (Class)transformedValueClass {
    return [NSObject class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id) transformedValue:(id)value {
    if (value == nil) return nil;
    
    if ([value isKindOfClass:[NSString class]]) {
        PBDelegate * delegate;
        id appDelegate = [[NSApplication sharedApplication] delegate];
        if ([appDelegate isKindOfClass:[PBDelegate class]])
             delegate = (PBDelegate *)appDelegate;
             
        NSMutableDictionary *imageDataBank = [delegate imageDataBank];
        NSImage * result = nil;
        NSString * iden = value;
        
        if (imageDataBank == nil) {
            NSFileManager * fileManager = [[NSFileManager alloc] init];
            NSURL * groupURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:PBAppGroup];
            NSURL * cachesURL = [groupURL URLByAppendingPathComponent:CachesFolder];
            
            imageDataBank = [NSKeyedUnarchiver unarchiveObjectWithFile:[[cachesURL URLByAppendingPathComponent:@"images.db"] path]];
        }
        
        if ([imageDataBank valueForKey:iden] != nil) {
            result = [imageDataBank valueForKey:iden];
            [delegate setImageDataBank:imageDataBank];
            return result;
        } else {
            NSDictionary * user = [[[delegate storageController] defaults] valueForKey:@"user"];
            if ([[user valueForKey:kPBIdenKey] isEqualTo:iden]) {
                NSImage * result = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[user valueForKey:@"image_url"]]];
                
                [imageDataBank setValue:result forKey:iden];
                [delegate setImageDataBank:imageDataBank];
                return result;
            }
            
            NSArray * contacts = [[[delegate storageController] defaults] valueForKey:@"contacts"];
            for (NSDictionary * contact in contacts) {
                if ([[contact valueForKey:kPBIdenKey] isEqualTo:iden]) {
                    NSImage * result = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[contact valueForKey:@"image_url"]]];
                    
                    [imageDataBank setValue:result forKey:iden];
                    [delegate setImageDataBank:imageDataBank];
                    return result;
                }
            }
            
        }
        
        
        NSFileManager * fileManager = [[NSFileManager alloc] init];
        NSURL * groupURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:PBAppGroup];
        NSURL * cachesURL = [groupURL URLByAppendingPathComponent:CachesFolder];
        NSURL * cachedFileURL = [cachesURL URLByAppendingPathComponent:iden];
        NSString * cachedFilePath = cachedFileURL.path;
        
        if ([fileManager fileExistsAtPath:cachedFilePath]) {
            result = [[NSImage alloc] initWithContentsOfFile:cachedFilePath];
            
            [imageDataBank setValue:result forKey:iden];
            goto exit;
        } else {
            PBLOGF(@"Subscription image not set : file not found at path %@", cachedFilePath);
            return nil;
        }
    exit:
        [delegate setImageDataBank:imageDataBank];
        return result;
    }
    return nil;
}

@end

@implementation ImageFromPush

- (id) transformedValue:(id)value {
    if (value == nil) return nil;
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        
        if ([((NSDictionary *)value) valueForKey:kPBChannelIdenKey]) {
            return [super transformedValue:[((NSDictionary *)value) valueForKey:kPBChannelIdenKey]];
        }
        
        if ([((NSDictionary *)value) valueForKey:kPBSenderIdenKey]) {
            return [super transformedValue:[((NSDictionary *)value) valueForKey:kPBSenderIdenKey]];
        }
    }
    return nil;
}

@end

@implementation Image16SquareFromPush

- (id) transformedValue:(id)value {
    NSImage * result = [super transformedValue:value];
    NSSize size = NSSizeFromString(@"{16,16}");
    [result setSize:size];
    return result;
}

@end

@implementation Image24SquareFromPush

- (id) transformedValue:(id)value {
    NSImage * result = [super transformedValue:value];
    NSSize size = NSSizeFromString(@"{24,24}");
    [result setSize:size];
    return result;
}

@end

@implementation Image32SquareFromPush

- (id) transformedValue:(id)value {
    NSImage * result = [super transformedValue:value];
    NSSize size = NSSizeFromString(@"{32,32}");
    [result setSize:size];
    return result;
}

@end

@implementation Image48SquareFromPush

- (id) transformedValue:(id)value {
    NSImage * result = [super transformedValue:value];
    NSSize size = NSSizeFromString(@"{48,48}");
    [result setSize:size];
    return result;
}

@end

@implementation Image64SquareFromPush

- (id) transformedValue:(id)value {
    NSImage * result = [super transformedValue:value];
    NSSize size = NSSizeFromString(@"{64,64}");
    [result setSize:size];
    return result;
}

@end

#pragma mark

@implementation Image16SquareFromIden

- (id) transformedValue:(id)value {
    NSImage * result = [super transformedValue:value];
    NSSize size = NSSizeFromString(@"{16,16}");
    [result setSize:size];
    return result;
}

@end

@implementation Image24SquareFromIden

- (id) transformedValue:(id)value {
    NSImage * result = [super transformedValue:value];
    NSSize size = NSSizeFromString(@"{24,24}");
    [result setSize:size];
    return result;
}

@end

@implementation Image32SquareFromIden

- (id) transformedValue:(id)value {
    NSImage * result = [super transformedValue:value];
    NSSize size = NSSizeFromString(@"{32,32}");
    [result setSize:size];
    return result;
}

@end

@implementation Image48SquareFromIden

- (id) transformedValue:(id)value {
    NSImage * result = [super transformedValue:value];
    NSSize size = NSSizeFromString(@"{48,48}");
    [result setSize:size];
    return result;
}

@end

@implementation Image64SquareFromIden

- (id) transformedValue:(id)value {
    NSImage * result = [super transformedValue:value];
    NSSize size = NSSizeFromString(@"{64,64}");
    [result setSize:size];
    return result;
}

@end
