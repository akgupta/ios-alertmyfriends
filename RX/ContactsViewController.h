//
//  ContactsViewController.h
//  RX
//
//  Created by Akhilesh Gupta on 12/31/12.
//  Copyright (c) 2012 Akhilesh Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactsViewController : UITableViewController <CLLocationManagerDelegate, ABPeoplePickerNavigationControllerDelegate> {
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
    NSMutableArray *_selectedContacts;
    UIBarButtonItem *_addButton;
}

@end
