//
//  SettingsViewController.h
//  Pocket Concierge
//
//  Created by kinkori on 2014/09/23.
//  Copyright (c) 2014年 Bonjamin. All rights reserved.
//

#import "BaseViewController.h"

@interface SettingsViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *dataSource;

@end
