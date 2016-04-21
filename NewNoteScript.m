//
//  NewNoteScript.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 09/11/2014.
//  Copyright (c) 2014 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewNoteScript.h"
#import "PBDefines.h"

@implementation NNScript
@synthesize source;
@synthesize script;
@synthesize descriptor;

- (void) createNewNoteWithTitle:(NSString *)title WithBody:(NSString *)body {
    NSDictionary *errorDict;
    
    source = [NSString stringWithFormat:
              @"tell application \"Notes\"\n\
              activate\n\
              set noteTitle to \"%@\"\n\
              set noteBody to \"%@\"\n\
              tell account 1\n\
              make new note at folder \"Notes\" with properties {name:noteTitle,body:noteBody}\n\
              end tell\n\
              end tell", title, body];
    script = [[NSAppleScript alloc] initWithSource:source];
    
    descriptor = [script executeAndReturnError:&errorDict];
    
    if (descriptor != NULL)
    {
        // successful execution
        if (kAENullEvent != [descriptor descriptorType])
        {
            // script returned an AppleScript result
            if (cAEList == [descriptor descriptorType])
            {
                PBLOGF(@"List of decriptors :%@",descriptor);
            }
            else
            {
                PBLOGF(@"Result :%@",descriptor);
            }
        }
    }
    else
    {
        PBLOGF(@"Error ? %@",descriptor);
    }
}

- (void) createNewReminderWithTitle:(NSString *)title WithObjects:(NSArray *)list {
    NSDictionary *errorDict;
    
    NSMutableString *theList = [NSMutableString stringWithString:@"{"];
    
    for (NSDictionary *reminder in list) {
        NSString *checked;
        NSNumber *checkedNum = [reminder valueForKey:@"checked"];
        if ([checkedNum boolValue]) {
            checked = @"true";
        } else {
            checked = @"false";
        }
        if (reminder == list.lastObject)
        [theList appendString:[NSString stringWithFormat:@"{\"%@\",%@}",[reminder valueForKey:@"text"], checked]];
        else [theList appendString:[NSString stringWithFormat:@"{\"%@\",%@},",[reminder valueForKey:@"text"], checked]];
    }
    [theList appendString:@"}"];
    
    source = [NSString stringWithFormat:
              @"tell application \"Reminders\"\n\
              activate\n\
              set listName to \"%@\"\n\
              set theReminders to %@\n\
              set theList to make new list with properties {name:listName}\n\
              repeat with theItem in theReminders\n\
              set remName to item 1 of theItem\n\
              set checkedState to item 2 of theItem\n\
              tell theList\n\
              set theReminder to make new reminder with properties {name:remName}\n\
              set name of theReminder to item 1 of theItem\n\
              if item 2 of theItem equals true then set completed of theReminder to true\n\
              end tell\n\
              end repeat\n\
              show theList\n\
              end tell", title, theList];
    script = [[NSAppleScript alloc] initWithSource:source];
    
    descriptor = [script executeAndReturnError:&errorDict];
    
    if (descriptor != NULL)
    {
        // successful execution
        if (kAENullEvent != [descriptor descriptorType])
        {
            // script returned an AppleScript result
            if (cAEList == [descriptor descriptorType])
            {
                PBLOGF(@"List of decriptors :%@",descriptor);
            }
            else
            {
                PBLOGF(@"Result :%@",descriptor);
            }
        }
    }
    else
    {
        PBLOGF(@"Error ? %@",descriptor);
    }
}

@end