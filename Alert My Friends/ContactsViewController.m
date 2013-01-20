//
//  ContactsViewController.m
//  Alert My Friends
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"add_friends", "text add_friends")];
    
    [self.tableView setAllowsSelection:NO];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = _addButton;
    
    // Toolbar
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    
    // Fetch selected contacts
    [self fetch];
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

- (void)done {
    [self dismissModalViewControllerAnimated:YES];
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

@end
