//
//  CreditCardListViewController.m
//  PocketConcierge
//
//  Created by chc on 6/18/15.
//  Copyright (c) 2015 Bonjamin. All rights reserved.
//

#import <LineAdapter/LineAdapter.h>
#import "CreditCardListViewController.h"
#import "CreditCardCell.h"
#import "SettingsCell.h"
#import "GAIFields.h"
#import "SessionManager.h"
#import "LanguageHelper.h"
#ifndef TEST
#import "PocketConcierge-Swift.h"
#else
#import "PocketConciergeTest-Swift.h"
#endif

NSInteger g_selCreditCard = -1;
extern NSMutableArray *g_datasource;

@interface CreditCardListViewController ()
<UITableViewDataSource,UITableViewDelegate, NSXMLParserDelegate>
{
    NSXMLParser *parser_;
    NSString *token_;
    NSDictionary *userParam_;
}

@end

@implementation CreditCardListViewController
@synthesize dataSource;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[Tracker sharedInstance] gaSetScreen:@"設定"];

    self.navigationItem.title = NSLocalizedString(@"CreditCard", nil);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    [backButton setTitle:@" "];
    [self.navigationItem setBackBarButtonItem:backButton];

    dataSource = g_datasource;
    /*NSURL *url = [NSURL URLWithString:_MAKE_POKECON_URL(@"users/credit_cards")];
    parser_ = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parser_.delegate = self;
    [parser_ parse];*/
    [self.tableView registerNib:[UINib nibWithNibName:@"CreditCardCell" bundle:nil] forCellReuseIdentifier:@"CreditCardCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendUserParam
{
    [MyNetworking PUT:_MAKE_POKECON_URL(@"users/credit_cards")
           parameters:userParam_
                owner:self
              success:
     ^(MyNetworkingResponse *responseObject) {
         
         //         [self dismissViewControllerAnimated:YES completion:^{ }];
         parser_ = [[NSXMLParser alloc] initWithData:responseObject.originalObject];
         parser_.delegate = self;
         [parser_ parse];
         
         [SVProgressHUD dismiss];
         
     } failure:^(MyNetworkingResponse *responseObject) {
         [SVProgressHUD dismiss];
         //[self lineAlert];
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
                               };
                [self sendUserParam];
                userParam_ = nil;
            }*/
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![LanguageHelper isJapaneseLanguage]) {
        if (2 == indexPath.row || 3 == indexPath.row) {
            return 0;
        }
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CreditCardCell";
    
    CreditCardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSDictionary *carddic = [dataSource objectAtIndex:indexPath.row];
    //masked_number = number
    //name = name
    //expdate = expiration_date
    cell.creditCardName.text = carddic[@"name"];
   
    cell.creditCardNumber.text = carddic[@"masked_number"];

    cell.creditCardDate.text = carddic[@"expiration_date"];

    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
    g_selCreditCard = indexPath.row;
    [self performSegueWithIdentifier:@"Show CreditCard Edit" sender:nil];
    [[Tracker sharedInstance] gaEvent:@"選択" action:self.navigationItem.title label:cell.textLabel.text value:@(indexPath.row)];
}

- (IBAction)createCreditCard:(id)sender {
    [self performSegueWithIdentifier:@"Show CreditCard Register" sender:nil];
}

@end
