//  StretchableTextView.h
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


@interface StretchableTextView : NSView
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic) NSColor *color;
@property (nonatomic) NSColor *alternateColor;
@property (nonatomic, getter=isUsingAlternateColor) BOOL useAlternateColor;

- (void)drawInBounds:(NSRect)bounds;

+ (void)draw:(NSString *)text color:(NSColor *)color font:(NSString *)fontName bounds:(NSRect)bounds ;

+ (void)drawText:(NSString *)text atPoint:(CGPoint)p attributes:(NSDictionary *)dict;

+ (NSSize)text:(NSString *)text dict:(NSMutableDictionary *)dict font:(NSString *)fontName size:(int)fontSize;

@end
