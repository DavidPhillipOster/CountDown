//  CDError.m
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

#import "CDError.h"


NSError *ErrorUnknownFileType(NSString *typeName) {
  NSString *s = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"ErrorUnknownFileType", @""), typeName];
  NSDictionary *info = [NSDictionary dictionaryWithObject:s forKey:NSLocalizedFailureReasonErrorKey];
  return [NSError errorWithDomain:kAppDomain code:kUnknownFileTypeError userInfo:info];
}

NSError *ErrorNotUTF8(void) {
  NSString *s = NSLocalizedString(@"ErrorNotUTF8", @"");
  NSDictionary *info = [NSDictionary dictionaryWithObject:s forKey:NSLocalizedFailureReasonErrorKey];
  return [NSError errorWithDomain:kAppDomain code:kNotUTF8Error userInfo:info];
}

NSString * const kAppDomain = @"CountDown";
