//
//  AlertViewController.h
//  Alert My Friends
//
//  Created by Akhilesh Gupta on 1/19/13.
//  Copyright (c) 2013 Akhilesh Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>

@class ContactsViewController;

@interface AlertViewController : UIViewController <MFMessageComposeViewControllerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) ContactsViewController *contactsViewController;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSString *currentAddress;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *coordinatesLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *addressLabel;
@property (unsafe_unretained, nonatomic) IBOutlet MKMapView *mapView;

@end
