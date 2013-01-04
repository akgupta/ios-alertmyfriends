//
//  ContactsViewController.m
//  RX
//
//  Created by Akhilesh Gupta on 12/31/12.
//  Copyright (c) 2012 Akhilesh Gupta. All rights reserved.
//

#import "ContactsViewController.h"
#import "Contact.h"

@interface ContactsViewController ()

@end

@implementation ContactsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;
@synthesize selectedContacts = _selectedContacts;
@synthesize addButton = _addButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        NSLog(@"%@", @"Shake");
        // reverse geocode and send as text message
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setAllowsSelection:NO];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = _addButton;
    
    // Fetch selected contacts
    [self fetch];
    
    // Location
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
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
    
    Contact *contact = (Contact *)[_selectedContacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [contact name];
    cell.detailTextLabel.text = [contact phone];
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object at the given index path.
        [_managedObjectContext deleteObject:[_selectedContacts objectAtIndex:indexPath.row]];
        // Update the array and table view.
        [_selectedContacts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        // Commit the change.
        NSError *error = nil;
        if (![_managedObjectContext save:&error]) {
            // Handle the error.
        }
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
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return  YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
    CFStringRef name = ABRecordCopyCompositeName(person);
    NSString *displayName = (__bridge NSString *)name;
    CFStringRef phone = ABMultiValueCopyValueAtIndex(multi, identifier);
    NSString *phoneString = (__bridge NSString *) phone;
    [self addContactWithName:displayName phone:phoneString];
    CFRelease(name);
    CFRelease(phone);
    CFRelease(multi);
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:NULL];
    return NO;
}

#pragma mark - handlers
- (void)addItem:sender
{
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    // Display only a person's phone
    NSArray *displayedItems = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    picker.displayedProperties = displayedItems;
    // Show the picker
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - CoreData
- (void)addContactWithName:(NSString *)name phone:(NSString *)phone
{
    Contact *contact = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:_managedObjectContext];
    [contact setName:name];
    [contact setPhone:phone];
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        // Handle the error.
    }
    [_selectedContacts addObject:contact];
}

- (void)fetch {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    [self setSelectedContacts:mutableFetchResults];
}

@end
