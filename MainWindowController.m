//
//  MainWindowController.m
//  Pushbullet
//
//  Created by Gaël PHILIPPE on 12/02/2015.
//  Copyright (c) 2015 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainWindowController.h"
#import "PBDelegate.h"
#import "Pushbullet.h"
#import "Node.h"


@implementation PBMainWindowController
@synthesize _delegate;

#pragma mark -
#pragma mark AppDelegate relation funcs
//TODO: Find a way to not need this
- (void) setDelegate:(id)delegate {
    _delegate = delegate;
}

- (id) delegate {
    return _delegate;
}

- (void) removeDelegate {
    _delegate = nil;
}

#pragma mark -
#pragma mark init funcs

static PBMainWindowController * sharedWindowController = nil;

+ (instancetype) sharedWindowController {
    @synchronized(sharedWindowController) {
        if (!sharedWindowController) {
            sharedWindowController = [[PBMainWindowController alloc] initWithWindowNibName:@"MainMenu"];
        }
        return sharedWindowController;
    }
}

-(void) awakeFromNib {
    
    [_mainWindow setTitleVisibility:NSWindowTitleHidden];
    [_mainWindow setDelegate:self];
    
    [self populateRecipientsArray];
    
    [self populateThePushTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPushToTable:) name:PBTableAddItemNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldRemovePush:) name:PBTableRemoveItemNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outlineViewSelectionChanged:) name:NSOutlineViewSelectionDidChangeNotification object:self->_recipientsOutlineView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRecipient:) name:@"PBRemoveDevice" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOneItem:) name:@"PBTableShowOneItem" object:nil];
    
    [_mainWindow orderFrontRegardless];
    [_mainWindow makeKeyWindow];
    
    //[self.pushesArrayController setFilterPredicate:[self defaultPredicate]];
    //[self filterPushTableWithPredicate:[self defaultPredicate]];
}

#pragma mark -
#pragma mark Initial Population funcs
- (void)populateRecipientsArray {
    
    if ([_delegate recipients] == nil) [_delegate setRecipients:[[NSMutableArray alloc] initWithCapacity:4]];
    
    if (self.userDefaultsController == nil) {
        self.userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    }
    
    NSArray * devices = [[self.userDefaultsController defaults] valueForKey:@"devices"];
    NSArray * subscriptions = [[self.userDefaultsController defaults] valueForKey:@"subscriptions"];
    NSArray * contacts = [[self.userDefaultsController defaults] valueForKey:@"contacts"];
    
    if ([self recipientsArray] == nil) {
        [self setRecipientsArray:[NSMutableArray array]];
    }
    [[self recipientsArray] addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"All", @"name", [NSNumber numberWithInt:1], @"active", nil]];
    [[self recipientsArray] addObjectsFromArray:devices];
    [[self recipientsArray] addObjectsFromArray:contacts];
    
    if ([self recipientsArrayController] == nil) {
        self.recipientsArrayController = [[NSArrayController alloc] init];
    }
    
    [[self recipientsArrayController] setContent:[self recipientsArray]];
    [[self recipientsArrayController] setFilterPredicate:[self defaultPredicate]];
    
    [_recipientsTreeController setContent:[_delegate recipients]];
    [_recipientsTreeController setChildrenKeyPath:@"children"];
    [_recipientsTreeController setLeafKeyPath:@"isLeaf"];
    
    [_recipientsTreeController setSortDescriptors:[self defaultOutlineSortDescriptor]];
    
    Node * allNode = [Node nodeWithTitle:@"All" isLeaf:YES];
    [allNode setType:kPBAllNode];
    [_recipientsTreeController insertObject:allNode atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:kPBAllNode]];
    
    //Populate the Recipients Tree, for display on Outline view
    Node * devicesNode = [Node nodeWithTitle:@"Devices" isLeaf:NO];
    [devicesNode setType:kPBDeviceNode];
    for (NSDictionary * device in devices) {
        if ([[device valueForKey:kPBActiveKey] boolValue] == YES) {
            Node * deviceNode = [Node nodeWithTitle:[device valueForKey:kPBNicknameKey] isLeaf:YES];
            [deviceNode setIden:[device valueForKey:kPBIdenKey]];
            [deviceNode setType:kPBDeviceNode];
            [deviceNode setParent:devicesNode];
            [deviceNode setActive:[[device valueForKey:kPBActiveKey] boolValue]];
            [devicesNode addChild:deviceNode];
        }
    }
    
    __block NSIndexPath * path = [NSIndexPath indexPathWithIndex:[[[self recipientsTreeController] arrangedObjects] count]];
    [[self recipientsOutlineView] beginUpdates];
    [_recipientsTreeController insertObject:devicesNode atArrangedObjectIndexPath:path];
    [_recipientsOutlineView expandItem:[_recipientsOutlineView itemAtRow:1]];
    [[self recipientsOutlineView] endUpdates];
    
    //Populate the Recipients Tree
    Node * subscriptionsNode = [Node nodeWithTitle:@"Subscriptions" isLeaf:NO];
    [subscriptionsNode setType:kPBSubscriptionNode];
    for (NSDictionary * subscription in subscriptions) {
        if ([[subscription valueForKey:kPBActiveKey] boolValue] == YES) {
            NSDictionary * channel = [subscription valueForKey:@"channel"];
            Node * subscriptionNode = [Node nodeWithTitle:[channel valueForKey:kPBNameKey] isLeaf:YES];
            [subscriptionNode setParent:subscriptionsNode];
            [subscriptionNode setType:kPBSubscriptionNode];
            [subscriptionNode setIden:[channel valueForKey:kPBIdenKey]];
            [subscriptionNode setActive:[[subscription valueForKey:kPBActiveKey] boolValue]];
            [subscriptionsNode addChild:subscriptionNode];
        }
    }
    
    [[self recipientsOutlineView] beginUpdates];
    path = [NSIndexPath indexPathWithIndex:[[_recipientsTreeController arrangedObjects] count]];
    [_recipientsTreeController insertObject:subscriptionsNode atArrangedObjectIndexPath:path];
    [[self recipientsOutlineView] endUpdates];
    
    //Populate the Recipients Tree
    Node * contactsNode = [Node nodeWithTitle:@"Contacts" isLeaf:NO];
    [contactsNode setType:kPBContactsNode];
    
    for (NSDictionary * contact in contacts) {
        Node * contactNode = [Node nodeWithTitle:[contact valueForKey:kPBNameKey] isLeaf:YES];
        [contactNode setIden:[contact valueForKey:kPBIdenKey]];
        [contactNode setParent:contactsNode];
        [contactNode setType:kPBContactsNode];
        [contactNode setActive:[[contact valueForKey:kPBActiveKey] boolValue]];
        [contactsNode addChild:contactNode];;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[self recipientsOutlineView] beginUpdates];
        path = [NSIndexPath indexPathWithIndex:[[self->_recipientsTreeController arrangedObjects] count]];
        [self->_recipientsTreeController insertObject:contactsNode atArrangedObjectIndexPath:path];
        [[self recipientsOutlineView] endUpdates];
        
        
        //[self->_recipientsOutlineView reloadData];
    });
    
    //Have "All" line selected by default
    [_recipientsOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:YES];
    
}


-(void) populateThePushTable {
    if (self.userDefaultsController == nil) {
        _userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    }
    
    NSMutableArray * pushes =  [[[self.userDefaultsController defaults] valueForKey:@"pushes"] mutableCopy];
    
    //prepare the array Controller
    if (self.pushesArrayController == nil) {
        self.pushesArrayController = [[NSArrayController alloc] init];
    }
    
    [self.pushesArrayController setContent:pushes];
    
    //prepare the pushesTable's dataSource, this should be self.
    if (self.dataSource == nil) {
        self.dataSource = [[PBTableViewDataSource alloc] init];
        
        [self.dataSource setContent:pushes];
        [self.dataSource setArrayController:self.pushesArrayController];
        [self.pushesTable setDataSource:self.dataSource];
        
    }
    
    [self.pushesArrayController setFilterPredicate:[self defaultPredicate]];
    [self.pushesArrayController setSortDescriptors:[self defaultPushSortDescriptor]];
    [self.pushesArrayController rearrangeObjects];
    
    NSIndexSet * indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.pushesArrayController.arrangedObjects count] - 1)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pushesTable beginUpdates];
        [self.pushesTable insertRowsAtIndexes:indexes withAnimation:NSTableViewAnimationEffectNone];
        
        [self.pushesTable endUpdates];
    });
    
}

#pragma mark -

-(void) updateRecipientsTree:(NSNotification *) notification {
    NSDictionary * newDevices = [notification object];
    
    //Populate the Recipients Tree, for display on Outline view
    Node * devicesNode = [Node nodeWithTitle:@"Devices" isLeaf:NO];
    [devicesNode setType:kPBDeviceNode];
    for (NSDictionary * device in newDevices) {
        if ([[device valueForKey:kPBActiveKey] boolValue] == YES) {
            Node * deviceNode = [Node nodeWithTitle:[device valueForKey:kPBNicknameKey] isLeaf:YES];
            [deviceNode setIden:[device valueForKey:kPBIdenKey]];
            [deviceNode setType:kPBDeviceNode];
            [deviceNode setParent:devicesNode];
            [deviceNode setActive:[[device valueForKey:kPBActiveKey] boolValue]];
            [devicesNode addChild:deviceNode];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self recipientsOutlineView] beginUpdates];
        [[self recipientsTreeController] removeObjectAtArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:kPBDeviceNode]];
        [[self recipientsTreeController] insertObject:devicesNode atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:kPBDeviceNode]];
        [[self recipientsTreeController] rearrangeObjects];
        [[self recipientsOutlineView] expandItem:devicesNode];
        [[self recipientsOutlineView] endUpdates];
    });
}

#pragma mark -
#pragma mark Sorting/Filtering functions

/* We only want to see the active pushes */
-(NSPredicate *)defaultPredicate {
    /*return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [[((NSDictionary *)evaluatedObject) valueForKey:kPBActiveKey] boolValue];
    }];*/
    return [NSPredicate predicateWithFormat:@"SELF.active == YES"];
}

//TODO: add descending sorting ?
-(NSArray *)defaultPushSortDescriptor {
    NSSortDescriptor * modifiedDesc = [NSSortDescriptor sortDescriptorWithKey:kPBModifiedKey ascending:NO];
    return [NSArray arrayWithObject:modifiedDesc];
}

-(NSArray *)defaultOutlineSortDescriptor {
    NSSortDescriptor * recipientArraySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kPBTypeKey ascending:YES];
    return [NSArray arrayWithObject:recipientArraySortDescriptor];
}


- (NSPredicate *)predicateForNode:(id)item {
    Node * node = item;
    NSPredicate * resultPredicate = nil;
    
    if ([node type] == kPBDeviceNode) {
        resultPredicate = [NSPredicate predicateWithFormat:@"(SELF.target_device_iden == nil) || (SELF.target_device_iden == %@)", [node iden]];
    }
    
    if ([node type] == kPBSubscriptionNode) {
        /*resultPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            
            return [[evaluatedObject valueForKey:kPBChannelIdenKey] isEqualTo:[node iden]];
        }];*/
        resultPredicate = [NSPredicate predicateWithFormat:@"SELF.channel_iden == %@", [node iden]];
    }
    
    if ([node type] == kPBContactsNode) {
        /*resultPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            
            return ([evaluatedObject valueForKey:@"sender_name"] == [node title]);
        }];*/
        resultPredicate = [NSPredicate predicateWithFormat:@"SELF.sender_name == %@", [node title]];
    }
    
    return resultPredicate;
}

- (NSPredicate *)predicateForType:(NSString *)type {
    if (type == nil) return nil;
    /*return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        BOOL result = NO;
        NSString * evaluatedType = [evaluatedObject valueForKey:kPBTypeKey];
        result = [evaluatedType isEqualToString:type];
        return  result;
    }];*/
    
    return [NSPredicate predicateWithFormat:@"SELF.type == %@", type];
}

- (NSString *) pushTypeForSegmentedSelection:(NSUInteger)selectionIndex {
    switch (selectionIndex) {
        case 0:
            return nil;
            break;
            
        case 1:
            return kPBNoteType;
            break;
            
        case 2:
            return kPBLinkType;
            break;
            
        case 3:
            return kPBListType;
            break;
            
        case 4:
            return kPBAddressType;
            break;
            
        case 5:
            return kPBFileType;
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSPredicate *) computePredicate {
    NSPredicate  *newSegmentPredicate, *newRecipientPredicate;
    NSInteger selectedOutlineRow = [self.recipientsOutlineView selectedRow];
    NSInteger selectedSegment = [self.segmentedToolBarItem selectedSegment];
    
    newSegmentPredicate = [self predicateForType:[self pushTypeForSegmentedSelection:selectedSegment]];
    newRecipientPredicate = [self predicateForNode:[[self.recipientsOutlineView itemAtRow:selectedOutlineRow] representedObject]];
    
    if ((newSegmentPredicate != nil) || (newRecipientPredicate != nil)) {
        
        if ((newSegmentPredicate != nil) && (newRecipientPredicate == nil)) {
            return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:[NSArray arrayWithObjects:[self defaultPredicate], newSegmentPredicate, nil]];
        }
        
        if ((newSegmentPredicate == nil) && (newRecipientPredicate != nil)) {
            return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:[NSArray arrayWithObjects:[self defaultPredicate], newRecipientPredicate, nil]];
        }
        
        return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:[NSArray arrayWithObjects:[self defaultPredicate], newRecipientPredicate, newSegmentPredicate, nil]];
        
    } else {
        return [self defaultPredicate];
    }
    
    return nil;
}

- (BOOL) filterPushTableWithPredicate:(NSPredicate *)newPredicate {
    __block BOOL result = YES;
    
    NSLog(@"Predicate %@", [newPredicate predicateFormat] );
    
    //if ([newPredicate isEqualTo:[[self pushesArrayController] filterPredicate]]) return NO;
    
    /* The "remove" index set is calculated before rearrangment, to avoid corruption */
    __block NSMutableIndexSet * removeIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[self pushesTable] numberOfRows])];
    __block NSMutableIndexSet * addIndexes = [[NSMutableIndexSet alloc] init];
    
    [self.pushesArrayController setFilterPredicate:newPredicate];
    //[self.pushesArrayController rearrangeObjects];
    
    /* The "add" index set is calculated after rearrangement, to account for the changes */
    addIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[self.pushesArrayController arrangedObjects] count])];
    
    /* Enumerate all pushes to be displayed
     * Then all currently displayed pushes
     * if a push is in both lists, remove it from the "add" list
     * if a currently displayed push evaluates with the new predicate, remove it from the "remove" list*/
    [[self.pushesArrayController arrangedObjects] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [[self pushesTable] enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
            id push = [[self dataSource] tableView:[self pushesTable] objectValueForTableColumn:nil row:row];
            if ([newPredicate evaluateWithObject:push]) {
                [removeIndexes removeIndex:row];
                //PBLOGF(@"Adding index %ld to index %@", idx, addIndexes)
                //[addIndexes addIndex:idx];
            }
            if (push == obj) {
                [addIndexes removeIndex:idx];
            }
        }];
        *stop = result?NO:YES;
    }];
    
    if (result == NO) return result;
    
    //If there is something to change
    if (([removeIndexes count] > 0) || ([addIndexes count] > 0)) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pushesTable beginUpdates];
            
            if ([removeIndexes count] > 0) {
                
                [removeIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    if (idx >= [[self pushesTable] numberOfRows]) {
                        [removeIndexes removeIndex:idx];
                    }
                }];
                
                [self.pushesTable removeRowsAtIndexes:removeIndexes withAnimation:NSTableViewAnimationEffectFade];
            }
            
            if ([addIndexes count] > 0) {
                
                NSInteger numberOfItemsToShow = [[self.pushesArrayController arrangedObjects] count];
                NSInteger numberOfIndexesToAdd = [addIndexes count];
                //PBLOGF(@"Wants to insert rows at indexes %@ with current number of rows %ld", addIndexes, [self.pushesTable numberOfRows])
                if (numberOfIndexesToAdd > numberOfItemsToShow)
                [addIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    
                    if (idx > numberOfItemsToShow - 1)
                        [addIndexes removeIndex:idx];
                }];
                //PBLOGF(@"Inserting rows at indexes %@ with current number of rows %ld", addIndexes, [self.pushesTable numberOfRows])
                [self.pushesTable insertRowsAtIndexes:addIndexes withAnimation:NSTableViewAnimationEffectFade];
                
            }
            [self.pushesTable endUpdates];
        });
        
    }
    
    /* 
     * We are showing one item, remove the height constraint of the first view
     */
    if ([self isShowingOneItem] == YES) {
        if ([self.oneItemTable dataSource] == nil) {
            [self.oneItemTable setDataSource:self.dataSource];
        }
        NSUInteger index = [[self.pushesArrayController arrangedObjects] indexOfObject:[[self.pushesArrayController arrangedObjects] firstObject]];
        [self.oneItemTable insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationEffectNone];
        [[self.pushesScrollView animator] setHidden:YES];
        [[self.oneItemScrollView animator] setHidden:NO];
    } else {
        if ([self.pushesScrollView isHidden] == YES) {
            [[self.pushesScrollView animator] setHidden:NO];
            [[self.oneItemScrollView animator] setHidden:YES];
            [self.oneItemTable removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationEffectNone];
        }
    }
    
    return result;
}

- (IBAction)searchPushesTable:(id)sender {
    NSString * wildcardedSearchString = @"*";
    NSString * searchString = [[self searchField] stringValue];
    
    if ((searchString == nil) || [searchString isEqualTo:@""]) {
        [self filterPushTableWithPredicate:[self computePredicate]];
        return;
    }
    
    NSPredicate * searchPredicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary * evaluatedPush, NSDictionary *bindings) {
        BOOL shouldShow = NO;
        //enumerate all keys in push
        for (NSString * key in evaluatedPush) {
            //only evaluate the strings
            if ([[evaluatedPush valueForKey:key] isKindOfClass:[NSString class]]) {
                NSString * expr = [wildcardedSearchString stringByAppendingString:[searchString stringByAppendingString:@"*"]];
                NSPredicate * pred = [NSPredicate predicateWithFormat:@"%K LIKE[cd] %@", key, [expr lowercaseString]];;
                shouldShow = [pred evaluateWithObject:evaluatedPush];
                if (shouldShow == YES) {
                    //NSLog(@"Found a matching push : title = %@ : matching key : %@", [evaluatedPush valueForKey:kPBTitleKey], key);
                    break;
                }
            }
        }
        return shouldShow;
    }];
    
    [self filterPushTableWithPredicate:searchPredicate];
}

- (IBAction) segmentedControlClicked:(id)sender {
    [self setIsShowingOneItem:NO];
    [self filterPushTableWithPredicate:[self computePredicate]];
}

- (void)outlineViewSelectionChanged:(NSNotification *)notification {
    if ([[self recipientsOutlineView] selectedRow] < 0) {
        return;
    }
    [self setIsShowingOneItem:NO];
    //TODO: we need to figure something better, to allow selection while editing, but prevent selection while removing
    if ([self.recipientsOutlineView editSessionOnGoing] == YES) {
        return;
    }
    NSInteger selectedRow = [[self recipientsOutlineView] selectedRow];
    if ((selectedRow < [[self recipientsOutlineView] numberOfRows]) && (selectedRow >= 0)) {
        if ([[self.pushesArrayController filterPredicate] isNotEqualTo:[self computePredicate]])
            [self filterPushTableWithPredicate:[self computePredicate]];
    }
}

- (void) showOneItem:(NSNotification *)notification {
    if (self.isShowingOneItem == YES)
        return;
    
    [self setIsShowingOneItem:YES];
    [[self recipientsOutlineView] deselectAll:self];
    
    [self filterPushTableWithPredicate:[NSPredicate predicateWithFormat:@"SELF == %@ && SELF.active == YES", [notification object]]];
}

#pragma mark -
#pragma mark Insertion/Removal
//TODO: rename to shouldInsertPush
//TODO: add Single an Batch Push Insertion
- (void) addPushToTable:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * push = [notification object];
        [self.pushesTable beginUpdates];
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:0];
        [self.pushesTable insertRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationSlideDown];
        [self.pushesArrayController insertObject:push atArrangedObjectIndex:0];
        [self.pushesTable endUpdates];
        [self filterPushTableWithPredicate:[self computePredicate]];
    });
}

- (void) shouldRemovePush:(NSNotification *)notification {
    NSInteger index = [[notification object] integerValue];
    
    [self removePushesAtArrangedIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void) removePushesAtArrangedIndexes:(NSIndexSet *)indexes {
    
    //Start removing things frome th view
    [[self pushesTable] beginUpdates];
    [[self pushesTable] removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationEffectFade];
    [[self pushesTable] endUpdates];
    
    //enumerate pushes and request push deletion
    NSMutableArray * removeArray = [[NSMutableArray alloc] init];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        
        NSArray * thePushes = [[self pushesArrayController] arrangedObjects];
        NSDictionary * pushDict = [thePushes objectAtIndex:index];
        
        [removeArray addObject:pushDict];
    }];
    
    
    if ([removeArray count] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            PBDelegate * delegate = (PBDelegate *)[self _delegate];
            NSNotification * notification = [NSNotification notificationWithName:@"PBRemovePushFromServer" object:self userInfo:[NSDictionary dictionaryWithObject:removeArray forKey:@"array"]];
            [delegate shouldRemovePushFromServer:notification];
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"PBRemovePushFromServer" object:self userInfo:[NSDictionary dictionaryWithObject:removeArray forKey:@"array"]];
        });
    }
    
    //Remove from in-memory array
    [[self pushesArrayController] removeObjectsAtArrangedObjectIndexes:indexes];
    
    //This should go to PBDelegate
    //Remove from the on-disk database
    NSUserDefaults * storage = [[self userDefaultsController] defaults];
    [storage setValue:[[self pushesArrayController] content] forKey:@"pushes"];
    [storage synchronize];
}

#pragma mark -
#pragma mark Recipients Removal
//TODO: On-the-fly insertion ?

- (void)sheetDidEndShouldDelete: (NSWindow *)sheet
                     returnCode: (NSInteger)returnCode
                    contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn) {
        PBLOGF(@"Removing Source. Info : %@", contextInfo);
        
        //figure out indexes and index paths
        Node * node = (__bridge Node *)contextInfo;
        NSUInteger NodeIndex = [[[node parent] children] indexOfObject:node];
        NSUInteger ParentIndex = [[[self recipientsTreeController] content] indexOfObject:[node parent]] + 1;
        
        NSIndexPath * nodeIndexPath = [NSIndexPath indexPathWithIndex:ParentIndex];
        nodeIndexPath = [nodeIndexPath indexPathByAddingIndex:NodeIndex];
        
        //remove observers for the view
        PBLOGF(@"Removing observers for item at index path : %@", nodeIndexPath);
        PBOutlineViewCellItem * view = (PBOutlineViewCellItem*)[[self recipientsOutlineView] viewForItem:node];
        [[NSNotificationCenter defaultCenter] removeObserver:view];
        
        //remove observers for the parents
        [[self recipientsOutlineView] enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
            [[rowView subviews] enumerateObjectsUsingBlock:^(NSView * view, NSUInteger idx, BOOL *stop) {
                if ([view isKindOfClass:[PBOutlineViewCellHeader class]]) {
                    PBLOGF(@"Temporarily remove observers for header at index %li", idx);
                    [view removeObserver:view forKeyPath:@"visibleRect"];
                }
            }];
        }];
        
        //Start updating data
        [[self recipientsOutlineView] beginUpdates];
        
        PBLOGF(@"Removing source from View with index : %ld", NodeIndex);
        [[self recipientsOutlineView] removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:NodeIndex] inParent:[node parent] withAnimation:NSTableViewAnimationEffectFade];
        
        PBLOGF(@"Removing source from Tree with index path : %@", nodeIndexPath);
        [[self recipientsTreeController] removeObjectAtArrangedObjectIndexPath:nodeIndexPath];
        
        //TODO: Activate removal
        NSPredicate * removalPredicate = [NSPredicate predicateWithFormat:@"(SELF.target_device_iden == %@) OR (SELF.sender_iden == %@)", node.iden, node.iden];
        
        //prevent the eradication of all data
        if ([removalPredicate isNotEqualTo:[self defaultPredicate]]) {
            //remove objects in the table
            NSMutableIndexSet * removeIndexes = [NSMutableIndexSet indexSet];
            
            [[[self pushesArrayController] arrangedObjects] enumerateObjectsUsingBlock:^(NSDictionary * push, NSUInteger idx, BOOL *stop) {
                BOOL isValid = [removalPredicate evaluateWithObject:push];
                if (isValid) {
                    [removeIndexes addIndex:idx];
                }
            }];
            PBLOGF(@"Removing pushes from View at indexes : %@", removeIndexes);
            [self removePushesAtArrangedIndexes:removeIndexes];
            
            //remove objects not shown on the table
            NSMutableArray * removeArray = [NSMutableArray array];
            removeIndexes = [NSMutableIndexSet indexSet];
            
            [[[self pushesArrayController] content] enumerateObjectsUsingBlock:^(NSDictionary * push, NSUInteger idx, BOOL *stop) {
                BOOL isValid = [removalPredicate evaluateWithObject:push];
                if (isValid) {
                    [removeArray addObject:push];
                    [removeIndexes addIndex:idx];
                }
            }];
            
            PBLOGF(@"Removing pushes from Array at indexes : %@", removeIndexes);
            [[self pushesArrayController] removeObjects:removeArray];
        }
        
        [[self recipientsOutlineView] endUpdates];
        
        //readd the observer for the parent view
        [[self recipientsOutlineView] enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
            [[rowView subviews] enumerateObjectsUsingBlock:^(NSView * view, NSUInteger idx, BOOL *stop) {
                if ([view isKindOfClass:[PBOutlineViewCellHeader class]]) {
                    PBLOGF(@"Readd observers for header at index %ld", idx);
                    [view addObserver:view forKeyPath:@"visibleRect" options:0 context:nil];
                }
            }];
        }];
        
        //Posting a notification for the AppDelegate to send deletion requests to the server
        //TODO: implement actual removal
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:[NSNumber numberWithInteger:[node type]] forKey:@"type"];
        [userInfo setObject:node forKey:@"object"];
        
        PBLOG(@"Posting PBRemoveRecipientFromServer notification");
        PBDelegate * delegate = (PBDelegate *)[self _delegate];
        NSNotification * notification = [NSNotification notificationWithName:@"PBRemoveRecipientFromServer" object:self userInfo:userInfo];
        [delegate shouldRemoveSourceFromServer:notification];
        //[[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void) removeRecipient:(NSNotification *) notification {
    Node * node = [notification object];
    
    //TODO: This should go in a dedicate Node class function
    NSString * typeOfRemoval;
    if (node.type == kPBDeviceNode) {
        typeOfRemoval = @"device";
    }
    if (node.type == kPBContactsNode) {
        typeOfRemoval = @"contact";
    }
    if (node.type == kPBSubscriptionNode) {
        typeOfRemoval = @"subscription";
    }
    
    {
        NSBeginAlertSheet(
                          [NSString stringWithFormat:@"Do you really want to remove the selected %@?", typeOfRemoval], // sheet message
                          @"Delete",              // default button label
                          nil,                    // no third button
                          @"Cancel",              // other button label
                          _mainWindow,                 // window sheet is attached to
                          self,                   // we’ll be our own delegate
                          @selector(sheetDidEndShouldDelete:returnCode:contextInfo:), // did-end selector
                          NULL,                   // no need for did-dismiss selector
                          (__bridge void *)(node),                 // context info
                          @"There is no undo for this operation."); // additional text
        
        return;
    }
}

#pragma mark -
#pragma mark CreatePush Sheet

- (void) setRecipientForPush:(PBPush *)PBPush {
    NSInteger selectedRecipient = [self->_pushSheetRecpipientButton indexOfSelectedItem];
    NSDictionary *recipient = [[self->_recipientsArrayController arrangedObjects] objectAtIndex:selectedRecipient];
    if ([recipient valueForKey:@"email"]) {
        PBPush.email = [recipient valueForKey:@"email"];
        return;
    }
    if ([recipient valueForKey:@"nickname"]) {
        PBPush.device_iden = [recipient valueForKey:@"iden"];
        return;
    }
    return;
}

- (IBAction)showCreatePushMenu:(id)sender {
    [[self createPushButton] setMenu:[self createPushMenu]];
    NSEvent * currentEvent = [NSApp currentEvent];
    
    NSRect buttonFrame = [[self createPushButton] frame];
    NSPoint locFromView = [[self createPushButton] convertPoint:buttonFrame.origin toView:_mainWindow.contentView];
    locFromView.y = locFromView.y - buttonFrame.size.height + 2;
    locFromView.x -= 5;
    
    NSEvent * event = [NSEvent mouseEventWithType:currentEvent.type location:locFromView modifierFlags:currentEvent.modifierFlags timestamp:[NSDate timeIntervalSinceReferenceDate] windowNumber:currentEvent.windowNumber context:currentEvent.context eventNumber:currentEvent.eventNumber clickCount:currentEvent.clickCount pressure:currentEvent.pressure];
    [NSMenu popUpContextMenu:[self createPushMenu] withEvent:event forView:[self createPushButton]];
}

- (void) initTextView:(NSTextView *)textWiew {
    [textWiew setFont:[NSFont fontWithName:@"Helvetica Neue" size:13]];
    [textWiew setTextContainerInset:NSMakeSize(0, 4)];
    [[textWiew textContainer] setLineFragmentPadding:0];
}

- (void) initTextViews:(NSArray *)array {
    [array enumerateObjectsUsingBlock:^(NSTextView * textView, NSUInteger idx, BOOL *stop) {
        if ([textView isKindOfClass:[NSTextView class]]) {
            [self initTextView:textView];
        } else {
            PBLOGF(@"Object %@ is not an NSTextField", textView)
        }
    }];
}

- (NSString *) PBPushTypeForMenuTag:(NSInteger)tag {
    switch (tag) {
        case 0:
            return kPBNoteType;
            break;
            
        case 1:
            return kPBLinkType;
            break;
        
        default:
            return kPBLinkType;
            break;
    }
}

//TODO: Add support for sendind either Lists, Addresses, Files ...
- (IBAction) showCreatePushSheet:(id)sender {
    __block NSInteger selectedType = [((NSMenuItem *)sender) tag];
    [[self pushSheetTabView] selectTabViewItemAtIndex:selectedType];
    
    [self initTextViews:[NSArray arrayWithObjects:[self pushSheetLinkBodyTextField], [self pushSheetNoteBodyTextField], nil]];
    
    [[self mainWindow] beginSheet:[self createPushSheet] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            
            PBPush * Ppush = [[PBPush alloc] init];
            
            Ppush.type = [self PBPushTypeForMenuTag:selectedType];
            
            [self setRecipientForPush:Ppush];
            
            if ([[self->_pushSheetUrlTextField stringValue] isNotEqualTo:@""])
                Ppush.url = [self->_pushSheetUrlTextField stringValue];
            
            if ([[self->_pushSheetTitleTextField stringValue] isNotEqualTo:@""])
                Ppush.title = [self->_pushSheetTitleTextField stringValue];
            
            if ([[self->_pushSheetNoteBodyTextField string] isNotEqualTo:@""])
                Ppush.body = [[self->_pushSheetNoteBodyTextField textStorage] string];
            if ([[self->_pushSheetLinkBodyTextField string] isNotEqualTo:@""])
                Ppush.body = [[self->_pushSheetLinkBodyTextField textStorage] string];
            
            [[PBPushController sharedPushController] push:Ppush];
            
        }
        
        self->_pushSheetTitleTextField.stringValue = self->_pushSheetUrlTextField.stringValue = self->_pushSheetNoteBodyTextField.string = self->_pushSheetLinkBodyTextField.string = @"";
        self->_pushSheetTitleTextField.placeholderString = @"Title";
        
        [self->_pushSheetRecpipientButton selectItemAtIndex:0];
        
        [[self createPushSheet] close];
    }];
}

- (IBAction) closeCreatePushSheet:(id)sender {
    [[self mainWindow] endSheet:[self createPushSheet] returnCode:NSModalResponseCancel];
}

- (IBAction) sendPushAndCloseCreatePushSheet:(id)sender {
    [[self mainWindow] endSheet:[self createPushSheet] returnCode:NSModalResponseOK];
}


#pragma mark -
#pragma mark Utility funcs

//Fullscreen Options. Not really necessary
- (NSApplicationPresentationOptions) window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions {
    
    NSApplicationPresentationOptions options = NSApplicationPresentationFullScreen | NSApplicationPresentationDefault | NSApplicationPresentationAutoHideMenuBar | NSApplicationPresentationHideDock;
    
    return  options;
}

-(void) windowDidUpdate:(NSNotification *)notification {
    //NSInteger selectedRow = [self.recipientsOutlineView selectedRow];
    //PBLOGF(@"SelectedRow %ld | Showing One Item ? %hhd", selectedRow, [self isShowingOneItem])
    if (([self.recipientsOutlineView selectedRow] < 0) && ([self isShowingOneItem] == NO)) {
        [self.recipientsOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
}

#pragma mark -
#pragma mark textfield delegate methods
- (BOOL)textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
    
    if (commandSelector == @selector(insertNewline:))
    {
        // new line action:
        // always insert a line-break character and don’t cause the receiver to end editing
        [textView insertNewlineIgnoringFieldEditor:self];
        result = YES;
    }
    else if (commandSelector == @selector(insertTab:))
    {
        // tab action:
        // always insert a tab character and don’t cause the receiver to end editing
        [textView insertTabIgnoringFieldEditor:self];
        result = YES;
    }
    
    return result;
}


@end
