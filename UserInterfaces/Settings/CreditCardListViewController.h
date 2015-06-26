//
//  CreditCardListViewController.h
//  PocketConcierge
//
//  Created by chc on 6/18/15.
//  Copyright (c) 2015 Bonjamin. All rights reserved.
//

#import "BaseViewController.h"

@interface CreditCardListViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *dataSource;

@end
