//
//  SettingsViewController.m
//  Pocket Concierge
//
//  Created by kinkori on 2014/09/23.
//  Copyright (c) 2014年 Bonjamin. All rights reserved.
//

#import <LineAdapter/LineAdapter.h>
#import "SettingsViewController.h"
#import "SettingsWebViewController.h"
#import "SettingsCell.h"
#import "GAIFields.h"
#import "SessionManager.h"
#import "LanguageHelper.h"
#ifndef TEST
    #import "PocketConcierge-Swift.h"
#else
    #import "PocketConciergeTest-Swift.h"
#endif

NSMutableArray *g_datasource = nil;      //Added by ARURU

@interface SettingsViewController ()
<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SettingsViewController

@synthesize dataSource;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[Tracker sharedInstance] gaSetScreen:@"設定"];
    
//    self.navigationItem.title = NSLocalizedString(@"setting", nil);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    [backButton setTitle:@" "];
    [self.navigationItem setBackBarButtonItem:backButton];
    NSString *account = NSLocalizedString(@"accountSetting", nil);
    NSString *foodPreference = NSLocalizedString(@"foodPreferenceSetting", nil);
    NSString *email = NSLocalizedString(@"emailSetting", nil);
    NSString *anniversary = NSLocalizedString(@"anniversarySetting", nil);
    NSString *creditCard = NSLocalizedString(@"creditCardSetting", nil);
    NSString *logout = NSLocalizedString(@"logoutSetting", nil);
    self.dataSource = [[NSArray alloc]initWithObjects:
                       account, foodPreference, email, anniversary, creditCard, logout, nil];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SettingsCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    static NSString *CellIdentifier = @"SettingsCell";
    
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [dataSource objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.44 alpha:1];
    
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];

    [[SessionManager sharedManager] checkSession:^(BOOL inSession) {
        if (inSession) {
            NSString *path = nil;
            
            switch(indexPath.row) {
                case 0:
                    //Modify by ARURU
                    //path = @"users/edit";         //--- org code
                    if( [self requestAccountInfo] )
                        [self performSegueWithIdentifier:@"Show Account Settings" sender:nil];             //Added by ARURU
                    else {
                        //alert
                    }
                    break;
                case 1:
                    [self performSegueWithIdentifier:@"Show Meal Settings" sender:nil];
                    break;
                case 2:
                    [self performSegueWithIdentifier:@"Show Mail Settings" sender:nil];
                    break;
                case 3:
                    [self performSegueWithIdentifier:@"Show Anniversary Settings" sender:nil];
                    break;
                case 4:
                    //path = @"users/credit_cards";     //---- org code
                    [self requestCreditCardInfo];
                    break;
                case 5:
                {
                    path = @"users/sign_out";
                    LineAdapter *adapter = [[LineAdapter alloc] initWithConfigFile];
                    [adapter unauthorize];
                }
                    break;
                default:
                    break;
            }
            
            if (path) {
                WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
                [webViewController setPokeconUrl:_MAKE_POKECON_URL(path)];
                [self.navigationController pushViewController:webViewController animated:YES];
            }
        }
        else {
            // ログアウト
            if (indexPath.row >= (self.dataSource.count - 1)) {
                LineAdapter *adapter = [[LineAdapter alloc] initWithConfigFile];
                [adapter unauthorize];

                return;
            }
            

            else {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login_iPhone" bundle:nil];
                UINavigationController *vc = [storyboard instantiateInitialViewController];
                [self presentViewController:vc animated:YES completion:nil];
                //[self performSegueWithIdentifier:@"Show Account Settings" sender:nil];
                //[self performSegueWithIdentifier:@"Show Anniversary Settings" sender:nil];
                //[self performSegueWithIdentifier:@"Show CreditCard Settings" sender:nil];
            }
        }
    }];
    
    [[Tracker sharedInstance] gaEvent:@"選択" action:self.navigationItem.title label:cell.textLabel.text value:@(indexPath.row)];
}

//Add by ARURU
- (BOOL)requestAccountInfo
{
    NSString *uuid = [[SessionManager sharedManager] getId];
    if( !_NSNullSafe(uuid) )        //Modify by ARURU - 2015-06-20
        return NO;
    
    return YES;
}

- (void)requestCreditCardInfo {
    if( g_datasource == nil )
        g_datasource = [[NSMutableArray alloc] init];
    else
        [g_datasource removeAllObjects];

    [SVProgressHUD show];
    [MyNetworking GET:_MAKE_POKECON_URL(@"api/users/credit_cards")
           parameters:@{}
                owner:self
              success:
     ^(MyNetworkingResponse *responseObject) {
         for( NSDictionary *p in [responseObject.jsonObject objectForKey:@"cards"])
         {
             [g_datasource addObject:p];
         }
         
         [SVProgressHUD dismiss];
         
         [self performSegueWithIdentifier:@"Show CreditCard Settings" sender:nil];
         
         [self dismissViewControllerAnimated:YES completion:^{ }];
         
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
