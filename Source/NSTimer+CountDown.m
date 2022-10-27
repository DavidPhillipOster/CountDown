// NSTimer+Countdown.m
//
//  Created by David Phillip Oster on 9/08/2020.
//  Copyright David Phillip Oster 2020 . All rights reserved.
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0

#import "NSTimer+CountDown.h"

@implementation NSTimer(CountDownDoc)
+ (NSTimer *)addedTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)sel repeats:(BOOL)repeats {
  NSTimer *timer = [NSTimer timerWithTimeInterval:seconds  target:target selector:sel userInfo:nil repeats:repeats];
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
  [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
#ifdef NSModalPanelRunLoopMode
  [runLoop addTimer:timer forMode:NSModalPanelRunLoopMode];
#endif
#ifdef NSEventTrackingRunLoopMode
  [runLoop addTimer:timer forMode:NSEventTrackingRunLoopMode];
#endif
  return timer;
}
@end

