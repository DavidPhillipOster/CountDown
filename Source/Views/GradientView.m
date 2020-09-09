//  GradientView.m
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

#import "GradientView.h"
#import <ApplicationServices/ApplicationServices.h>

#define kRadialSize 1.0
#define kSquareBounds CGRectMake(-kRadialSize, -kRadialSize, kRadialSize * 2.0, kRadialSize * 2.0)

static CGPathRef GetSquarePath(){
	static CGMutablePathRef square = NULL;
	if(NULL == square){
		square = CGPathCreateMutable();
		CGPathAddRect(square, NULL, kSquareBounds);
	}
	return square;
}

// A simple utility function to return a Generic RGB colorspace that we don't have to release.
static CGColorSpaceRef GetGenericRGBColorspace() {
	static CGColorSpaceRef rgb = NULL;
	if(NULL == rgb){
		rgb = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	}
	return rgb;
}

typedef struct {
	// the start value is where in the domain this
	// color should be at full intensity.
	CGFloat start;
	// the color to present at the start point and to
	// interpolate with.
	CGFloat components[4];
} LinearColorSpec;

static void LinearColorEvaluator(void *inInfo, const CGFloat *inInputs, CGFloat *outOutputs) {
	// We assume 3 LinearColorSpecs, as that is what CreateShadingFunction creates.
	LinearColorSpec *colorInfo = (LinearColorSpec*)inInfo;
	CGFloat progression = inInputs[0];
	if(progression <= colorInfo[0].start) {
		memcpy(outOutputs, colorInfo[0].components, 4 * sizeof(CGFloat));
	} else if(progression <= colorInfo[1].start) {
		// progression is in the range of [color1Start, color2Start]. So we can calculate the correct
		// color we want a value between [0,1], so we convert the value of progression from the former domain
		// to the latter domain here.
		CGFloat value = (progression - colorInfo[0].start) / (colorInfo[1].start - colorInfo[0].start);
		int i;
		for(i = 0; i < 4; ++i) {
			// transition smoothly from color1 => color2
			outOutputs[i] = colorInfo[0].components[i] + value * (colorInfo[1].components[i] - colorInfo[0].components[i]);
		}
	} else if(progression <= colorInfo[2].start) {
		// progression is in the range of [color2Start, color3Start]. So we can calculate the correct
		// color we want a value between [0,1], so we convert the value of progression from the former domain
		// to the latter domain here.
		CGFloat value = (progression - colorInfo[1].start) / (colorInfo[2].start - colorInfo[1].start);
		int i;
		for(i = 0; i < 4; ++i) {
			// transition smoothly from color2 => color3
			outOutputs[i] = colorInfo[1].components[i] + value * (colorInfo[2].components[i] - colorInfo[1].components[i]);
		}
	} else {
		memcpy(outOutputs, colorInfo[2].components, 4 * sizeof(CGFloat));
	}
}

static void LinearColorReleaser(void *inInfo) {
	free(inInfo);
}


// This is basically a bubble sort implemented in our tiny tiny domain of 3 color specs.
// A more sophisticated sort wasn't used for various sundry reasons
// including that they are all overkill for sorting 3 numbers.
static void Sort(LinearColorSpec * specs) {
	LinearColorSpec temp;
	if(specs[0].start > specs[1].start) {
		temp = specs[0]; specs[0] = specs[1]; specs[1] = temp;
	}
	if(specs[1].start > specs[2].start) {
		temp = specs[1]; specs[1] = specs[2]; specs[2] = temp;
	}
	// spec[2] is definately largest at this point...
	if(specs[0].start > specs[1].start) {
		temp = specs[0]; specs[0] = specs[1]; specs[1] = temp;
	}
	// spec[1] is definately larger than spec[0], thus we are sorted.
}


static CGFunctionRef CreateShadingFunction(
	CGColorRef inColor1,
	CGFloat inColor1Start,
	CGColorRef inColor2,
	CGFloat inColor2Start,
	CGColorRef inColor3,
	CGFloat inColor3Start) {
	// Version 0, use LinearColorEvaluator to derive values, and LinearColorReleaser to clean up.
	static CGFunctionCallbacks callbacks = {0, &LinearColorEvaluator, &LinearColorReleaser};
	// Our domain (input) consists of 1 parameter whose values range from 0.0 to 1.0 inclusive.
	CGFloat domain[2] = {0.0, 1.0};
	// Our range (output) consists of 4 parameters whose values range from 0.0 to 1.0 inclusive.
	CGFloat range[8] = {0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0};
	// Allocate enough space for 3 color specs.
	LinearColorSpec * info = malloc(sizeof(LinearColorSpec) * 3);
	// Fill them out
	info[0].start = inColor1Start;
	info[1].start = inColor2Start;
	info[2].start = inColor3Start;
	memcpy(info[0].components, CGColorGetComponents(inColor1), sizeof(info[0].components));
	memcpy(info[1].components, CGColorGetComponents(inColor2), sizeof(info[1].components));
	memcpy(info[2].components, CGColorGetComponents(inColor3), sizeof(info[2].components));
	// Sort the specs - this mimics what CGGradientCreateWithColors does.
	Sort(info);
	
	// Create the function
	CGFunctionRef function = CGFunctionCreate(info, 1, domain, 4, range, &callbacks);
	if(NULL == function) {
		// if we have a failure, then clean up now, since our callback will not be called.
		LinearColorReleaser(info);
	}
	
	return function;
}


@implementation GradientView {
  CGFunctionRef shadingFunction_;
  CGShadingRef shading_;
  CGPoint startPoint_, endPoint_;
  BOOL extendStart_, extendEnd_;
}

-(void)dealloc {
	if (shading_) { CGShadingRelease(shading_); }
	if (shadingFunction_) { CGFunctionRelease(shadingFunction_); }
}

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
      // Initialization code here.
      startPoint_.x = 0;
      startPoint_.y = 1;
      endPoint_.x = 0;
      endPoint_.y = -1;
  }
  return self;
}

- (void)drawRect:(NSRect)rect {
  NSRect bounds = [self bounds];

	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];

	CGContextSaveGState(context);
	// Move 0,0 to the center of the view
	CGContextTranslateCTM(context, bounds.size.width / 2.0, bounds.size.height / 2.0);
	CGContextScaleCTM(context, bounds.size.width / 2.0, bounds.size.height / 2.0);
  CGContextAddPath(context, GetSquarePath());
  CGContextClip(context);
  if (NULL == shadingFunction_) {
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGFloat f1[] = {.3, .3, .3, 1};
    CGColorRef c1 = CGColorCreate(colorSpaceRef, f1);
    CGFloat f2[] = {.5, .5, .5, 1};
    CGColorRef c2 = CGColorCreate(colorSpaceRef, f2);
    CGFloat f3[] = {0, 0, 0, 1};
    CGColorRef c3 = CGColorCreate(colorSpaceRef, f3);
    shadingFunction_ = CreateShadingFunction(
      c1, .1,
      c2, .3,
      c3, .9);
    CGColorRelease(c1);
    CGColorRelease(c2);
    CGColorRelease(c3);
    CGColorSpaceRelease(colorSpaceRef);
  }
	if(NULL == shading_ && NULL != shadingFunction_) {
    shading_ = CGShadingCreateAxial(GetGenericRGBColorspace(), startPoint_, endPoint_, shadingFunction_, extendStart_, extendEnd_);
  }
	if(NULL != shading_){
		CGContextDrawShading(context, shading_);
	}
	CGContextRestoreGState(context);
}

@end
