//
//  CreditCardCell.h
//  PocketConcierge
//
//  Created by chc on 6/18/15.
//  Copyright (c) 2015 Bonjamin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreditCardCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *creditCardName;
@property (weak, nonatomic) IBOutlet UILabel *creditCardNumber;
@property (weak, nonatomic) IBOutlet UILabel *creditCardDate;


@end
