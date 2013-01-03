//
//  ContactsViewController.m
//  RX
//
//  Created by Akhilesh Gupta on 12/31/12.
//  Copyright (c) 2012 Akhilesh Gupta. All rights reserved.
//

#import "ContactsViewController.h"

@interface ContactsViewController ()

@end

@implementation ContactsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setAllowsSelection:NO];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = _addButton;
    
    // Selected contacts array
    NSDictionary *A = [NSDictionary dictionaryWithObjectsAndKeys:@"A",@"name",@"6508041611",@"phone",nil];
    NSDictionary *B = [NSDictionary dictionaryWithObjectsAndKeys:@"B",@"name",@"6508041612",@"phone",nil];
    NSDictionary *C = [NSDictionary dictionaryWithObjectsAndKeys:@"C",@"name",@"6508041613",@"phone",nil];
    _selectedContacts = [[NSMutableArray alloc] initWithObjects:A,B,C,nil];
    
    // Location
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
    if (editing) {
        _addButton.enabled = NO;
    } else {
        _addButton.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_selectedContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *contact = [_selectedContacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [contact valueForKey:@"name"];
    cell.detailTextLabel.text = [contact valueForKey:@"phone"];
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_selectedContacts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location:lat:%f,lon:%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    //if we get a location less than 2 minutes old, stop updating location
    if ( abs([newLocation.timestamp timeIntervalSinceDate: [NSDate date]]) < 120) {
        [_locationManager stopUpdatingLocation];
    }
    _currentLocation = newLocation;
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return  YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
    CFStringRef name = ABRecordCopyCompositeName(person);
    NSString *displayName = (__bridge NSString *)name;
    CFStringRef phone = ABMultiValueCopyValueAtIndex(multi, identifier);
    NSString *phoneString = (__bridge NSString *) phone;
    NSDictionary *newContact = [NSDictionary dictionaryWithObjectsAndKeys:displayName,@"name",phoneString,@"phone",nil];
    [_selectedContacts addObject:newContact];
    CFRelease(name);
    CFRelease(phone);
    CFRelease(multi);
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:NULL];
    return NO;
}

#pragma mark - handlers
- (void)addItem:sender {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    // Display only a person's phone
    NSArray *displayedItems = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    picker.displayedProperties = displayedItems;
    // Show the picker
    [self presentViewController:picker animated:YES completion:NULL];
}

@end
