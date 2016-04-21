//
//  ImageLoader.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 12/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "ImageLoader.h"
#import "PBDefines.h"

@implementation PBImageLoader
@synthesize _image;
@synthesize _name;
@synthesize _extension;

- (void) loadImageFromURL:(NSURL *)url ofType:(NSString *)extension withName:(NSString *)name {
    self._name = name;
    self._extension = extension;
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError) PBLOGE(connectionError);
        if (response) {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse * )response;
            
            if (httpResponse.statusCode == 200) {
                //PBLOGF(@"Status Code : %li", httpResponse.statusCode);
                
                self._image = [[NSBitmapImageRep alloc] initWithData:data];
                [[NSNotificationCenter defaultCenter] postNotificationName:PBImageReceivedNotification object:self];
                return;
            }
            PBLOGF(@"HTTP Err : %@ %@", httpResponse, data);
        }
        PBLOG(@"No Response ?");
    }];

}

@end