//
//  MyNetworking.h
//  Hiroshi Uyama
//
//  Created by Hiroshi Uyama on 2014/03/06.
//  Copyright (c) 2014年 Prosbee Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "MyNetworkingResponse.h"

@interface MyNetworking : NSObject

// 詳しくは AFHTTPSessionManager.h を見て下さい

+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                        owner:(id)owner
                      success:(void (^)(MyNetworkingResponse *responseObject))success
                      failure:(void (^)(MyNetworkingResponse *responseObject))failure;

+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                         owner:(id)owner
                       success:(void (^)(MyNetworkingResponse *responseObject))success
                       failure:(void (^)(MyNetworkingResponse *responseObject))failure;

+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                         owner:(id)owner
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                       success:(void (^)(MyNetworkingResponse *responseObject))success
                       failure:(void (^)(MyNetworkingResponse *responseObject))failure;

+ (NSURLSessionDataTask *)PUT:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                        owner:(id)owner
                      success:(void (^)(MyNetworkingResponse *responseObject))success
                      failure:(void (^)(MyNetworkingResponse *responseObject))failure;
//Added by ARURU
+ (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                        owner:(id)owner
                      success:(void (^)(MyNetworkingResponse *responseObject))success
                      failure:(void (^)(MyNetworkingResponse *responseObject))failure;

+ (void)removeNetworkSession;
+ (void)cancelAllNetworking;
+ (BOOL)cancelNetworking:(id)owner;

@end
