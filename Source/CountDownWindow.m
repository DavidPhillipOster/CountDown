//  CountDownWindow.m
//  CountDown
//
//  Created by David Phillip Oster on 9/08/2020.
//   Copyright 2020 David Phillip Oster.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//

#import "CountDownWindow.h"
#import "CountDownDoc.h"

@implementation CountDownWindow

- (CountDownDoc *)doc {
  return (CountDownDoc *) [self delegate];
}

- (void)keyDown:(NSEvent *)theEvent {

  NSString *inString = [theEvent characters];
  if ([inString isEqual:@" "]) {
    State state = [[self doc] state];
    switch (state) {
    case kIdleState:
      [[self doc] setState:kRunningState];
      break;
    case kRunningState:
    case kAlarmingState:
      [[self doc] setState:kIdleState];
      break;
    default:
      break;
    }
  } else if (1 == [inString length] && 127 == [inString characterAtIndex:0]) {
    [[self doc] deleteCharacter];
  } else if ([inString isEqual:@":"]) {
    [[self doc] insertText:inString];
  } else {
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    NSRange r = [inString rangeOfCharacterFromSet:digits];
    if (0 != r.length) {
      [[self doc] insertText:inString];
    } else {
      [super keyDown:theEvent];
    }
  }
}

- (void)cancelOperation:(id)sender {
  State state = [[self doc] state];
  switch (state) {
  case kRunningState:
  case kAlarmingState:
    [[self doc] setState:kIdleState];
    break;
  default:
    break;
  }
}

@end
