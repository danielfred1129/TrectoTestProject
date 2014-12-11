//
//  MainViewVC.h
//  Meetup_Test
//
//  Created by Daniel on 12/11/14.
//  Copyright (c) 2014 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface MainViewVC : UIViewController <UISearchBarDelegate, MBProgressHUDDelegate>

@property (strong, nonatomic) NSMutableArray *arrayEvents;
@property (strong, nonatomic) IBOutlet UISearchBar* searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
