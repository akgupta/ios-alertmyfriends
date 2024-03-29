//
//  AlertViewController.m
//  Alert My Friends
//
//  Created by Akhilesh Gupta on 1/19/13.
//  Copyright (c) 2013 Akhilesh Gupta. All rights reserved.
//

#import "AlertViewController.h"
#import "ContactsViewController.h"
#import "SettingsViewController.h"
#import "Contact.h"

@interface AlertViewController ()

@end

@implementation AlertViewController

@synthesize currentLocation = _currentLocation;
@synthesize currentAddress = _currentAddress;
@synthesize geoCoder = _geoCoder;
@synthesize player = _player;
@synthesize contactsViewController = _contactsViewController;
@synthesize coordinatesLabel = _coordinatesLabel;
@synthesize addressLabel = _addressLabel;
@synthesize mapView = _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:NSLocalizedString(@"alert_my_friends", "text alert_my_friends")];
    
    UIBarButtonItem *contactsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"group.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(selectContacts)];
    
    self.navigationItem.rightBarButtonItem = contactsButton;
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"\u2699" style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings)];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        UIFont *settingsFont = [UIFont fontWithName:@"Helvetica" size:24.0];
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:settingsFont, UITextAttributeFont, nil];
        [settingsButton setTitleTextAttributes:dict forState:UIControlStateNormal];
    }
    
    self.navigationItem.leftBarButtonItem = settingsButton;
    
    // init contacts controller
    _contactsViewController = [[ContactsViewController alloc] initWithStyle:UITableViewStylePlain];
    _contactsViewController.managedObjectContext = [ApplicationDelegate managedObjectContext];
    // make sure contacts are loaded
    [_contactsViewController fetch];
    
    // Location
    _geoCoder = [[CLGeocoder alloc] init];
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
    
    // AV Player
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource: @"siren" ofType: @"wav"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
    [_player prepareToPlay];
    [_player setVolume:1.0];
    [_player setNumberOfLoops:2];
}

- (void)didReceiveMemoryWarning
{
    [_player stop];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - handlers

- (void)selectContacts {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_contactsViewController];
    [navigationController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [navigationController setToolbarHidden:NO];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)showSettings
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentModalViewController:navController animated:YES];
}

- (IBAction)sendAlert
{
    NSArray *selectedContacts = [_contactsViewController selectedContacts];
    if ([selectedContacts count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"empty_contacts_title", "text empty_contacts_title") message:NSLocalizedString(@"empty_contacts_message", "text empty_contacts_message") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", "text ok") otherButtonTitles:nil];
        [alert show];
        return;
    }
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
        NSMutableArray *recipients = [NSMutableArray arrayWithCapacity:[selectedContacts count]];
        for (Contact *contact in selectedContacts) {
            [recipients addObject:[contact phone]];
        }
        [messageController setRecipients:recipients];
        messageController.messageComposeDelegate = self;
        [self presentModalViewController:messageController animated:YES];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    CLLocation *newLocation = userLocation.location;
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    NSLog(@"INFO:Location:\n lat: %f\n lon: %f\n accuracy: %f\n age: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.horizontalAccuracy, locationAge);
    
    _currentLocation = newLocation;
    [self updateLocationLabels];
    
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
            [self updateLocationLabels];
        }
    }];
}

- (void)updateLocationLabels {
    if (_currentLocation != nil) {
        _coordinatesLabel.text = [NSString stringWithFormat:@"%f, %f", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];
    }
    if (_currentAddress != nil) {
        _addressLabel.text = _currentAddress;
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
