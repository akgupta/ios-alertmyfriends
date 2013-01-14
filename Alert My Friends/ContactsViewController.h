//
//  ContactsViewController.h
//  Alert My Friends
//
//  Created by Akhilesh Gupta on 12/31/12.
//  Copyright (c) 2012 Akhilesh Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface ContactsViewController : UITableViewController <CLLocationManagerDelegate, ABPeoplePickerNavigationControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) CLGeocoder *geoCoder;

@end
