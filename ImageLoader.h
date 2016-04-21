//
//  ImageLoader.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 12/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_ImageLoader_h
#define Pushbullet_ImageLoader_h

static NSString * PBImageReceivedNotification = @"ImageReceived";

@interface PBImageLoader : NSObject

@property NSString * _name;
@property NSString * _extension;
@property NSBitmapImageRep * _image;

- (void) loadImageFromURL:(NSURL *)url ofType:(NSString *)extension withName:(NSString *)name;

@end

#endif
