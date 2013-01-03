//
//  AppDelegate.h
//  RX
//
//  Created by Akhilesh Gupta on 12/31/12.
//  Copyright (c) 2012 Akhilesh Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContactsViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ContactsViewController *contactsViewController;

@end
