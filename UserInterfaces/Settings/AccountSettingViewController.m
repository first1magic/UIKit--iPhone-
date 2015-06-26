//
//  AccountSettingViewController.m
//  PocketConcierge
//
//  Created by chc on 6/17/15.
//  Copyright (c) 2015 Bonjamin. All rights reserved.
//

#import "AccountSettingViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SessionManager.h"
#import "MyNetworking.h"
#import <wchar.h>

@interface AccountSettingViewController()
<UITextFieldDelegate, NSXMLParserDelegate>
{
    NSXMLParser *parser_;
    NSString *token_;
    NSDictionary *userParam_;
    NSString *year, *month, *day;
}

@property (weak, nonatomic) IBOutlet UITextField *firstNameField_;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField_;
@property (weak, nonatomic) IBOutlet UITextField *firstHiraField_;
@property (weak, nonatomic) IBOutlet UITextField *lastHiraField_;
@property (weak, nonatomic) IBOutlet UITextField *emailField_;
@property (weak, nonatomic) IBOutlet UITextField *telField_;
@property (weak, nonatomic) IBOutlet UITextField *companyField_;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sexSegment_;
@property (weak, nonatomic) IBOutlet UITextField *birthdayField_;
@property (assign, nonatomic) NSInteger gender;
@property (assign, nonatomic) NSInteger uid;

@end

@implementation AccountSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     self.navigationItem.title = NSLocalizedString(@"setting", nil);
     UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
     [backButton setTitle:@" "];
     [self.navigationItem setBackBarButtonItem:backButton];
     NSString *account = NSLocalizedString(@"accountSetting", nil);
     */
    
    NSURL *url = [NSURL URLWithString:_MAKE_POKECON_URL(@"users/edit")];
    parser_ = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parser_.delegate = self;
    [parser_ parse];
    
    self.gender = 1;
    self.uid = -1;
    [self setAccountInfo];
    [self.sexSegment_ addTarget:self action:@selector(sexChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendUserParam
{
    [MyNetworking PUT:_MAKE_POKECON_URL(@"users")
            parameters:userParam_
                 owner:self
               success:
     ^(MyNetworkingResponse *responseObject) {
         
         //         [self dismissViewControllerAnimated:YES completion:^{ }];
         /*parser_ = [[NSXMLParser alloc] initWithData:responseObject.originalObject];
         parser_.delegate = self;
         [parser_ parse];
         */
         [SVProgressHUD dismiss];
         
         if( responseObject.statusOK == YES ) {
             [self alertView:@"accountSuccessTitle" Message:@"accountSuccessMessage"];
         }
         else {
             [self alertView:@"accountErrorTitle" Message:@"accountErrorMessage"];
         }
     } failure:^(MyNetworkingResponse *responseObject) {
         [SVProgressHUD dismiss];
         
         //[self alertView:@"networkerror" Message:@"LINENetworkErrorMessage"];
     }];
}

#pragma mark - NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //    NSLog(@"%@: \n%@", elementName, attributeDict);
    /*
     "authenticity_token"=>"wp/Nsr3w8IK6LHWBV0J6SREcPK/KtSLIwfi1sc5YD28=", "user"=>{"firstname"=>"c", "lastname"=>"c", "firstname_kana"=>"33", "lastname_kana"=>"44", "gender"=>"1", "birthday(1i)"=>"1915", "birthday(2i)"=>"1", "birthday(3i)"=>"1", "email"=>"redwine1216@126.com", "tel"=>"1234567890", "company_name"=>"aaaa"}, "locale"=>"en"}
     */
    if ([elementName isEqualToString:@"meta"] && attributeDict && 0 < [attributeDict count]) {
        NSString *name = attributeDict[@"name"];
        if ([name isEqualToString:@"csrf-token"]) {
            token_ = attributeDict[@"content"];
            /*if (userParam_) {
                userParam_ = @{@"authenticity_token": token_
                               ,@"user[firstname]": self.firstNameField_.text
                               ,@"user[lastname]": self.lastNameField_.text
                               ,@"user[firstname_kana]": self.firstHiraField_.text
                               ,@"user[lastname_kana]": self.lastHiraField_.text
                               ,@"user[gender]": @(self.gender)
                               ,@"user[birthday]": self.birthdayField_.text
                               ,@"user[email]": self.emailField_.text
                               ,@"user[tel]": self.telField_.text
                               ,@"user[company_name]": self.companyField_.text
                               };
                [self sendUserParam];
                userParam_ = nil;
            }*/
        }
    }
}

- (IBAction)ApplySetting:(id)sender {
    /*[SVProgressHUD show];
    [MyNetworking PUT:_MAKE_POKECON_URL(@"api/users/update")
            parameters:@{@"user[id]": @(self.uid),
                         @"user[firstname]": self.firstNameField_.text,
                         @"user[lastname]": self.lastNameField_.text,
                         @"user[firstname_kana]": self.firstHiraField_.text,
                         @"user[lastname_kana]": self.lastHiraField_.text,
                         @"user[gender]": @(self.gender),
                         @"user[birthday]": self.birthdayField_.text,
                         @"user[email]": self.emailField_.text,
                         @"user[tel]": self.telField_.text,
                         @"user[company_name]": self.companyField_.text,}
                 owner:self
               success:
     ^(MyNetworkingResponse *responseObject) {
         
         [SVProgressHUD dismiss];
         
         [self dismissViewControllerAnimated:YES completion:^{ }];
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"success", nil)
                                               message:NSLocalizedString(@"loginErrorMessage", nil)
                                               delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         [alert show];
     } failure:^(MyNetworkingResponse *responseObject) {
         
         [SVProgressHUD dismiss];
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkerror", nil)
                                                         message:NSLocalizedString(@"loginErrorMessage", nil)
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         [alert show];
         //???
         
     }];*/
    
    if ([self.firstNameField_.text isEqualToString:@""]) {
        [self alertView:@"accountErrorTitle" Message:@"firstNameErrorMessage"];
        return;
    }
    else if ([self.lastNameField_.text isEqualToString:@""]) {
        [self alertView:@"accountErrorTitle" Message:@"lastNameErrorMessage"];
        return;
    }
    else if ([self.emailField_.text isEqualToString:@""]) {
        [self alertView:@"accountErrorTitle" Message:@"mailAddressErrorMessage"];
        return;
    }
    
    //<<check birthday
    if( self.birthdayField_.text.length < 8 )
    {//format no
        [self alertView:@"accountErrorTitle" Message:@"birthdayErrorMessage"];
        return;
    }
    
    year = [self.birthdayField_.text substringToIndex:4];
    month = [self.birthdayField_.text substringFromIndex:4];
    month = [month substringToIndex:2];
    day = [self.birthdayField_.text substringFromIndex:6];
    day = [day substringToIndex:2];
    //>>

    [SVProgressHUD show];
    userParam_ = @{@"authenticity_token": token_
                   ,@"user[firstname]": self.firstNameField_.text
                   ,@"user[lastname]": self.lastNameField_.text
                   ,@"user[firstname_kana]": self.firstHiraField_.text
                   ,@"user[lastname_kana]": self.lastHiraField_.text
                   ,@"user[gender]": @(self.gender)
                   ,@"user[birthday(1i)]": year
                   ,@"user[birthday(2i)]": month
                   ,@"user[birthday(3i)]": day
                   ,@"user[email]": self.emailField_.text
                   ,@"user[tel]": self.telField_.text
                   ,@"user[company_name]": self.companyField_.text
                   };
    
    [self sendUserParam];

}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if( [textField isEqual:self.firstNameField_] ) {
        [self.lastNameField_ becomeFirstResponder];
    }
    else if( [textField isEqual:self.lastNameField_] ) {
        [self.firstHiraField_ becomeFirstResponder];
    } 
    else if( [textField isEqual:self.firstHiraField_] ) {
        [self.lastHiraField_ becomeFirstResponder];
    }
    else if( [textField isEqual:self.lastHiraField_] ) {
        [self.birthdayField_ becomeFirstResponder];
    }
    else if( [textField isEqual:self.birthdayField_] ) {
        [self.emailField_ becomeFirstResponder];
    }
    else if( [textField isEqual:self.emailField_] ) {
        [self.telField_ becomeFirstResponder];
    }
    else if( [textField isEqual:self.telField_] ) {
        [self.companyField_ endEditing:NO];
    }
    
    return NO;
}

- (void)setAccountInfo
{
    NSDictionary *data = [[SessionManager sharedManager] getUser];
    NSString *tmp;
    
    tmp = data[@"firstname"];
    if( _NSNullSafe(tmp) )
        self.firstNameField_.text = tmp;
    
    tmp = data[@"lastname"];
    if( _NSNullSafe(tmp) )
        self.lastNameField_.text = tmp;
    
    tmp = data[@"firstname_kana"];
    if( _NSNullSafe(tmp) )
        self.firstHiraField_.text = tmp;
    
    tmp = data[@"lastname_kana"];
    if( _NSNullSafe(tmp) )
        self.lastHiraField_.text = tmp;
    
    //Modify by ARURU   -- 2015-06-20
    tmp = data[@"birthday"];
    if( _NSNullSafe(tmp) )
    {
        unichar tempDay[260] = {0};
        unichar birthday[260] = {0};
        [tmp getCharacters:birthday];
        int k = 0;
        for( NSInteger i = 0; i < tmp.length; i++ ) {
            if( birthday[i] != '-' ) {
                tempDay[k++] = birthday[i];
            }
        }

        tmp = [NSString stringWithCharacters:tempDay length:k];
        self.birthdayField_.text = tmp;
    }
    
    tmp = data[@"email"];
    if( _NSNullSafe(tmp) )
        self.emailField_.text = tmp;
    
    tmp = data[@"tel"];
    if( _NSNullSafe(tmp) )
        self.telField_.text = tmp;
    
    tmp = data[@"company_name"];
    if( _NSNullSafe(tmp) )
        self.companyField_.text = tmp;

    //user_id
    //gender
    NSNumber* p = (NSNumber*)data[@"gender"];
    self.gender = p.longValue;
    [self.sexSegment_ setSelectedSegmentIndex:self.gender - 1];
    
    p = (NSNumber*)data[@"user_id"];
    self.uid = p.longLongValue;     //Modify by ARURU 2015-06-20
}

- (void)sexChanged:(UISegmentedControl *)paramSender
{
    if( [paramSender isEqual:self.sexSegment_])
    {
        self.gender = [paramSender selectedSegmentIndex] + 1;
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
@end
