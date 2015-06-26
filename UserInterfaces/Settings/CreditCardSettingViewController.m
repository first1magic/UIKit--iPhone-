//
//  CreditCardSettingViewController.m
//  PocketConcierge
//
//  Created by chc on 6/17/15.
//  Copyright (c) 2015 Bonjamin. All rights reserved.
//

#import "CreditCardSettingViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SessionManager.h"
#import "MyNetworking.h"

@interface CreditCardSettingViewController()
<UITextFieldDelegate, NSXMLParserDelegate>
{
    NSXMLParser *parser_;
    NSString *token_;
    NSDictionary *userParam_;
}

@end

@implementation CreditCardSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

     self.navigationItem.title = NSLocalizedString(@"setting", nil);
     UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
     [backButton setTitle:@" "];
     //[self.navigationItem setBackBarButtonItem:backButton];
      //NSString *account = NSLocalizedString(@"accountSetting", nil);
    
    NSURL *url = [NSURL URLWithString:_MAKE_POKECON_URL(@"users/credit_cards")];
    parser_ = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parser_.delegate = self;
    [parser_ parse];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( [textField isEqual:self.creditCardNumberField_] ) {
        [self.creditCardDateField_ becomeFirstResponder];
    }
    else if( [textField isEqual:self.creditCardDateField_] ) {
        [self.creditCardNameField_ becomeFirstResponder];
    }
    else if( [textField isEqual:self.creditCardNameField_] ) {
        [self.securityField_ endEditing:NO];
    }

    return NO;
}

- (IBAction)CreateCreditCardAction:(id)sender
{
    if( self.creditCardNumberField_.text.length < 16 ) {
        [self alertView:@"addErrorTitle" Message:@"cardNumberErrorMessage"];
        return;
    }
    else if( self.creditCardDateField_.text.length <= 0 ) {
        return;
        [self alertView:@"addErrorTitle" Message:@"cardDateErrorMessage"];
    }
    else if( self.creditCardNumberField_.text.length <= 0 ) {
        [self alertView:@"addErrorTitle" Message:@"cardNameErrorMessage"];
        return;
    }
    else if( self.securityField_.text.length <= 0 ) {
        [self alertView:@"addErrorTitle" Message:@"securityErrorMessage"];
        return;
    }
    
    if( !_NSNullSafe(token_) )
        return;
        
    [SVProgressHUD show];
    userParam_ = @{@"authenticity_token": token_
                   ,@"credit_card_gmo[card_no]": self.creditCardNumberField_.text
                   ,@"credit_card_gmo[expire]": self.creditCardDateField_.text
                   ,@"credit_card_gmo[name]": self.creditCardNameField_.text
                   ,@"credit_card_gmo[security_code]": self.securityField_.text
                   };
    
    [self sendUserParam];
}

- (void)sendUserParam
{
    [MyNetworking POST:_MAKE_POKECON_URL(@"users/credit_cards")
           parameters:userParam_
                owner:self
              success:
     ^(MyNetworkingResponse *responseObject) {
         
         //         [self dismissViewControllerAnimated:YES completion:^{ }];
         /*parser_ = [[NSXMLParser alloc] initWithData:responseObject.originalObject];
         parser_.delegate = self;
         [parser_ parse];*/
         //_statusOK = NO, YES
         //[SVProgressHUD dismiss];
         
         //if( responseObject.statusOK == YES )
         //{
         //    [self alertView:@"addSuccessTitle" Message:@"addSuccessMessage"];
         //    [self.navigationController popViewControllerAnimated:YES];
         //}
         //else
         //   [self alertView:@"addErrorTitle" Message:@"addErrorMessage"];
         [self confirmAdd];
     } failure:^(MyNetworkingResponse *responseObject) {
         [SVProgressHUD dismiss];
         //[self lineAlert];
         [self alertView:@"networkerror" Message:@"LINENetworkErrorMessage"];
     }];
}

#pragma mark - NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //    NSLog(@"%@: \n%@", elementName, attributeDict);
    /*
     Parameters: {"utf8"=>"✓", "authenticity_token"=>"pZe3Skl2axEyRN5fxFF45DVaFIp/9c+CuNRt2dcj4Sk=", "credit_card_gmo"=>{"card_no"=>"11111111111", "expire"=>"0117", "name"=>"aaa", "security_code"=>"123"}, "locale"=>"en"}
     */
    if ([elementName isEqualToString:@"meta"] && attributeDict && 0 < [attributeDict count]) {
        NSString *name = attributeDict[@"name"];
        if ([name isEqualToString:@"csrf-token"]) {
            token_ = attributeDict[@"content"];
            /*if (userParam_) {
                userParam_ = @{@"authenticity_token": token_
                               ,@"credit_card_gmo[card_no]": self.creditCardNumberField_.text
                               ,@"credit_card_gmo[expire]": self.creditCardDateField_.text
                               ,@"credit_card_gmo[name]": self.creditCardNameField_.text
                               ,@"credit_card_gmo[security_code]": self.securityField_.text
                               };
                [self sendUserParam];
                userParam_ = nil;
            }*/
        }
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

- (void)confirmAdd
{
    [MyNetworking GET:_MAKE_POKECON_URL(@"api/users/credit_cards")
           parameters:@{}
                owner:self
              success:
     ^(MyNetworkingResponse *responseObject) {
         
         bool bSucces = false;
         [SVProgressHUD dismiss];
         
         for( NSDictionary *p in [responseObject.jsonObject objectForKey:@"cards"])
         {
             NSNumber* cardID = (NSNumber*)p[@"id"];
             NSInteger myCardID = [self.creditCardNumberField_.text integerValue];
             if( myCardID == cardID.longLongValue )
             {
                 bSucces = true;
                 [self alertView:@"deleteErrorTitle" Message:@"deleteErrorMessage"];
                 break;
             }
         }
         
         if( bSucces )
             [self alertView:@"addSuccessTitle" Message:@"addSuccessMessage"];
         else
             [self alertView:@"addErrorTitle" Message:@"addErrorMessage"];
         //         [self dismissViewControllerAnimated:YES completion:^{ }];
         
     } failure:^(MyNetworkingResponse *responseObject) {
         
         [SVProgressHUD dismiss];
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkerror", nil)
                                                         message:NSLocalizedString(@"loginErrorMessage", nil)
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         [alert show];
         //???
     }];
    
}


@end
