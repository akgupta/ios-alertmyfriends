//
//  AppDelegate.h
//  Alert My Friends
//
//  Created by Akhilesh Gupta on 12/31/12.
//  Copyright (c) 2012 Akhilesh Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@class ContactsViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ContactsViewController *contactsViewController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
