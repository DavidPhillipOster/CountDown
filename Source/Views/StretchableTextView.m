//  StretchableTextView.m
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

#import "StretchableTextView.h"

static BOOL AreEqualOrBothNil(id a, id b) {
  if (a == b) {
    return YES;
  }
  return [a isEqual:b];
}

@interface NSString(Stretchable)
- (NSString *)replaceDigitsByZero;
@end

@implementation NSString(Stretchable)
- (NSString *)replaceDigitsByZero {
  NSMutableData *d = [[self dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
  NSUInteger count = [d length];
  char *dp = (char *)[d bytes];
  for (NSUInteger i = 0; i < count; ++i) {
    char c = dp[i];
    if ('1' <= c && c <= '9') {
      dp[i] = '0';
    }
  }
  return [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
}
@end

@implementation StretchableTextView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (BOOL)isOpaque {
  return NO;
}

- (void)drawRect:(NSRect)rect {
  NSRect bounds = [self bounds];
  [self drawInBounds:bounds];
}

- (void)drawInBounds:(NSRect)bounds {
  NSColor *color = self.color;
  if (self.isUsingAlternateColor && self.alternateColor) {
    color = self.alternateColor;
  }
  [[self class] draw:self.text color:color font:self.fontName bounds:bounds];
}

// Updates the attribute dict with the new fontsize, and returns the measured text size.
// A class method so it can be called outside this object.
+ (NSSize)text:(NSString *)text dict:(NSMutableDictionary *)dict font:(NSString *)fontName size:(int)fontSize {
  NSFont *font = [NSFont fontWithName:fontName size:fontSize];
  [dict setObject:font forKey:NSFontAttributeName];
  return [text sizeWithAttributes:dict];
}

+ (void)drawText:(NSString *)text atPoint:(CGPoint)p attributes:(NSDictionary *)dict {
  [text drawAtPoint:p withAttributes:dict];
}


// Draw the text, centered in the bounds rect, using the integer font size that is the best fit.
// Uses binary search to find the best fit.
// A class method so it can be called outside this object.
+ (void)draw:(NSString *)text color:(NSColor *)color font:(NSString *)fontName bounds:(NSRect)bounds {
  if (text && color && fontName) {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowOffset:NSMakeSize(3, -3)];
    [shadow setShadowBlurRadius:6.];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
      style, NSParagraphStyleAttributeName,
      color, NSForegroundColorAttributeName,
      nil];

    int lo = 4;
    int hi = floor(bounds.size.height * 2);
    int fontSize = lo + (hi-lo)/2;
    NSString *measureText = [text replaceDigitsByZero];
    NSSize textSize = [self text:measureText dict:dict font:fontName size:fontSize];
    while ( ! (bounds.size.width == textSize.width && textSize.height == bounds.size.height)  && 2 < hi - lo) {
      if (textSize.width < bounds.size.width && textSize.height < bounds.size.height) {
        lo += (hi-lo)/2;
      } else {
        hi -= (hi-lo)/2;
      }
      fontSize = lo + (hi-lo)/2;
      textSize = [self text:measureText dict:dict font:fontName size:fontSize];
    }

    [dict setObject:shadow forKey:NSShadowAttributeName];
    // Draw centered, in a single line.
    NSPoint p;
    p = bounds.origin;
    p.y += MAX(0, (bounds.size.height - textSize.height)/2);
    p.x += MAX(0, (bounds.size.width - textSize.width)/2);
    [self drawText:text atPoint:p attributes:dict];
  } else {
    // for debugging.
    [[NSColor redColor] set];
    [NSBezierPath strokeRect:bounds];
  }
}

- (void)setText:(NSString *)text {
  if (!AreEqualOrBothNil(_text, text)) {
    _text = [text copy];
    [self setNeedsDisplay:YES];
  }
}

- (void)setFontName:(NSString *)fontName {
  if (!AreEqualOrBothNil(_fontName, fontName)) {
    _fontName = [fontName copy];
    [self setNeedsDisplay:YES];
  }
}

- (void)setColor:(NSColor *)color {
  if (!AreEqualOrBothNil(_color, color)) {
    _color = color;
    [self setNeedsDisplay:YES];
  }
}

- (void)setAlternateColor:(NSColor *)alternateColor {
  if (!AreEqualOrBothNil(_alternateColor, alternateColor)) {
    _alternateColor = alternateColor;
    [self setNeedsDisplay:YES];
  }
}

- (void)setUseAlternateColor:(BOOL)isUsingAlternateColor {
  if (_useAlternateColor != isUsingAlternateColor) {
    _useAlternateColor = isUsingAlternateColor;
    [self setNeedsDisplay:YES];
  }
}

@end
