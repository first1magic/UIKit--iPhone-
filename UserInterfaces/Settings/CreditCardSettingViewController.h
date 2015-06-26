//
//  CreditCardSettingViewController.h
//  PocketConcierge
//
//  Created by chc on 6/17/15.
//  Copyright (c) 2015 Bonjamin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CreditCardSettingViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITextField *creditCardNumberField_;
@property (weak, nonatomic) IBOutlet UITextField *creditCardDateField_;
@property (weak, nonatomic) IBOutlet UITextField *creditCardNameField_;
@property (weak, nonatomic) IBOutlet UITextField *securityField_;
@end
