//
//  CountDownDoc.h
//  CountDown
//
//  Created by David Phillip Oster on 9/08/2020.
//  Copyright David Phillip Oster 2020 . All rights reserved.
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//


#import <Cocoa/Cocoa.h>

// the "model" of this program is the number of seconds to count down from.
// the file format of this program is a text .plist of a Dictionary, with 
// "maxSeconds" as the only key (this allows easy extension later.)
// The Engine of this program is a enum: we are either idle, 
// in which case the timer is editable by: typing, pasting, or dragging.
// running, or alarming.

enum {
  kIdleState,
  kRunningState,
  kAlarmingState
};
typedef char State; 

@interface CountDownDoc : NSDocument

@property (nonatomic, getter=isTransient) BOOL transient;
@property (nonatomic) State state;

- (void)insertText:(NSString *)insertString;
- (void)deleteCharacter;
- (IBAction)toggleOneTimer:(id)sender;

// Applescript
- (NSString *)alarmTimeString;
- (void)setAlarmTimeString:(NSString *)alarmTimeString;
- (NSString *)currentTimeString;
- (NSURL *)soundURL;
- (void)setSoundURL:(NSURL *)soundURL;
- (BOOL)isSoundOn;
- (void)setIsSoundOn:(BOOL)isSoundOn;
- (OSType)timerState;
- (void)setTimerState:(OSType)timerState;
@end

