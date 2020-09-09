//  CDError.h
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

#import <Cocoa/Cocoa.h>

extern NSString * const kAppDomain;

enum {
  kUnknownFileTypeError = 1000,
  kNotUTF8Error = 1001,
  kSavePreparationError = 1002,
  kReadError = 1003
};


NSError *ErrorUnknownFileType(NSString *typeName);

NSError *ErrorNotUTF8(void);

