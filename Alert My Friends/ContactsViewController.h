//
//  ContactsViewController.h
//  Alert My Friends
//
//  Created by Akhilesh Gupta on 12/31/12.
//  Copyright (c) 2012 Akhilesh Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactsViewController : UITableViewController <ABPeoplePickerNavigationControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) UIBarButtonItem *addButton;

- (void)fetch;

@end
