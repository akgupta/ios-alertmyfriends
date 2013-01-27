//
//  SettingsViewController.m
//  Alert My Friends
//
//  Created by Akhilesh Gupta on 1/18/13.
//  Copyright (c) 2013 Akhilesh Gupta. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

typedef enum {
    kSettingsSiren,
    kSettingsShake,
    kSettingsHelp
} kSettingsRows;

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
    [self setTitle:NSLocalizedString(@"settings", "text settings")];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return kSettingsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    switch(indexPath.row) {
        case kSettingsSiren: {
            UISwitch *toggler = [[UISwitch alloc] init];
            cell.accessoryView = toggler;
            toggler.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSiren];
            [toggler addTarget:self action:@selector(sirenToggled:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = NSLocalizedString(@"siren_on_alert", @"text siren_on_alert");
            break;
        }
        case kSettingsShake: {
            UISwitch *toggler = [[UISwitch alloc] init];
            cell.accessoryView = toggler;
            toggler.on = [[NSUserDefaults standardUserDefaults] boolForKey:kShake];
            [toggler addTarget:self action:@selector(shakeToggled:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = NSLocalizedString(@"shake_to_alert", @"text shake_to_alert");
            break;
        }
        case kSettingsHelp: {
            cell.textLabel.text = NSLocalizedString(@"help", "text help");
            break;
        }
    }
    
    return cell;
}

#pragma mark - Table View Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case kSettingsHelp:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kHelpURL]];
            break;
    }
}

#pragma mark - Settings handlers

- (void) sirenToggled:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:((UISwitch *)sender).on forKey:kSiren];
}

- (void) shakeToggled:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:((UISwitch *)sender).on forKey:kShake];
}

- (void) done {
    [self dismissModalViewControllerAnimated:YES];
}


@end
