//
//  LoginViewController.h
//  Pocket Concierge
//
//  Created by Hiroshi Uyama on 2014/07/09.
//  Copyright (c) 2014年 Bonjamin. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "BaseViewController.h"
#import <LineAdapter/LineAdapter.h>
#import <LineAdapterUI/LineAdapterUI.h>

@class LineAdapter;
@interface LoginViewController : BaseViewController
{
    LineAdapter *adapter;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (weak, nonatomic) IBOutlet UIButton *registration;

- (IBAction)signUpTapped:(id)sender;
- (IBAction)onTap:(UITapGestureRecognizer *)sender;

@end
