//  StretchableImage.h
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




@interface StretchableImage : NSObject
@property NSImage *image;
@property int xSlice;
@property int ySlice;

- (id)initWithImage:(NSImage *)image xSlice:(int)x ySlice:(int)y;

- (void)drawInRect:(NSRect)rect operation:(NSCompositingOperation)op fraction:(float)delta;

@end
