//
//  PBSignInWindowController.h
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 11/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#ifndef Pushbullet_PBSignInWindowController_h
#define Pushbullet_PBSignInWindowController_h

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <WebKit/WebPreferences.h>

@interface PBSignInWindowController : NSWindowController{
@private
    NSWindow *menuWindow;
    WebView *webview;
}

@property (weak) IBOutlet id delegate;

@property IBOutlet NSWindow *menuWindow;
@property IBOutlet WebView *webview;
@property IBOutlet NSView *waitingView;
@property IBOutlet NSProgressIndicator *spinningWheel;

@property (readonly) BOOL gotApiKey;

- (void) goToSignIn;

@end

@interface NSObject(PBSignInReceiver)

- (void) gotApiKey:(NSString *)apiKey;

@end

#endif
