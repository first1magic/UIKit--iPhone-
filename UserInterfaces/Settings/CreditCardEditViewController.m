//
//  CreditCardEditViewController.m
//  PocketConcierge
//
//  Created by chc on 6/18/15.
//  Copyright (c) 2015 Bonjamin. All rights reserved.
//

#import "CreditCardEditViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SessionManager.h"
#import "MyNetworking.h"

extern NSInteger g_selCreditCard;
extern NSMutableArray *g_datasource;

@interface CreditCardEditViewController ()
<UITextFieldDelegate, NSXMLParserDelegate>
{
    NSXMLParser *parser_;
    NSString *token_;
    NSDictionary *userParam_;
    NSInteger card_id;
}

@end

@implementation CreditCardEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *url = [NSURL URLWithString:_MAKE_POKECON_URL(@"users/credit_cards")];
    parser_ = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parser_.delegate = self;
    [parser_ parse];
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendUserParam
{
    NSString *url = [NSString stringWithFormat:@"users/credit_cards/%ld", (long)card_id];
    [MyNetworking DELETE:_MAKE_POKECON_URL(url)
           parameters:userParam_
                owner:self
              success:
     ^(MyNetworkingResponse *responseObject) {
         
         //         [self dismissViewControllerAnimated:YES completion:^{ }];
         /*parser_ = [[NSXMLParser alloc] initWithData:responseObject.originalObject];
         parser_.delegate = self;
         [parser_ parse];
         */
         //[SVProgressHUD dismiss];
         
         //if( responseObject.statusOK == YES )
         {
//            [self alertView:@"deleteSucessTitle" Message:@"deleteSuccessMessage"];
//            [self.navigationController popViewControllerAnimated:YES];
         }
         //else
         //   [self alertView:@"deleteErrorTitle" Message:@"deleteErrorMessage"];
         [self confirmDelete];
         
     } failure:^(MyNetworkingResponse *responseObject) {
         [SVProgressHUD dismiss];
         //[self lineAlert];
         [self alertView:@"networkerror" Message:@"LINENetworkErrorMessage"];
     }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)EditCreditCardActiion:(id)sender {
    [SVProgressHUD show];
    
    userParam_ = @{@"authenticity_token": token_
                   ,@"id": @(card_id)
                   };
    
    [self sendUserParam];

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
            if (userParam_) {
                /*userParam_ = @{@"authenticity_token": token_
                               ,@"id": @(0)
                               };
                [self sendUserParam];*/
                userParam_ = nil;
            }
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

/*
 @property (weak, nonatomic) IBOutlet UITextField *creditCardNumberField_;
 @property (weak, nonatomic) IBOutlet UITextField *creditCardDateField_;
 @property (weak, nonatomic) IBOutlet UITextField *creditCardNameField_;
 @property (weak, nonatomic) IBOutlet UITextField *securityField_;
*/
- (void)initUI
{
    //masked_number = number
    //name = name
    //expdate = expiration_date
    card_id = 0;
    NSDictionary *card = g_datasource[g_selCreditCard];
    self.creditCardNumberField_.text = card[@"masked_number"];
    self.creditCardNameField_.text = card[@"name"];
    self.creditCardDateField_.text = card[@"expiration_date"];
    NSNumber *p = (NSNumber*)card[@"id"];
    card_id = p.longLongValue;
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

- (void)confirmDelete
{
    [MyNetworking GET:_MAKE_POKECON_URL(@"api/users/credit_cards")
           parameters:@{}
                owner:self
              success:
     ^(MyNetworkingResponse *responseObject) {
         
         bool bSucces = true;
         [SVProgressHUD dismiss];

         for( NSDictionary *p in [responseObject.jsonObject objectForKey:@"cards"])
         {
             NSNumber* cardID = (NSNumber*)p[@"id"];
             if( card_id == cardID.longLongValue )
             {
                 bSucces = false;
                 [self alertView:@"deleteErrorTitle" Message:@"deleteErrorMessage"];
                 break;
             }
         }
         
         if( bSucces )
             [self alertView:@"deleteSuccessTitle" Message:@"deleteSuccessMessage"];
         else
             [self alertView:@"deleteErrorTitle" Message:@"deleteErrorMessage"];
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
