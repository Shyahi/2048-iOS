//
// Created on 17/05/14.
// Copyright (c) 2014 Shyahi. All rights reserved.
//
//


#import <Foundation/Foundation.h>


@interface SHAnalytics : NSObject
@property(strong, nonatomic) NSString *token;


+ (SHAnalytics *)sharedInstance;

+ (SHAnalytics *)sharedInstanceWithToken:(NSString *)token;

- (void)screen:(NSString *)screen properties:(NSDictionary *)properties;

- (void)track:(NSString *)eventName properties:(NSDictionary *)properties;

- (void)identify:(NSString *)identifier traits:(NSDictionary *)traits;

- (void)addPushDeviceToken:(NSData *)token;
@end