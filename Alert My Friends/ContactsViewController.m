//
//  ContactsViewController.m
//  Alert My Friends
//
//  Created by Akhilesh Gupta on 12/31/12.
//  Copyright (c) 2012 Akhilesh Gupta. All rights reserved.
//

#import "ContactsViewController.h"
#import "Contact.h"
#import "SettingsViewController.h"

@interface ContactsViewController ()

@end

@implementation ContactsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;
@synthesize currentAddress = _currentAddress;
@synthesize selectedContacts = _selectedContacts;
@synthesize addButton = _addButton;
@synthesize geoCoder = _geoCoder;
@synthesize player = _player;

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
        NSLog(@"INFO:%@", @"Shake");
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kShake]) {
            [self sendAlert];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"alert_my_friends", "text alert_my_friends")];
    
    [self.tableView setAllowsSelection:NO];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = _addButton;
    
    // Toolbar
    [self.navigationController setToolbarHidden:NO];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *alertButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"alert_button", "text alert_button") style:UIBarButtonItemStyleBordered target:self action:@selector(sendAlert)];
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [infoButton addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace, alertButton, flexibleSpace, infoBarButton, nil];
    
    // Fetch selected contacts
    [self fetch];
    
    // Location
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [_locationManager setDistanceFilter:100];
    [_locationManager startUpdatingLocation];
    _geoCoder = [[CLGeocoder alloc] init];
    
    // AV Player
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource: @"siren" ofType: @"wav"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
    [_player prepareToPlay];
    [_player setVolume:1.0];
    [_player setNumberOfLoops:2];
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
    [_player stop];
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
    if ([contact name] != nil) {
        cell.textLabel.text = [contact name];
        cell.detailTextLabel.text = [contact phone];
    } else {
        cell.textLabel.text = [contact phone];
    }
    
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
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    
    NSLog(@"INFO:Location:\n lat: %f\n lon: %f\n accuracy: %f\n age: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.horizontalAccuracy, locationAge);
    
    _currentLocation = newLocation;
    
    // reverse geocode and save current address
    [_geoCoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"ERROR:There was a reverse geocoding error\n%@", [error description]);
        } else {
            // Iterate through all of the placemarks returned
            // and output them to the console
            for(CLPlacemark *placemark in placemarks) {
                NSLog(@"INFO:Address:\n%@", ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES));
            }
            CLPlacemark *placemark = [placemarks lastObject];
            _currentAddress = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
        }
    }];
    
    
    //    // test that the horizontal accuracy does not indicate an invalid measurement
    //    if (newLocation.horizontalAccuracy < 0) return;
    
    //    // test the measurement to see if it is more accurate than the previous measurement
    //    if (_currentLocation == nil || _currentLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
    //        // store the location as the "best effort"
    //        _currentLocation = newLocation;
    //        // test the measurement to see if it meets the desired accuracy
    //        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
    //            [_locationManager stopUpdatingLocation];
    //        }
    //    }
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
    if(name) CFRelease(name);
    if(phone) CFRelease(phone);
    if(multi) CFRelease(multi);
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:NULL];
    return NO;
}

#pragma mark - handlers
- (void)addItem:sender
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    // Display only a person's phone
    NSArray *displayedItems = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    picker.displayedProperties = displayedItems;
    // Show the picker
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)sendAlert
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSiren]) {
        [_player play];
    }
    
    NSString *latLonLink = @"";
    NSString *address = @"";
    if (_currentLocation != nil) {
        latLonLink = [NSString stringWithFormat:kGoogleMapsLink, _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];
    }
    if (_currentAddress != nil) {
        address = _currentAddress;
    }
    NSString *messageText = [NSString stringWithFormat:NSLocalizedString(@"sms_text", "text sms_text"), address, latLonLink];
    NSLog(@"INFO:Message text:\n%@", messageText);
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText]) {
        [messageController setBody:messageText];
        NSMutableArray *recipients = [NSMutableArray arrayWithCapacity:[_selectedContacts count]];
        for (Contact *contact in _selectedContacts) {
            [recipients addObject:[contact phone]];
        }
        [messageController setRecipients:recipients];
        messageController.messageComposeDelegate = self;
        [self presentViewController:messageController animated:YES completion:NULL];
    }
}

- (void)showSettings
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentModalViewController:navController animated:YES];
}

#pragma mark - CoreData
- (void)addContactWithName:(NSString *)name phone:(NSString *)phone
{
    Contact *contact = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:kContact inManagedObjectContext:_managedObjectContext];
    [contact setName:name];
    [contact setPhone:phone];
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        // Handle the error.
    }
    [_selectedContacts addObject:contact];
}

- (void)fetch
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kContact inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kName ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    [self setSelectedContacts:mutableFetchResults];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
