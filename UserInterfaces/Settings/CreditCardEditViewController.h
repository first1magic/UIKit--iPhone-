//
//  CreditCardEditViewController.h
//  PocketConcierge
//
//  Created by chc on 6/18/15.
//  Copyright (c) 2015 Bonjamin. All rights reserved.
//

#import "BaseViewController.h"

@interface CreditCardEditViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITextField *creditCardNumberField_;
@property (weak, nonatomic) IBOutlet UITextField *creditCardDateField_;
@property (weak, nonatomic) IBOutlet UITextField *creditCardNameField_;
@end
