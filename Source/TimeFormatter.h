//  TimeFormatter.h
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

#import <Foundation/Foundation.h>


@interface TimeFormatter : NSFormatter {


}
- (NSString *)stringForObjectValue:(id)obj;


- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)error;


- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error;

- (int)intFromString:(NSString *)s;

- (NSString *)stringFromInt:(int)i;

@end
