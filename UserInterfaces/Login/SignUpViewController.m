//
//  SignUpViewController.m
//  Pocket Concierge
//
//  Created by Hiroshi Uyama on 2014/07/15.
//  Copyright (c) 2014年 Bonjamin. All rights reserved.
//

#import "SignUpViewController.h"
#import "MyNetworking.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SessionManager.h"

@interface SignUpViewController ()
<UIScrollViewDelegate, NSXMLParserDelegate, UITextFieldDelegate/*Added by ARURU*/>
{
    @private
    
    __weak IBOutlet UITextField *emailTextField_;
    __weak IBOutlet UITextField *passwordTextField_;
    __weak IBOutlet UITextField *passwordTextField2_;
    __weak IBOutlet UITextField *lastNameTextField_;
    __weak IBOutlet UITextField *firstNameTextField_;
    // << Modify by ARURU
    //__weak IBOutlet UIButton *genderButton_;
    //__weak IBOutlet UIButton *birthdayButton_;

    __weak IBOutlet UITextField *birthdayField_;
    __weak IBOutlet UISegmentedControl *sexOption_;
    // >>
    
    NSXMLParser *parser_;
    NSString *token_;
    //Added by ARURU
    NSString *year, *month, *day;
    NSInteger gender;
    //>>
    NSDictionary *userParam_;
    bool bMessageDisplay;
}

- (IBAction)nextTapped:(id)sender;

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *url = [NSURL URLWithString:_MAKE_POKECON_URL(@"users/sign_up")];
    parser_ = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parser_.delegate = self;
    [parser_ parse];


    //<< Added by ARURU
    [sexOption_ addTarget:self action:@selector(sexChanged:) forControlEvents:UIControlEventValueChanged];
    gender = 1;
    //>>
    /*
    emailTextField_.text = @"redwine1216@126.com";
    passwordTextField_.text = @"11111111";
    passwordTextField2_.text = @"11111111";
    lastNameTextField_.text = @"a";
    firstNameTextField_.text = @"a";
    birthdayField_.text = @"20150101";*/
    bMessageDisplay = false;
}

- (void)sendUserParam
{
    [MyNetworking POST:_MAKE_POKECON_URL(@"users")
                 parameters:userParam_
                      owner:self
                    success:
     ^(MyNetworkingResponse *responseObject) {
         
         parser_ = [[NSXMLParser alloc] initWithData:responseObject.originalObject];
         parser_.delegate = self;
         [parser_ parse];
         
         [SVProgressHUD dismiss];
//error
         if( bMessageDisplay ) {
             bMessageDisplay = false;
             [self alertView:@"signupSucessTitle" Message:@"signupSuccessMessage"];
             [self.navigationController popViewControllerAnimated:YES];
         }
         
     } failure:^(MyNetworkingResponse *responseObject) {
         [SVProgressHUD dismiss];
         [self alertView:@"signupErrorTitle" Message:@"LINENetworkErrorMessage"];
     }];
}

#pragma mark - NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"meta"] && attributeDict && 0 < [attributeDict count]) {
        NSString *name = attributeDict[@"name"];
        if ([name isEqualToString:@"csrf-token"]) {
            token_ = attributeDict[@"content"];
            if (userParam_) {
                userParam_ = @{@"authenticity_token": token_
                               ,@"user[email]": emailTextField_.text
                               ,@"user[password]": @""
                               ,@"user[lastname]": lastNameTextField_.text
                               ,@"user[firstname]": firstNameTextField_.text
                               ,@"user[gender]": @(gender)
                               ,@"user[birthday]": birthdayField_.text
                               ,@"user[confirmed]": @"true"
                               };
                [self sendUserParam];
                
                //[self alertView:@"signupSucessTitle" Message:@"signupSuccessMessage"];
                //[self.navigationController popViewControllerAnimated:YES];
                bMessageDisplay = true;
                userParam_ = nil;
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:NO];
}

#pragma mark - UIControll events
- (IBAction)nextTapped:(id)sender {
    // authenticity_token
    // user[email]
    // user[password]
    // user[password_confirmation]
    // user[lastname]
    // user[firstname]
    // user[gender]
    // user[birthday(1i)] 年
    // user[birthday(2i)] 月
    // user[birthday(3i)] 日
//    NSDictionary *param = @{@"authenticity_token": token_
//                            ,@"email": emailTextField_.text
//                            ,@"password": passwordTextField_.text
//                            ,@"password_confirmation": passwordTextField2_.text
//                            ,@"lastname": lastNameTextField_.text
//                            ,@"firstname": firstNameTextField_.text
//                            ,@"gender": @(1)
//                            ,@"birthday": @"1980/1/26"
//                            };
    if ([emailTextField_.text isEqualToString:@""]) {
        [self alertView:@"signupErrorTitle" Message:@"mailAddressErrorMessage"];
        return;
    } else if(passwordTextField_.text.length < 8 ) {
        [self alertView:@"signupErrorTitle" Message:@"passwordErrorMessage"];
        return;
    }
    else if ([passwordTextField_.text isEqualToString:@""]) {
        [self alertView:@"signupErrorTitle" Message:@"passwordErrorMessage"];
        return;
    } else if ([passwordTextField2_.text isEqualToString:@""]) {
        [self alertView:@"signupErrorTitle" Message:@"passwordErrorMessage"];
        return;
    } else if (![passwordTextField_.text isEqualToString:passwordTextField2_.text]) {
        [self alertView:@"signupErrorTitle" Message:@"passwordDiffMessage"];
        return;
    }
    else if ([firstNameTextField_.text isEqualToString:@""]) {
        [self alertView:@"signupErrorTitle" Message:@"firstNameErrorMessage"];
        return;
    } else if ([lastNameTextField_.text isEqualToString:@""]) {
        [self alertView:@"signupErrorTitle" Message:@"lastNameErrorMessage"];
        return;
    } else if ([birthdayField_.text isEqualToString:@""] ) {
        [self alertView:@"signupErrorTitle" Message:@"birthdayErrorMessage"];
        return;
    }
    
    //<<check birthday
    if( birthdayField_.text.length < 8 )
    {//format no
        [self alertView:@"signupErrorTitle" Message:@"birthdayErrorMessage"];
        return;
    }
    
    year = [birthdayField_.text substringToIndex:4];
    month = [birthdayField_.text substringFromIndex:4];
    month = [month substringToIndex:2];
    day = [birthdayField_.text substringFromIndex:6];
    day = [day substringToIndex:2];
    //>>
    
    //gender convert
    
    //>>
    
    [SVProgressHUD show];
    userParam_ = @{@"authenticity_token": token_
                    ,@"user[email]": emailTextField_.text
                    ,@"user[password]": passwordTextField_.text
                    ,@"user[lastname]": lastNameTextField_.text
                    ,@"user[firstname]": firstNameTextField_.text
                    ,@"user[gender]": @(gender)
                    ,@"user[birthday(1i)]": year
                    ,@"user[birthday(2i)]": month
                    ,@"user[birthday(3i)]": day
                    };
    
    //[self sendUserParam];
    [self check_email];
}
/*  //Modify by ARURU
- (IBAction)genderTapped:(id)sender {
}

- (IBAction)birthdayTapped:(id)sender {
}
*/
//Modify by ARURU
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    /*
     __weak IBOutlet UITextField *emailTextField_;
     __weak IBOutlet UITextField *passwordTextField_;
     __weak IBOutlet UITextField *passwordTextField2_;
     __weak IBOutlet UITextField *lastNameTextField_;
     __weak IBOutlet UITextField *firstNameTextField_;
     */
    if ([textField isEqual:emailTextField_]) {
        [passwordTextField_ becomeFirstResponder];
    }
    else if ([textField isEqual:passwordTextField_]) {
        [passwordTextField2_ becomeFirstResponder];
    }
    else if ([textField isEqual:passwordTextField2_]) {
        [lastNameTextField_ becomeFirstResponder];
    }
    else if ([textField isEqual:lastNameTextField_]) {
        [firstNameTextField_ becomeFirstResponder];
    }
    else if ([textField isEqual:firstNameTextField_]) {
        [birthdayField_ becomeFirstResponder];
    }
    else if ([textField isEqual:birthdayField_]) {
        [self.view endEditing:NO];
    }
    
    return NO;
}

- (void)sexChanged:(UISegmentedControl *)paramSender
{
    if( [paramSender isEqual:sexOption_])
    {
        gender = [paramSender selectedSegmentIndex] + 1;
        //NSString *selectedSegmentText = [paramSender titleForSegmentAtIndex:selectedSegmentIndex];
    }
}

- (void)alertView:(NSString*)title Message:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil)
                                                    message:NSLocalizedString(msg, nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)check_email
{
    [MyNetworking GET:_MAKE_POKECON_URL(@"users/check_register")
            parameters:@{@"email": emailTextField_.text
                         }
                 owner:self
               success:
     ^(MyNetworkingResponse *responseObject) {
         
         NSString *ans = [responseObject.jsonObject objectForKey:@"ans"];
        
         if( [ans isEqualToString:@"no"] )
             [self sendUserParam];
         else
         {
             [SVProgressHUD dismiss];
             [self alertView:@"signupErrorTitle" Message:@"signupDuplicateMessage"];
             //[self.navigationController popViewControllerAnimated:YES];
         }
         //[self dismissViewControllerAnimated:YES completion:^{ }];
     } failure:^(MyNetworkingResponse *responseObject) {
         
         [SVProgressHUD dismiss];
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"signupErrorTitle", nil)
                                                         message:NSLocalizedString(@"LINENetworkErrorMessage", nil)
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         [alert show];
     }];

}
@end
