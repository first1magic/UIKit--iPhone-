//
//  SessionManager.h
//  Pocket Concierge
//
//  Created by kinkori on 2014/09/10.
//  Copyright (c) 2014年 Bonjamin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionManager : NSObject

@property (nonatomic,assign,getter=isInSession) BOOL inSession;
@property (nonatomic,readonly) NSString *authenticityToken;

+ (instancetype) sharedManager;

- (void)checkSession;
- (void)checkSession:(void (^)(BOOL inSession))responce;
- (void)updateUser:(void (^)(BOOL inSession))responce;
- (void)saveUUID:(NSString *)uui;
- (NSString*)getId;       //Added by ARURU
-(NSDictionary *)getUser;   //Added by ARURU

@end
