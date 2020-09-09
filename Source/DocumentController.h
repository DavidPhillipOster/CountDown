//  DocumentController.h
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

// Transient document is the untitled document put up when CountDown is first
// launched, or activated with no other documents open.
// If the user makes no changes to this untitled document before opening a new
// document, we get rid of the untitled document and visually replace it with
// the opened one. NSDocument doesn't yet have support for this.

@interface DocumentController : NSDocumentController {

}

@end
