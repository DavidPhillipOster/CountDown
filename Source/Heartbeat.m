//  Hearbeat.m
//  CountDown
//
//  Created by David Phillip Oster on 9/08/2020.
//  Copyright David Phillip Oster 2020 . All rights reserved.
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0

#import "Heartbeat.h"

#import "NSTimer+CountDown.h"

NSString *const HeartbeatNotification = @"HeartbeatNotification";

@interface Heartbeat ()
@property (nonatomic) NSTimer *heartbeat;
@property NSHashTable *heartbeatClients;
@end

static Heartbeat *instance = nil;

@implementation Heartbeat

+ (instancetype)sharedInstance {
  if (instance == nil) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[self alloc] init];
    });
  }
  return instance;
}

- (void)addSubscriber:(id)sender {
  if (self.heartbeatClients == nil){
    self.heartbeatClients = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:1];
  }
  [self.heartbeatClients addObject:sender];
  if (0 < [self.heartbeatClients count] && nil == self.heartbeat) {
    self.heartbeat = [NSTimer addedTimerWithTimeInterval:1 target:self selector:@selector(didBeat:) repeats:YES];
  }
}

- (void)removeSubscriber:(id)sender {
  [self.heartbeatClients removeObject:sender];
  if (0 == [self.heartbeatClients count]) {
    [self.heartbeat invalidate];
    self.heartbeat = nil;
  }
}

- (void)didBeat:(NSTimer *)timer {
  [[self.heartbeatClients allObjects] makeObjectsPerformSelector:@selector(heartDidBeat) withObject:nil];
}

@end
