//
//  HRBViewController.h
//  EstimatedTable
//
//  Created by Hirobe Kazuya on 5/26/14.
//  Copyright (c) 2014 Kazuya Hirobe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRBTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
- (IBAction)reloadTunedTapped:(id)sender;

- (IBAction)reloadDefaultTapped:(id)sender;

@end
