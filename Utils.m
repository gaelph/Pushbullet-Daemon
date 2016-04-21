//
//  Utils.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 11/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"
#import "Pushbullet.h"
#import "DateTools.h"

@implementation Utils

+ (void) openURL:(NSString*)url {
    NSURL *Url = [NSURL URLWithString:url];
    [[NSWorkspace sharedWorkspace] openURL:Url];
}

+ (NSBitmapImageFileType) typeForExtension:(NSString *)extension {
    if ([[extension lowercaseString] isEqualToString:@"bmp"]) {
        return NSBMPFileType;
    } else if ([[extension lowercaseString] isEqualToString:@"gif"]) {
        return NSGIFFileType;
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"]) {
        return NSJPEGFileType;
    } else if ([[extension lowercaseString] isEqualToString:@"jpeg"]) {
        return NSJPEGFileType;
    } else if ([[extension lowercaseString] isEqualToString:@"png"]) {
        return NSPNGFileType;
    } else if ([[extension lowercaseString] isEqualToString:@"tif"]) {
        return NSTIFFFileType;
    } else if ([[extension lowercaseString] isEqualToString:@"tiff"]) {
        return NSTIFFFileType;
    }
    
    return -1;
}

+ (NSString *) computerName {
    //Getting Computer Model (e.g. MacBookPro7,1)
    CFStringRef cfName = SCDynamicStoreCopyComputerName(NULL, NULL);
    NSString * nsName = [(__bridge NSString *)cfName copy];
    
    CFRelease(cfName);
    return nsName;
}

+ (NSString *) computerModel {
    NSString * __block computerModel = nil;
    
    //preparing call for sysctl
    NSTask * sysctl = [[NSTask alloc] init];
    sysctl.launchPath = @"/usr/sbin/sysctl";
    sysctl.arguments = @[@"hw.model"];
    
    //setting the outputPipe so we get the result
    NSPipe * __strong outputPipe = [[NSPipe alloc] init];
    sysctl.standardOutput = outputPipe;
    
    [[outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
    
    //asking for a notification when the pipe gets written to
    [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[outputPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *notification) {
        //formating the output to get the interesting part of it
        NSData *output = [[outputPipe fileHandleForReading] availableData];
        NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
        
        NSArray *splittedOutput = [outputString componentsSeparatedByString:@" "];
        NSString *modelString = [splittedOutput[1] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        computerModel = modelString;
        
    }];
    
    //starting sysctl
    [sysctl launch];
    [sysctl waitUntilExit]; //stop this thread until sysctl is done
    
    //waiting to get our output formated and shit
    NSDate *then = [NSDate date];
    NSTimeInterval timeout = 10; //set a 10s timeout in case it failed
    while (computerModel == nil) {
        NSDate *now = [NSDate date];
        if ([now timeIntervalSinceDate:then] > timeout) {
            PBLOGF(@"Couldn't get Model Name, timeout after %gs", timeout);
            break;
        }
    }
    return computerModel;
}

+ (NSString *) getDateStringFromDate:(NSDate *)date withDateFormatter:(NSDateFormatter *) formatter {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) {
        return date.timeAgoSinceNow;
    } else {
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        // read out the format string
        NSString *format = [formatter dateFormat];
        format = [format stringByReplacingOccurrencesOfString:@"y" withString:@""];
        [formatter setDateFormat:format];
    }
    return [formatter stringFromDate:otherDate];
}

@end
