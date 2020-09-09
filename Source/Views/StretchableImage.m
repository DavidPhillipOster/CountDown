//  StretchableImage.m
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

#import "StretchableImage.h"


@implementation StretchableImage {
  NSImage *_image;
  int     _xSlice;
  int     _ySlice;
}


- (id)init {
  return [self initWithImage:nil xSlice:0 ySlice:0];
}

- (id)initWithImage:(NSImage *)image xSlice:(int)x ySlice:(int)y {
  self = [super init];
  if (self) {
    _image = image;
    _xSlice = x;
    _ySlice = y;
  }
  return self;
}

enum {
  kTL, kTM, kTR,
  kML, kMM, kMR,
  kBL, kBM, kBR,
  kCOUNT
};


- (void)drawInRect:(NSRect)bounds operation:(NSCompositingOperation)op fraction:(float)delta {
  NSRect imageR[kCOUNT], r[kCOUNT];
  memset(imageR, 0, sizeof imageR);
  memset(r, 0, sizeof r);

  NSRect imageBounds;
  imageBounds.origin = NSZeroPoint;
  imageBounds.size = [_image size];
  if (1 <= _xSlice && _xSlice < bounds.size.width  && imageBounds.size.width < bounds.size.width &&
    1 <= _ySlice && _ySlice < bounds.size.height && imageBounds.size.height < bounds.size.height) {
      // 4 endcaps

     imageR[kTL] = NSMakeRect(imageBounds.origin.x, imageBounds.origin.y, _xSlice, _ySlice);
     r[kTL] = NSMakeRect(bounds.origin.x,bounds.origin.y, _xSlice, _ySlice);

     imageR[kTM] = NSMakeRect(imageBounds.origin.x + _xSlice, imageBounds.origin.y, 1, _ySlice);
     r[kTM] = NSMakeRect(bounds.origin.x + _xSlice, bounds.origin.y, bounds.size.width - (imageBounds.size.width-1), _ySlice);

     imageR[kTR] = NSMakeRect(imageBounds.origin.x + _xSlice + 1 , imageBounds.origin.y, imageBounds.size.width - (_xSlice+1), _ySlice);
     r[kTR] = NSMakeRect((bounds.origin.x + bounds.size.width) - (imageR[kTR].size.width), bounds.origin.y, imageR[kTR].size.width,_ySlice);


     imageR[kML] = NSMakeRect(imageBounds.origin.x, imageBounds.origin.y + _ySlice, _xSlice, 1);
     r[kML] = NSMakeRect(bounds.origin.x, bounds.origin.y + _ySlice, _xSlice, bounds.size.height - (imageBounds.size.height-1));

     imageR[kMM] = NSMakeRect(imageBounds.origin.x + _xSlice, imageBounds.origin.y + _ySlice, 1, 1);
     r[kMM] = NSMakeRect(bounds.origin.x + _xSlice, bounds.origin.y + _ySlice, bounds.size.width - (imageBounds.size.width-1), bounds.size.height - (imageBounds.size.height-1));

     imageR[kMR] = NSMakeRect(imageBounds.origin.x + _xSlice + 1, imageBounds.origin.y + _ySlice,imageBounds.size.width - (_xSlice+1), 1);
     r[kMR] = NSMakeRect((bounds.origin.x + bounds.size.width) - (imageR[kMR].size.width),
        bounds.origin.y + _ySlice,
        imageR[kMR].size.width,
        bounds.size.height - (imageBounds.size.height-1)); 


     imageR[kBL] = NSMakeRect(imageBounds.origin.x, imageBounds.origin.y + _ySlice + 1, _xSlice, imageBounds.size.height - (_ySlice + 1));
     r[kBL] = NSMakeRect(bounds.origin.x, (bounds.origin.y + bounds.size.height) - (imageR[kBL].size.height), _xSlice, imageR[kBL].size.height);

     imageR[kBM] = NSMakeRect(imageBounds.origin.x + _xSlice, imageBounds.origin.y + _ySlice + 1, 1, imageBounds.size.height - (_ySlice + 1));
     r[kBM] = NSMakeRect(bounds.origin.x + _xSlice, (bounds.origin.y + bounds.size.height) - (imageR[kBM].size.height), bounds.size.width - (imageBounds.size.width-1), imageR[kBM].size.height);

     imageR[kBR] = NSMakeRect(imageBounds.origin.x + _xSlice + 1, imageBounds.origin.y + _ySlice + 1, imageBounds.size.width - (_xSlice+1), imageBounds.size.height - (_ySlice + 1));
     r[kBR] = NSMakeRect((bounds.origin.x + bounds.size.width) - (imageR[kBR].size.width),
        (bounds.origin.y + bounds.size.height) - (imageR[kBR].size.height),
        imageR[kBR].size.width,
        imageR[kBR].size.height); 
  } else if (1 <= _xSlice && _xSlice < bounds.size.width && imageBounds.size.width < bounds.size.width) {
      // 2 endcaps horizontal just use top row.

     imageR[kTL] = NSMakeRect(imageBounds.origin.x, imageBounds.origin.y, _xSlice,imageBounds.size.height);
     r[kTL] = NSMakeRect(bounds.origin.x, bounds.origin.y, _xSlice, bounds.size.height);

     imageR[kTM] = NSMakeRect(imageBounds.origin.x+_xSlice,imageBounds.origin.y,1,imageBounds.size.height);
     r[kTM] = NSMakeRect(bounds.origin.x+_xSlice, bounds.origin.y, bounds.size.width - (imageBounds.size.width-1), bounds.size.height);

     imageR[kTR] = NSMakeRect(imageBounds.origin.x + _xSlice + 1,imageBounds.origin.y, imageBounds.size.width - (_xSlice+1), imageBounds.size.height);
     r[kTR] = NSMakeRect((bounds.origin.x + bounds.size.width) - (imageR[kTR].size.width), bounds.origin.y, imageBounds.size.width - (_xSlice+1), bounds.size.height);
  } else if (1 <= _ySlice && _ySlice < bounds.size.height && imageBounds.size.height < bounds.size.height) {
      // 2 endcaps vertical just use left column

     imageR[kTL] = NSMakeRect(imageBounds.origin.x, imageBounds.origin.y, imageBounds.size.width, _ySlice);
     r[kTL] = NSMakeRect(bounds.origin.x, bounds.origin.y, bounds.size.width, _ySlice);

     imageR[kML] = NSMakeRect(imageBounds.origin.x, imageBounds.origin.y + _ySlice, imageBounds.size.width, 1);
     r[kML] = NSMakeRect(bounds.origin.x, bounds.origin.y + _ySlice, bounds.size.width, bounds.size.height - (imageBounds.size.height - 1));

     imageR[kBL] = NSMakeRect(imageBounds.origin.x, imageBounds.origin.y + _ySlice + 1, imageBounds.size.width, imageBounds.size.height - (_ySlice + 1));
     r[kBL] = NSMakeRect(bounds.origin.x, (bounds.origin.y + bounds.size.height) - (imageR[kBL].size.height), bounds.size.width, imageBounds.size.height - (_ySlice + 1));
  } else {
    // simple stretch
    [_image drawInRect:bounds fromRect:imageBounds operation:op fraction:delta];
    return;
  }
  int i;
  for (i = 0; i < kCOUNT; ++i) {
    if (0 < imageR[i].size.width && 0 < imageR[i].size.height && 
        0 < r[i].size.width && 0 < r[i].size.height) {
      [_image drawInRect:r[i] fromRect:imageR[i] operation:op fraction:delta];
    }
  }
}

@end
