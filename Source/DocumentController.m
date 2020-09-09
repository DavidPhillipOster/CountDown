//  DocumentController.m
//  CountDown
//
//  Created by David Phillip Oster on 9/08/2020.
//  Copyright David Phillip Oster 2020 . All rights reserved.
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0

#import "DocumentController.h"
#import "CountDownDoc.h"

@implementation DocumentController

- (CountDownDoc *)transientDocumentToReplace {
    NSArray *documents = [self documents];
    CountDownDoc *transientDoc = nil;
    return ([documents count] == 1 && [(transientDoc = [documents objectAtIndex:0]) isTransient]) ? transientDoc : nil;
}

- (id)openDocumentWithContentsOfURL:(NSURL *)absoluteURL display:(BOOL)displayDocument error:(NSError **)outError {
  CountDownDoc *transientDoc = [self transientDocumentToReplace];
  [transientDoc close];
  return [super openDocumentWithContentsOfURL:absoluteURL display:displayDocument error:outError];
}

/* This method is overridden in order to support transient documents, i.e. the automatic closing of an automatically created untitled document, when a real document is opened. 
*/
- (id)openUntitledDocumentAndDisplay:(BOOL)displayDocument error:(NSError **)outError {
  CountDownDoc *doc = [super openUntitledDocumentAndDisplay:displayDocument error:outError];
  
  if ( ! doc) return nil;
  
  if ([[self documents] count] == 1) {
    // Determine whether this document might be a transient one
    // Check if there is a current AppleEvent. If there is, check whether
    // it is an open or reopen event. In that case, the document being created is transient.
    NSAppleEventDescriptor *evtDesc = [[NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
    AEEventID evtID = [evtDesc eventID];
    
    if (evtDesc && (evtID == kAEReopenApplication || evtID == kAEOpenApplication) && [evtDesc eventClass] == kCoreEventClass) {
      [doc setTransient:YES];
    }
  }
  return doc;
}

@end
