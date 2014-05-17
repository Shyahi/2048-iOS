//
// Created on 17/05/14.
// Copyright (c) 2014 Shyahi. All rights reserved.
//
//


#import <Mixpanel/Mixpanel.h>
#import "SHAnalytics.h"

static SHAnalytics *sharedInstance = nil;

@interface SHAnalytics ()
@property(nonatomic, strong) NSData *pushDeviceToken;
@property(nonatomic) BOOL requiresPushTokenUpdate;
@end

@implementation SHAnalytics {

}

#pragma mark - Tracking
- (void)screen:(NSString *)screen properties:(NSDictionary *)properties {
    [[Mixpanel sharedInstance] track:screen properties:properties];
}

- (void)track:(NSString *)eventName properties:(NSDictionary *)properties {
    [[Mixpanel sharedInstance] track:eventName properties:properties];
}

- (void)addPushDeviceToken:(NSData *)token {
    self.pushDeviceToken = token;
    self.requiresPushTokenUpdate = YES;
    [[Mixpanel sharedInstance].people addPushDeviceToken:token];
}

#pragma mark - Initialization
- (instancetype)initWithToken:(NSString *)token {
    self = [super init];
    if (self) {
        self.token = token;
        [Mixpanel sharedInstanceWithToken:@"f5cbb9544ffb2eab524f51901bde5ac8"];
    }
    return self;
}

+ (SHAnalytics *)sharedInstanceWithToken:(NSString *)token {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SHAnalytics alloc] initWithToken:token];
    });
    return sharedInstance;
}

- (void)identify:(NSString *)identifier traits:(NSDictionary *)traits {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:identifier];
    if (traits) {
        [mixpanel.people set:traits];
    }
    if (self.requiresPushTokenUpdate) {
        self.requiresPushTokenUpdate = NO;
        [mixpanel.people addPushDeviceToken:self.pushDeviceToken];
    }
}

+ (SHAnalytics *)sharedInstance {
    return sharedInstance;
}

@end