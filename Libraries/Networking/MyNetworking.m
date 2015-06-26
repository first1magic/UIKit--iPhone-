//
//  MyNetworking.m
//  Hiroshi Uyama
//
//  Created by Hiroshi Uyama on 2014/03/06.
//  Copyright (c) 2014年 Prosbee Inc. All rights reserved.
//

#import "MyNetworking.h"
#import "MyNetManager.h"

typedef enum {
    RetryNetworkingTypeNone = 0,
    RetryNetworkingTypeGet,
    RetryNetworkingTypePost,
    RetryNetworkingTypeMultipart,
} RetryNetworkingType;

@interface MyNetworking ()
{
    @private
    
}

@property (nonatomic,retain) id retryOwner;
@property (nonatomic,copy) NSString *retryURL;
@property (nonatomic,assign) NSInteger retryNetworkingType;
@property (nonatomic,retain) NSDictionary *parameters;
@property (nonatomic,copy) void (^block)(id<AFMultipartFormData>); // ローカルのブロック構文は入れないようにして下さい
@property (nonatomic,copy) void (^success)(MyNetworkingResponse*); // ローカルのブロック構文は入れないようにして下さい
@property (nonatomic,copy) void (^failure)(MyNetworkingResponse*); // ローカルのブロック構文は入れないようにして下さい
@property (nonatomic,retain) MyNetworkingResponse *recentObject;

@end

@implementation MyNetworking

+ (void)cancelAllNetworking
{
    [MyNetManager cancelAllTask];
}

+ (BOOL)cancelNetworking:(id)owner
{
    return [MyNetManager cancelOwner:owner];
}

+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                        owner:(id)owner
                      success:(void (^)(MyNetworkingResponse *responseObject))success
                      failure:(void (^)(MyNetworkingResponse *responseObject))failure
{
    NSURLSessionDataTask *ret = nil;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:APPLICATION_NAME forHTTPHeaderField:@"X-Application-Name"];
#ifdef BASIC_AUTH
    [manager.requestSerializer setValue:BASIC_AUTH forHTTPHeaderField:@"Authorization"];
#endif
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    ret = [manager GET:URLString
             parameters:parameters
                success:^(NSURLSessionDataTask *task, id responseObject) {
                    [MyNetManager removeTask:task];
              
                    MyNetworkingResponse *response = [[MyNetworkingResponse alloc] initWithTask:task data:responseObject error:nil];
                    success(response);
              
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [MyNetManager removeTask:task];
                    
                    MyNetworkingResponse *response = [[MyNetworkingResponse alloc] initWithTask:task data:nil error:error];
                    failure(response);
                    
                }];
    
    [MyNetManager addTask:ret owner:owner];
    
    return ret;
}

+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                         owner:(id)owner
                       success:(void (^)(MyNetworkingResponse *responseObject))success
                       failure:(void (^)(MyNetworkingResponse *responseObject))failure
{
    NSURLSessionDataTask *ret = nil;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:APPLICATION_NAME forHTTPHeaderField:@"X-Application-Name"];
#ifdef BASIC_AUTH
    [manager.requestSerializer setValue:BASIC_AUTH forHTTPHeaderField:@"Authorization"];
#endif
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    ret = [manager POST:URLString
             parameters:parameters
                success:^(NSURLSessionDataTask *task, id responseObject) {
                    [MyNetManager removeTask:task];
                    
                    MyNetworkingResponse *response = [[MyNetworkingResponse alloc] initWithTask:task data:responseObject error:nil];
                    success(response);
                    
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [MyNetManager removeTask:task];
                    
                    MyNetworkingResponse *response = [[MyNetworkingResponse alloc] initWithTask:task data:nil error:error];
                    failure(response);
                    
                }];
    
    [MyNetManager addTask:ret owner:owner];
    
    return ret;
}

+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                         owner:(id)owner
     constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
                       success:(void (^)(MyNetworkingResponse *))success
                       failure:(void (^)(MyNetworkingResponse *))failure
{
    NSURLSessionDataTask *ret = nil;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:APPLICATION_NAME forHTTPHeaderField:@"X-Application-Name"];
#ifdef BASIC_AUTH
    [manager.requestSerializer setValue:BASIC_AUTH forHTTPHeaderField:@"Authorization"];
#endif
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    ret = [manager POST:URLString
             parameters:parameters
constructingBodyWithBlock:block
                success:^(NSURLSessionDataTask *task, id responseObject) {
                    [MyNetManager removeTask:task];
                    
                    MyNetworkingResponse *response = [[MyNetworkingResponse alloc] initWithTask:task data:responseObject error:nil];
                    success(response);
                    
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [MyNetManager removeTask:task];
                    
                    MyNetworkingResponse *response = [[MyNetworkingResponse alloc] initWithTask:task data:nil error:error];
                    failure(response);
                    
                }];
    
    [MyNetManager addTask:ret owner:owner];
    
    return ret;
}

+ (NSURLSessionDataTask *)PUT:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                        owner:(id)owner
                      success:(void (^)(MyNetworkingResponse *responseObject))success
                      failure:(void (^)(MyNetworkingResponse *responseObject))failure
{
    NSURLSessionDataTask *ret = nil;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:APPLICATION_NAME forHTTPHeaderField:@"X-Application-Name"];
#ifdef BASIC_AUTH
    [manager.requestSerializer setValue:BASIC_AUTH forHTTPHeaderField:@"Authorization"];
#endif
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    ret = [manager PUT:URLString
            parameters:parameters
               success:^(NSURLSessionDataTask *task, id responseObject) {
                   [MyNetManager removeTask:task];
                   
                   MyNetworkingResponse *response = [[MyNetworkingResponse alloc] initWithTask:task data:responseObject error:nil];
                   success(response);
               
               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                   [MyNetManager removeTask:task];
                   
                   MyNetworkingResponse *response = [[MyNetworkingResponse alloc] initWithTask:task data:nil error:error];
                   failure(response);
               
               }];
    [MyNetManager addTask:ret owner:owner];
    
    return ret;
}

+ (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                        owner:(id)owner
                      success:(void (^)(MyNetworkingResponse *responseObject))success
                      failure:(void (^)(MyNetworkingResponse *responseObject))failure
{
    NSURLSessionDataTask *ret = nil;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:APPLICATION_NAME forHTTPHeaderField:@"X-Application-Name"];
#ifdef BASIC_AUTH
    [manager.requestSerializer setValue:BASIC_AUTH forHTTPHeaderField:@"Authorization"];
#endif
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    ret = [manager DELETE:URLString
            parameters:parameters
               success:^(NSURLSessionDataTask *task, id responseObject) {
                   [MyNetManager removeTask:task];
                   
                   MyNetworkingResponse *response = [[MyNetworkingResponse alloc] initWithTask:task data:responseObject error:nil];
                   success(response);
                   
               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                   [MyNetManager removeTask:task];
                   
                   MyNetworkingResponse *response = [[MyNetworkingResponse alloc] initWithTask:task data:nil error:error];
                   failure(response);
                   
               }];
    [MyNetManager addTask:ret owner:owner];
    
    return ret;
}

+ (void)removeNetworkSession
{
    
}

@end
