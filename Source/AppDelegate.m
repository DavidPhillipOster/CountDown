//  AppDelegate.m
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

#import "AppDelegate.h"
#import "CountDownDoc.h"

@implementation AppDelegate

- (CountDownDoc *)firstActiveDoc {
  NSArray *docs = [NSApp orderedDocuments];
  NSEnumerator *e = [docs objectEnumerator];
  CountDownDoc *doc = nil;
  while (nil != (doc = [e nextObject])) {
    if (kIdleState != [doc state]) {
      return doc;
    }
  }
  return nil;
}

- (IBAction)toggleTimer:(id)sender {
  CountDownDoc *doc = [self firstActiveDoc];
  if (doc) {
    [doc toggleOneTimer:self];
  } else if (0 < [[NSApp orderedDocuments] count]){
    doc = (CountDownDoc *)[[NSApp orderedDocuments] objectAtIndex:0];
    [doc toggleOneTimer:self];
  }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  if ([menuItem action] == @selector(toggleTimer:)) {
    CountDownDoc *doc = [self firstActiveDoc];
    if (doc) {
      [menuItem setTitle:NSLocalizedString(@"Stop Timer", @"")];
    } else {
      [menuItem setTitle:NSLocalizedString(@"Start Timer", @"")];
    }
  }
  return 0 < [[NSApp orderedDocuments] count];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  [ud synchronize];
}


@end
