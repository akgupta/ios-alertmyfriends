//
//  Contact.h
//  Alert My Friends
//
//  Created by Akhilesh Gupta on 1/22/13.
//  Copyright (c) 2013 Akhilesh Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * address;

@end
