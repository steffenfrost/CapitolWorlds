//
//  MasterViewController.h
//  CapitolWords
//
//  Created by Steven Frost-Ruebling on 12/8/14.
//  Copyright (c) 2014 Carticipate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSUNLIGHTFOUNDATION_API_KEY @"my secret key"


@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;


@end

