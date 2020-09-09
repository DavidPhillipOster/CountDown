//  OnOffButton.m
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

#import "OnOffButton.h"
#import "StretchableImage.h"

@implementation StateEntry

- (void)drawRect:(NSRect)rect bounds:(NSRect)bounds isDown:(BOOL)isDown {
  // draw the background image

  // if isDown, draw it upside down.
  NSGraphicsContext *contextNS = isDown ? [NSGraphicsContext currentContext] : nil;
  [contextNS saveGraphicsState];
  CGContextRef context = [contextNS CGContext];
  if (context) {
    CGAffineTransform t = CGAffineTransformIdentity;
    CGRect r = bounds;
    t = CGAffineTransformTranslate(t, r.size.width/2, r.size.height/2);
    t = CGAffineTransformRotate(t, M_PI);
    t = CGAffineTransformTranslate(t, -r.size.width/2, -r.size.height/2);
    CGContextConcatCTM(context, t);
  }
  [_image drawInRect:bounds operation:NSCompositeSourceOver fraction:1.0];
  [contextNS restoreGraphicsState];

  // draw the top text
  NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
  [style setAlignment:NSCenterTextAlignment];
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
    style, NSParagraphStyleAttributeName,
    isDown ? [NSColor blackColor]: _color, NSForegroundColorAttributeName,
    _font, NSFontAttributeName,
    nil];
  float fontSize = [_font pointSize];
  bounds.origin.y += (fontSize - bounds.size.height)/2.;
  [_text drawInRect:bounds withAttributes:dict];
}


@end

@interface OnOffButton ()
@property NSMutableArray *stateEntrys;
@property BOOL isDown, isInside;
@property (weak) id target;
@property SEL sel;
@property int clickState;

@end

@implementation OnOffButton
@synthesize state = _state;

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _stateEntrys = [[NSMutableArray alloc] init];
  }
  return self;
}

- (BOOL)isOpaque {
  return NO;
}

- (void)drawRect:(NSRect)rect {
  NSRect bounds = [self bounds];
  int state = [self state];
  if (0 <= state && state < [self countOfStateEntrys]) {
    StateEntry *se = [self objectInStateEntrysAtIndex:state];
    [se drawRect:rect bounds:bounds isDown:_isDown && _isInside];
  } else {
    [[NSColor whiteColor] set];
    [NSBezierPath strokeRect:bounds];
  }
}

- (int)state {
  return _state;
}

- (void)setState:(int)state {
  if (_state != state) {
    _state = state;
    [self setNeedsDisplay:YES];
  }
}


// for Key Value Coding Compliance
- (NSUInteger)countOfStateEntrys {
  return [_stateEntrys count];
}

- (StateEntry *)objectInStateEntrysAtIndex:(NSUInteger)index {
  return [_stateEntrys objectAtIndex:index];
}

- (void)insertObject:(StateEntry *)se inStateEntrysAtIndex:(NSUInteger)index {
  return [_stateEntrys insertObject:se atIndex:index];
}

- (void)removeObjectFromStateEntrysAtIndex:(NSUInteger)index {
  [_stateEntrys removeObjectAtIndex:index];
}

- (void)mouseDown:(NSEvent *)currentEvent {
  _clickState = _state;
  _isDown = YES;
  NSRect bounds = [self bounds];
  do {
    NSPoint mousePoint = [self convertPoint:[currentEvent locationInWindow] fromView:nil];
    switch ([currentEvent type]) {
      case NSLeftMouseDown:
	    case NSLeftMouseDragged:
        {
          BOOL isInside = NSPointInRect(mousePoint, bounds);
          if (_isInside != isInside) {
            _isInside = isInside;
            [self setNeedsDisplay:YES];
          }
        }
        break;
	    default:
        // If we find anything other than a mouse dragged (mouse up) we are done.
        if (_isInside) {
          _isInside = NO;
          [self setNeedsDisplay:YES];
          if (_target && _sel) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_target performSelector:_sel withObject:self];
#pragma clang diagnostic pop
          }
        }
        return;
    }
  } while (nil != (currentEvent = 
    [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask  | NSLeftMouseUpMask) 
                               untilDate:[NSDate distantFuture]
                                  inMode:NSEventTrackingRunLoopMode
                                 dequeue:YES]));
}

#if 0
- (void)mouseEntered:(NSEvent *)theEvent {
  _isInside = YES;
  [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
  _isInside = NO;
  [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
  if (_isDown && _isInside && _sel && _clickState == _state) {
    [_target performSelector:_sel withObject:self];
  }
  _isDown = NO;
  _isInside = NO;
  [self setNeedsDisplay:YES];
}
#endif

- (void)setTarget:(id)target action:(SEL)sel {
  _target = target;
  _sel = sel;
}


@end
