//
//  SessionManager.m
//  Pocket Concierge
//
//  Created by kinkori on 2014/09/10.
//  Copyright (c) 2014年 Bonjamin. All rights reserved.
//

#import "SessionManager.h"
#import "MyNetworking.h"
#import "CurrentUser.h"
#ifndef TEST
  #import "PocketConcierge-Swift.h"
#else
  #import "PocketConciergeTest-Swift.h"
#endif

@implementation SessionManager

// https://developer.apple.com/jp/documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/chapter_3_section_10.html
static id instance_;

+ (instancetype) sharedManager {
    @synchronized(self) {
        if (instance_ == nil) {
            id dummy = [[self alloc] init]; // ここでは代入していない
            dummy = nil;
        }
    }
    return instance_;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    @synchronized(self) {
        if (instance_ == nil) {
            instance_ = [super allocWithZone:zone];
            [instance_ initialize];
            return instance_;  // 最初の割り当てで代入し、返す
        }
    }
    return nil; // 以降の割り当てではnilを返すようにする
}

- (void)initialize {
    
}

- (void)setInSession:(BOOL)inSession {
    if (inSession && ![[FeaturedRestaurants sharedInstance] data]) {
        [[FeaturedRestaurants sharedInstance] updateForce];
    }
    else if(!inSession) {
        [[FeaturedRestaurants sharedInstance] setData:nil];
    }
    _inSession = inSession;
}

-(void)checkSession {
    [self checkSession:^(BOOL inSession) { }];
}

- (void)checkSession:(void (^)(BOOL inSession))responce {
    [MyNetworking GET:_MAKE_POKECON_URL(@"users/session/check")
           parameters:nil
                owner:self
              success:^(MyNetworkingResponse *responseObject) {
                  if (!responseObject.jsonObject) {
                      [[CurrentUser sharedInstance] setUser:nil];
                      self.inSession = NO;
                      responce(self.inSession);
                      return ;
                  }
                  NSNumber *isSession = responseObject.jsonObject[@"session"];
                  self.inSession = [isSession boolValue];
                  if (self.inSession) {
                      [self getUser:^(BOOL inSession) {
                          responce(inSession);
                      }];
                  }
                  else {
                      [self checkUuid:^(BOOL inSession) {
                          responce(inSession);
                      }];
                  }
                  
              } failure:^(MyNetworkingResponse *responseObject) {
                  [[CurrentUser sharedInstance] setUser:nil];
                  self.inSession = NO;
                  responce(self.inSession);
                  
              }];
}

- (void)getUser:(void (^)(BOOL inSession))responce
{
    [MyNetworking GET:_MAKE_POKECON_URL(@"api/users")
           parameters:@{}
                owner:self
              success:^(MyNetworkingResponse *responseObject) {
                  if ([responseObject isStatusOK]) {
                      CurrentUser *user = [CurrentUser sharedInstance];
                      user.user = responseObject.data;
                      
                      [[Tracker sharedInstance] setUserID:[user.user[@"id"] stringValue]];
                      
                      [self getUuid:responce];
                  }
              } failure:^(MyNetworkingResponse *responseObject) {
                  [[CurrentUser sharedInstance] setUser:nil];
                  self.inSession = NO;
                  responce(self.inSession);
              }];
}

- (void)updateUser:(void (^)(BOOL inSession))responce
{
    [MyNetworking GET:_MAKE_POKECON_URL(@"api/users")
           parameters:@{}
                owner:self
              success:^(MyNetworkingResponse *responseObject) {
                  if ([responseObject isStatusOK]) {
                      CurrentUser *user = [CurrentUser sharedInstance];
                      user.user = responseObject.data;
                      [self getUuid:responce];
                  }
              } failure:^(MyNetworkingResponse *responseObject) {
                  [[CurrentUser sharedInstance] setUser:nil];
                  self.inSession = NO;
                  responce(self.inSession);
              }];
}

- (void)getUuid:(void (^)(BOOL inSession))responce
{
    [MyNetworking GET:_MAKE_POKECON_URL(@"api/users/uuid")
           parameters:@{}
                owner:self
              success:^(MyNetworkingResponse *responseObject) {
                  NSString *uuid = [responseObject.jsonObject objectForKey:@"uuid"];
                  [self saveUUID:uuid];
                  responce (self.inSession);
                  
              } failure:^(MyNetworkingResponse *responseObject) {
                  [_UD removeObjectForKey:KEYS_USER_UUID];
                  [_UD synchronize];
                  [[CurrentUser sharedInstance] setUser:nil];
                  self.inSession = NO;
                  responce(self.inSession);
              }];
}

- (void)checkUuid:(void (^)(BOOL inSession))responce
{
    NSString *uuid = [_UD objectForKey:KEYS_USER_UUID];
    if (uuid) {
        [MyNetworking POST:_MAKE_POKECON_URL(@"users/login/uuid")
                parameters:@{@"uuid": uuid}
                     owner:self
                   success:^(MyNetworkingResponse *responseObject) {
                       if ([responseObject isStatusOK]) {
                           CurrentUser *user = [CurrentUser sharedInstance];
                           user.user = responseObject.data;
                           
                           [[Tracker sharedInstance] setUserID:[user.user[@"id"] stringValue]];
                           
                           responce(self.inSession);
                       }
                   } failure:^(MyNetworkingResponse *responseObject) {
                       [[CurrentUser sharedInstance] setUser:nil];
                       self.inSession = NO;
                       responce(self.inSession);
                   }];
    }
    else {
        [[CurrentUser sharedInstance] setUser:nil];
        self.inSession = NO;
        responce(self.inSession);
    }
    
}

-(void)saveUUID:(NSString *)uuid {
    if (!_NSNullSafe(uuid)) {
        [_UD removeObjectForKey:KEYS_USER_UUID];
        [_UD synchronize];
        return;
    }
    
    [_UD setObject:uuid forKey:KEYS_USER_UUID];
    [_UD synchronize];
}

//Added by ARURU
-(NSString *)getId
{
    CurrentUser *user = [CurrentUser sharedInstance];
    if( !_NSNullSafe(user) )
        return nil;
    
    NSString *uid = user.user[@"user_id"];
    if( !_NSNullSafe(uid) )
        return nil;
    
    return uid;
}

-(NSDictionary *)getUser
{
    CurrentUser *user = [CurrentUser sharedInstance];
    if( user.user == nil )
        return nil;
    
    return user.user;
}

@end
