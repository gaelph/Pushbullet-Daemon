//
//  PBSignInWindowController.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 11/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBSignInWindowController.h"

@implementation PBSignInWindowController

@synthesize delegate;

@synthesize menuWindow;
@synthesize webview;
@synthesize waitingView;
@synthesize spinningWheel;

@synthesize gotApiKey;

- (void) awakeFromNib {
    [menuWindow orderFrontRegardless];
    [self goToSignIn];
}

- (void) showSimpleAlert: (NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Uh oh..."];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self menuWindow] completionHandler:^(NSModalResponse returnCode) {
        return;
    }];
}

- (NSString *) URLEncodeDictionary:(NSDictionary *)dict {
    NSMutableString * result = [[NSMutableString alloc] init];
    
    for (NSString * currKey in dict) {
        NSString * currObject = [dict valueForKey:currKey];
        if ([result length] > 0)
            [result appendString:@"&"];
            
            [result appendString:[NSString stringWithFormat:@"%@=%@", [currKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [currObject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    return result;
}

- (NSURL *) googleSignInURL {
    NSURL *signInUrl;
    NSMutableDictionary * requestDict = [[NSMutableDictionary alloc] init];
    NSMutableString * baseURL = [[NSMutableString alloc] init];
    [baseURL appendString:@"https://accounts.google.com/o/oauth2/auth?"];
    char state_iden[32];
    srand((int)time(NULL));
    for (int i=0; i < 32; i++) {
        state_iden[i] = "ABCDEFGHIJKLMONPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"[rand() % 62];
    }
    
    NSString *stateIden = [[NSString alloc] initWithBytes:state_iden length:32 encoding:NSUTF8StringEncoding];
    
    [requestDict setValue:stateIden forKey:@"state"];
    [requestDict setValue:@"https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile" forKey:@"scope"];
    [requestDict setValue:@"select_account" forKey:@"prompt"];
    [requestDict setValue:@"https://www.pushbullet.com/" forKey:@"redirect_uri"];
    [requestDict setValue:@"336343571939-881tp5n559pij79kmb2irmnbg641qt7c.apps.googleusercontent.com" forKey:@"client_id"];
    [requestDict setValue:@"token" forKey:@"response_type"];
    
    [baseURL appendString:[self URLEncodeDictionary:requestDict]];
    
    signInUrl = [NSURL URLWithString:baseURL];
    
    return signInUrl;
}

- (void) goToSignIn {
    gotApiKey = NO;

    NSURL *url = [self googleSignInURL];
    [webview.mainFrame loadRequest:[NSURLRequest requestWithURL:url]];
}

- (NSString *) getMeCookie {
    NSHTTPCookieStorage *CookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [CookieStorage cookiesForURL:[NSURL URLWithString:@"https://www.pushbullet.com"]];
    NSEnumerator *cookieEnum = [cookies objectEnumerator];
    NSHTTPCookie *c;
    
    while (c = [cookieEnum nextObject]) {
        if ([c.name  isEqual: @"api_key"]) {
            return c.value;
        }
    }
    return nil;
}

- (void)webView:(WebView *)sender
didReceiveServerRedirectForProvisionalLoadForFrame:(WebFrame *)frame {
    [menuWindow setContentView:waitingView];
    [spinningWheel startAnimation:self];
    
    NSURL * frameURL = [NSURL URLWithString:sender.mainFrameURL];
    if ([[frameURL host] isNotEqualTo:@"www.pushbullet.com"]) {
        //[menuWindow setContentView:webview];
    } else {
        NSString * query = [frameURL fragment];
        if (query != nil) {
            NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
            
            for (NSString * pair in [query componentsSeparatedByString:@"&"]) {
                NSArray * keyAndValue = [pair componentsSeparatedByString:@"="];
                if ([keyAndValue count] == 2) {
                    [params setValue:[keyAndValue objectAtIndex:1] forKey:[keyAndValue objectAtIndex:0]];
                }
                
            }
            
            NSString * access_token = [params valueForKey:@"access_token"];
            if (access_token == nil) {
                return;
            }
            
            NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.pushbullet.com/v2/authenticate"]];
            [request setHTTPMethod:@"POST"];
            
            NSString * JSONBody = [NSString stringWithFormat:@"{\"access_token\": \"%@\", \"type\": \"google\"}", access_token];
            NSData * data = [JSONBody dataUsingEncoding:NSUTF8StringEncoding];
            
            [request setHTTPBody:data];
            [request addValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Content-Type"];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (connectionError == nil) {
                    NSError * error = nil;
                    
                    NSDictionary * responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                    if (error) {
                        if (error) NSLog(@"%@", error);
                        return;
                    }
                    
                    NSString * apiKey = [responseDict valueForKey:@"api_key"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBSignInGotApiKey" object:apiKey];
                }
                NSLog(@"%@",response);
                NSLog(@"%@", data);
            }];
            
        }
    }
    
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    [menuWindow setContentView:waitingView];
    [spinningWheel startAnimation:self];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame  {
    NSURL * frameURL = [NSURL URLWithString:sender.mainFrameURL];
    if ([[frameURL host] isNotEqualTo:@"www.pushbullet.com"])
        [menuWindow setContentView:webview];
    
}

- (BOOL) windowShouldClose:(NSNotification *)aNotification {
    if (gotApiKey == YES) {
        [webview close];
        return YES;
    } else {
        [[NSApplication sharedApplication] terminate:self];
        return YES;
    }
}

@end
