//
//  Contact.h
//  Alert My Friends
//
//  Created by Akhilesh Gupta on 1/3/13.
//  Copyright (c) 2013 Akhilesh Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;

@end
