//
//  LoginViewController.m
//  Pocket Concierge
//
//  Created by Hiroshi Uyama on 2014/07/09.
//  Copyright (c) 2014年 Bonjamin. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "LoginViewController.h"
#import "MyNetworking.h"
#import "SignUpViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SessionManager.h"
#import <LineAdapter/LineAdapter.h>
#import <LineAdapterUI/LineAdapterUI.h>
#ifndef TEST
    #import "PocketConcierge-Swift.h"
#else
    #import "PocketConciergeTest-Swift.h"
#endif

@interface LoginViewController ()
<UITextFieldDelegate>

{
@private
    

    __weak IBOutlet UIButton *lineLoginButton_;
    __weak IBOutlet UITextField *emailTextField_;
    __weak IBOutlet UITextField *passwordTextField_;
    
}

- (IBAction)loginTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    adapter = [[LineAdapter alloc] initWithConfigFile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lineAdapterAuthorizationDidChange:)
                                                 name:LineAdapterAuthorizationDidChangeNotification object:nil];
    
    _fbLoginView.readPermissions = @[@"email",
                                     @"public_profile",
                                     @"user_birthday"];
    
    [self registKeyboardNotifications];
    
    UIImage *image;
    image = [UIImage imageNamed:@"btn_login_base"];
    CGSize imageSize = image.size;
    imageSize.width /= 2;
    imageSize.height /= 2;
    image = [image stretchableImageWithLeftCapWidth:imageSize.width topCapHeight:imageSize.height];
    [lineLoginButton_ setBackgroundImage:image forState:UIControlStateNormal];
    image = [UIImage imageNamed:@"btn_login_press"];
    image = [image stretchableImageWithLeftCapWidth:imageSize.width topCapHeight:imageSize.height];
    [lineLoginButton_ setBackgroundImage:image forState:UIControlStateHighlighted];
    
//    NSString *str = _registration.titleLabel.text;
//    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
//    NSDictionary *attributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
//    [attrStr addAttributes:attributes range:NSMakeRange(0, [attrStr length])];
//    [_registration setAttributedTitle:attrStr forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[SessionManager sharedManager] checkSession:^(BOOL inSession) {
        
    }];
}

- (void)lineAdapterAuthorizationDidChange:(NSNotification*)aNotification
{
    if ([[aNotification object] isAuthorized])
    {
        [self getLineApi];
    }
    else {
        NSError *error = [[aNotification userInfo] objectForKey:@"error"];
        if (error) {
            [adapter unauthorize];
            NSInteger code = [error code];
            if (code) {
                NSString *errorMessage;
                if (code == kLineAdapterErrorAuthorizationAgentNotAvailable)
                {
                    errorMessage = NSLocalizedString(@"LINEInstallErrorMessage", nil);
                }
                else if (code == kLineAdapterErrorInvalidServerResponse)
                {
                    errorMessage = NSLocalizedString(@"LINENetworkErrorMessage", nil);
                }
                else if (code == kLineAdapterErrorAuthorizationDenied)
                {
                    errorMessage = NSLocalizedString(@"LINEAuthenticationErrorMessage", nil);
                }
                else if (code == kLineAdapterErrorAuthorizationFailed)
                {
                    errorMessage = NSLocalizedString(@"LINEFailureErrorMessage", nil);
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginErrorTitle", nil)
                                                                message:errorMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

- (void)registLine:(NSDictionary *)result{
    LineApiClient *apiClient = _NSNullSafe([adapter getLineApiClient]);
    NSString *accessToken = _NSNullSafe(apiClient.accessToken);
    NSString *refreshToken = _NSNullSafe(apiClient.refreshToken);
    NSString *uid = _NSNullSafe(result[@"mid"]);
    NSString *nickname = _NSNullSafe(result[@"displayName"]);
    NSDate *expireAt = _NSNullSafe(apiClient.expiresDate);
    NSTimeInterval t = [expireAt timeIntervalSince1970];
    NSString *expireAtString = [NSString stringWithFormat:@"%f", t];
    
    if (!uid || !accessToken || !refreshToken || !nickname || !expireAtString) {
        [adapter unauthorize];
        [self lineAlert];
        return;
    }
    
    NSDictionary *userDic = @{@"uid": uid,
                              @"access_token": accessToken,
                              @"refresh_token": refreshToken,
                              @"expire_at": expireAtString,
                              @"nickname": nickname};
    
    [SVProgressHUD show];
    
    [MyNetworking POST:_MAKE_POKECON_URL(@"api/users/auth_line")
            parameters:userDic
                 owner:self
               success:^(MyNetworkingResponse *responseObject) {
                   if ([responseObject isStatusOK]) {
                       NSString *uuid = [responseObject.jsonObject objectForKey:@"uuid"];
                       [[SessionManager sharedManager] saveUUID:uuid];
                       [SVProgressHUD dismiss];
                       [self dismissViewControllerAnimated:YES completion:^{
                           if (![adapter canAuthorizeUsingLineApp]) {
                               if ([self.navigationController.visibleViewController isKindOfClass:[LoginViewController class]]) {
                                   [self dismissViewControllerAnimated:YES completion:nil];
                               }
                           }
                       }];
                   } else {
                       [SVProgressHUD dismiss];
                       if (![adapter canAuthorizeUsingLineApp]) {
                           if ([self.navigationController.visibleViewController isKindOfClass:[LineAdapterWebViewController class]]) {
                               [self dismissViewControllerAnimated:YES completion:nil];
                           }
                       }
                       NSString *path = @"users/sign_up";
                       WebViewController *vc = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
                       [vc setPokeconUrl:_MAKE_POKECON_URL(path)];
                       [self.navigationController pushViewController:vc animated:YES];
                   }
                   
               } failure:^(MyNetworkingResponse *responseObject) {
                   [SVProgressHUD dismiss];
                   [adapter unauthorize];
                   [self lineAlert];
               }];
}

- (void)registFacebook:(NSDictionary *)result{
    
    FBAccessTokenData *tokenData = [[FBSession activeSession] accessTokenData];
    NSString *email = _NSNullSafe( result[@"email"] );
    NSValue *uid = _NSNullSafe( result[@"id"] );
    NSString *firstName = _NSNullSafe( result[@"first_name"] );
    NSString *lastName = _NSNullSafe( result[@"last_name"] );
    NSString *gender = _NSNullSafe( result[@"gender"] );
    NSString *birthday = _NSNullSafe( result[@"birthday"] );
    
    if (!tokenData || !tokenData.accessToken || !email || !uid || !firstName || !lastName || !gender || !birthday) {
        [[FBSession activeSession] closeAndClearTokenInformation];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginErrorTitle", nil)
                                                        message:NSLocalizedString(@"FBNetworkErrorMessage", nil)
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSDictionary *userDic = @{@"email": email,
                              @"uid": uid,
                              @"firstname": firstName,
                              @"lastname": lastName,
                              @"gender": gender,
                              @"birthday": birthday,
                              @"access_token": tokenData.accessToken};
    
    [SVProgressHUD show];
    
    [MyNetworking POST:_MAKE_POKECON_URL(@"api/users/auth_facebook")
           parameters:userDic
                owner:self
              success:^(MyNetworkingResponse *responseObject) {
                  
                  NSString *uuid = [responseObject.jsonObject objectForKey:@"uuid"];
                  [[SessionManager sharedManager] saveUUID:uuid];
                  
                  [SVProgressHUD dismiss];
                  [self dismissViewControllerAnimated:YES completion:nil];
                  
              } failure:^(MyNetworkingResponse *responseObject) {
                  
                  [[FBSession activeSession] closeAndClearTokenInformation];
                  [SVProgressHUD dismiss];
                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginErrorTitle", nil)
                                                                  message:NSLocalizedString(@"FBNetworkError", nil)
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                  [alert show];
            }];
    
}

- (void)registKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGPoint scrollPoint = CGPointMake(0.0,120.0);
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.scrollView setContentSize:self.contentView.bounds.size];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {

    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){        
        if (!error) {
            NSLog(@"logged in.");
            [self registFacebook :result];
            
        } else {
            NSLog(@"error: %@", error);
            [[FBSession activeSession] closeAndClearTokenInformation];
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginErrorTitle", nil)
                                                            message:NSLocalizedString(@"FBNetworkError", nil)
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
    }];

}

#pragma mark - UIControl evelts
- (IBAction)loginTapped:(id)sender {
    
    [SVProgressHUD show];
    
    [MyNetworking POST:_MAKE_POKECON_URL(@"api/users/sign_in")
            parameters:@{@"user[email]": emailTextField_.text,
                         @"user[password]": passwordTextField_.text}
                 owner:self
               success:
     ^(MyNetworkingResponse *responseObject) {
         
         NSString *uuid = [responseObject.jsonObject objectForKey:@"uuid"];
         [[SessionManager sharedManager] saveUUID:uuid];
          
         [SVProgressHUD dismiss];
         
         [self dismissViewControllerAnimated:YES completion:^{ }];
         
     } failure:^(MyNetworkingResponse *responseObject) {
         
         [SVProgressHUD dismiss];
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginErrorTitle", nil)
                                                         message:NSLocalizedString(@"loginErrorMessage", nil)
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         [alert show];
         
     }];
}

- (IBAction)cancelTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
    
}

- (IBAction)signUpTapped:(id)sender {
    
    /*NSString *path = @"users/sign_up";
    WebViewController *vc = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    [vc setPokeconUrl:_MAKE_POKECON_URL(path)];
    [self.navigationController pushViewController:vc animated:YES];
    */
    //Modify by ARURU.
    [self performSegueWithIdentifier:@"SignUp" sender:nil];
}

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:emailTextField_]) {
        [passwordTextField_ becomeFirstResponder];
    }
    else if ([textField isEqual:passwordTextField_]) {
        [self.view endEditing:NO];
    }
    return NO;
}

- (IBAction)lineLogin:(id)sender {
    if ([adapter isAuthorized])
    {
//        [adapter unauthorize];
//        [self dismissViewControllerAnimated:YES completion:^{ }];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"既にLINEでログインしています"
//                                                        message:nil
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
        
        [self getLineApi];
    }
    else {
        if ([adapter canAuthorizeUsingLineApp])
        {
            [adapter authorize];
        }
        else {
            UIViewController *viewController;
            viewController = [[LineAdapterWebViewController alloc] initWithAdapter:adapter
                                                            withWebViewOrientation:kOrientationAll];
            [[viewController navigationItem] setLeftBarButtonItem:[LineAdapterNavigationController
                                                                   barButtonItemWithTitle:@"Cancel" target:self action:@selector(cancelTapped:)]];
            UIViewController *navigationController;
            navigationController = [[LineAdapterNavigationController alloc]
                                    initWithRootViewController:viewController];
            [self presentViewController:navigationController animated:YES completion:nil];
        }
    }
}

- (void)getLineApi {
    [[adapter getLineApiClient] getMyProfileWithResultBlock:^(NSDictionary *result, NSError *error)
     {
         if (!error) {
             [self registLine:result];
         }
         else {
             [SVProgressHUD dismiss];
             [adapter unauthorize];
             [self lineAlert];
         }
     }];
}

- (void)lineAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginErrorTitle", nil)
                                                    message:NSLocalizedString(@"LINENetworkErrorMessage", nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
