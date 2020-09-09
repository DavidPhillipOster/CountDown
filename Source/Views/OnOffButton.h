//  OnOffButton.h
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

@class StretchableImage;

@interface StateEntry : NSView
@property StretchableImage *image;
@property (copy) NSString *text;
@property NSColor *color;
@property NSFont *font;

- (void)drawRect:(NSRect)rect bounds:(NSRect)bounds isDown:(BOOL)isDown;

@end

@interface OnOffButton : NSView
@property (nonatomic) int state;

// for Key Value Coding Compliance
- (NSUInteger)countOfStateEntrys;
- (StateEntry *)objectInStateEntrysAtIndex:(NSUInteger)index;
- (void)insertObject:(StateEntry *)se inStateEntrysAtIndex:(NSUInteger)index;
- (void)removeObjectFromStateEntrysAtIndex:(NSUInteger)index;

// calls action when button is clicked in.
- (void)setTarget:(id)target action:(SEL)sel;
@end
