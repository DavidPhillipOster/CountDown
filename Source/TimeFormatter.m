//  TimeFormatter.m
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

#import "TimeFormatter.h"

static NSString *SecondsAsString(int seconds) {
  if (60*60 <= seconds) {
    return [NSString stringWithFormat:@"%01d:%02d:%02d",
      seconds/(60*60), (seconds % (60*60))/60, seconds % 60];
  } else if (60 <= seconds) {
    return [NSString stringWithFormat:@"%01d:%02d", seconds/60, seconds % 60];
  } else {
    return [NSString stringWithFormat:@"%02d", seconds % 60];
  }
}

static BOOL StringAsSeconds(NSString *s, int *secondsp) {
  *secondsp = 0;
  if (0 == [s length]) {
     return YES;
  }
  NSArray *a = [s componentsSeparatedByString:@":"];
  int i, k;
  static int multiplier[] = {1, 60, 60*60};
  for (i = 0, k = [a count] - 1; i < 3 && 0 <= k; ++i, --k) {
    NSString *s1 = [a objectAtIndex:k];
    int sec1 = [s1 intValue];
    if (0 <= sec1 && sec1 <= 59) {
      *secondsp += sec1 * multiplier[i];
    } else {
      return NO;
    }
  }
  return YES;
}


@implementation TimeFormatter

- (id)copyWithZone:(NSZone *)zone {
  return [[[self class] allocWithZone:zone] init];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  return [super init];
}

- (BOOL)isEqual:(id)a {
  return [self class] == [a class];
}

- (NSUInteger)hash {
  return [[self class] hash];
}


- (NSString *)stringForObjectValue:(id)obj {
  int n = [obj intValue];
  return SecondsAsString(n);
}


- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)error {
  NSArray *a = [string componentsSeparatedByString:@":"];
  if (3 < [a count]) {
    if (error) {
      *error = @"Too many colons";
    }
    return NO;
  }
  if (0 == [a count]) {
    if (error) {
      *error = @"Empty";
    }
    return NO;
  }
  int hours = 0;
  int minutes = 0;
  int seconds = [[a objectAtIndex:[a count] - 1] intValue];
  if (!(0 <= seconds && seconds <= 59) && 1 != [a count]) {
    if (error) {
      *error = @"Seconds out of range";
    }
    return NO;
  }
  if (2 <= [a count]) {
    minutes = [[a objectAtIndex:[a count] - 2] intValue];
    if (!(0 <= seconds && seconds <= 59)) { 
      if (error) {
        *error = @"Minutes out of range";
      }
      return NO;
    }
  }
  if (3 == [a count]) {
    hours = [[a objectAtIndex:[a count] - 3] intValue];
    if (hours  < 0) {
      if (error) {
        *error = @"Hours out of range.";
      }
      return NO;
    }
  }
  *obj = [NSNumber numberWithInt:hours*3600 + minutes*60 + seconds];
  return YES;
}


- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error {
  return YES;
}

- (int)intFromString:(NSString *)s {
  id obj = nil;
  [self getObjectValue:&obj forString:s errorDescription:nil];
  return [obj intValue];
}


- (NSString *)stringFromInt:(int)i {
  return [self stringForObjectValue:[NSNumber numberWithInt:i]];
}


@end
