//  Hearbeat.h
//  CountDown
//
//  Created by David Phillip Oster on 9/08/2020.
//  Copyright David Phillip Oster 2020 . All rights reserved.
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN


// If there are any subscribers this notification is sent once per second.
extern NSString *const HeartbeatNotification;

@protocol HeartbeatProtocol <NSObject>
- (void)heartDidBeat;
@end

// this is the master one second timer for the app so that multiple active timers tick together.
@interface Heartbeat : NSObject

+ (instancetype)sharedInstance;

- (void)addSubscriber:(id<HeartbeatProtocol>)sender;
- (void)removeSubscriber:(id<HeartbeatProtocol>)sender;

@end

NS_ASSUME_NONNULL_END
