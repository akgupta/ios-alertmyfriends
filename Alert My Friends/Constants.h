//
//  Constants.h
//  Alert My Friends
//
//  Created by Akhilesh Gupta on 1/17/13.
//  Copyright (c) 2013 Akhilesh Gupta. All rights reserved.
//

// System Versioning Preprocessor Macros

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define kModelResource @"Alert My Friends"
#define kModelExtension @"momd"
#define kStoreName @"Alert My Friends.sqlite"
#define kContact @"Contact"
#define kName @"name"
#define kSiren @"siren"
#define kShake @"shake"
#define kSettingsCount 3
#define kHelpURL @"http://alertmyfriends.zohosites.com"
#define kGoogleMapsLink @"http://maps.google.com/?q=%f,%f"
#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)
