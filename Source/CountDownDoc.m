//  CountDownDoc.m
//  CountDown
//
//  Created by David Phillip Oster on 9/08/2020.
//  Copyright David Phillip Oster Copyright 2020 . All rights reserved.
//

#import "CountDownDoc.h"

#import "CDError.h"
#import "GradientView.h"
#import "Heartbeat.h"
#import "NSTimer+CountDown.h"
#import "OnOffButton.h"
#import "StretchableTextView.h"
#import "StretchableImage.h"
#import "TimeFormatter.h"

@interface CountDownDoc()<HeartbeatProtocol, NSSoundDelegate>
@property IBOutlet GradientView *backgroundView;
@property IBOutlet StretchableTextView *timerView;
@property IBOutlet OnOffButton *onOffButton;
@property IBOutlet OnOffButton *infoButton;
@property IBOutlet NSTextField *summaryLabel;

@property IBOutlet NSWindow *details;
@property IBOutlet NSTextField *timeText;
@property IBOutlet NSTextField *summaryText;
@property IBOutlet NSButton *playSoundCheck;
@property IBOutlet NSPopUpButton *soundPopup;

@property TimeFormatter *timeFormat;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) int maxSeconds;
@property int seconds; // seconds remaining, when running.
@property int alarmPhase; // increments each time alarm timer runs.
@property (getter=isSoundOn) BOOL soundOn;
@property (copy) NSString *soundPath;
@property int requestUserID;
@property (nonatomic) NSDictionary *tempDoc;  // Used to hold values between read time and show time.

- (void)setTempDoc:(NSDictionary *)doc;
- (void)cancelUserAttention;
- (void)setPopUp:(NSPopUpButton *)popUp;
- (NSString *)soundsFolderInDomain:(short)theDomain;
- (void)fromDict:(NSDictionary *)dict;


- (void)setMaxSeconds:(int)maxSeconds;
- (State)state;
- (void)setState:(State)state;
- (void)setTimer:(NSTimer *)timer;

- (NSString *)summary;
- (void)setSummary:(NSString *)summary;


- (IBAction)popupDidChange:(id)sender;

- (IBAction)shortcutDidClick:(id)sender;

- (IBAction)toggleInfo:(id)sender;
- (BOOL)isInfoShowing;

- (BOOL)isTransient;
- (void)setTransient:(BOOL)isTransient;

@end

@implementation CountDownDoc
@synthesize state = _state;

- (id)init {
  self = [super init];
  if (self) {
    _timeFormat = [[TimeFormatter alloc] init];
  }
  return self;
}

- (void)dealloc {
  [Heartbeat.sharedInstance removeSubscriber:self];
  [self cancelUserAttention];
  [_timer invalidate];
}

- (void)awakeFromNib {
  if (nil == _timeFormat) {
    _timeFormat = [[TimeFormatter alloc] init];
  }
}


- (NSString *)windowNibName {
  // Override returning the nib file name of the document
  // If you need to use a subclass of NSWindowController or if your document
  // supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
  return @"CountDownDoc";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController {
  [super windowControllerDidLoadNib:aController];
  // Add any code here that needs to be executed once the windowController has loaded the document's window.
  [self.timerView setFontName:@"Helvetica"];
  [self.timerView setColor:[NSColor whiteColor]];
  [self.timerView setAlternateColor:[NSColor purpleColor]];

  NSFontManager *fm = [NSFontManager sharedFontManager];
  NSFont *font = [NSFont fontWithName:@"Helvetica" size:17.];
  font = [fm convertFont:font toHaveTrait:NSBoldFontMask];

  StateEntry *se = [[StateEntry alloc] init];
  NSImage *image = [NSImage imageNamed:@"GreenFrame"];
  [se setImage:[[StretchableImage alloc] initWithImage:image xSlice:16 ySlice:16]];
  [se setFont:font];
  [se setColor:[NSColor whiteColor]];
  [se setText:@"Start"];
  [_onOffButton insertObject:se inStateEntrysAtIndex:kIdleState];

  se = [[StateEntry alloc] init];
  image = [NSImage imageNamed:@"RedFrame"];
  [se setImage:[[StretchableImage alloc] initWithImage:image xSlice:16 ySlice:16]];
  [se setFont:font];
  [se setColor:[NSColor whiteColor]];
  [se setText:@"Cancel"];
  [_onOffButton insertObject:se inStateEntrysAtIndex:kRunningState];

  se = [[StateEntry alloc] init];
  image = [NSImage imageNamed:@"GrayFrame"];
  [se setImage:[[StretchableImage alloc] initWithImage:image xSlice:16 ySlice:16]];
  [se setFont:font];
  [se setColor:[NSColor whiteColor]];
  [se setText:@"Timer Fired"];
  [_onOffButton insertObject:se inStateEntrysAtIndex:kAlarmingState];

  [_onOffButton setTarget:self action:@selector(wasClicked:)];
  

  se = [[StateEntry alloc] init];
  image = [NSImage imageNamed:@"GrayFrame"];
  [se setImage:[[StretchableImage alloc] initWithImage:image xSlice:16 ySlice:16]];
  [se setFont:font];
  [se setColor:[NSColor whiteColor]];
  [se setText:@"Info"];
  [_infoButton insertObject:se inStateEntrysAtIndex:kIdleState];
  [_infoButton insertObject:se inStateEntrysAtIndex:kRunningState];
  [_infoButton insertObject:se inStateEntrysAtIndex:kAlarmingState];

  [_infoButton setTarget:self action:@selector(toggleInfo:)];


  if (nil == _tempDoc) {
    // initial default for new untitled documents is 5 minutes
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultDoc = [userDefaults objectForKey:@"defaultDoc"];
    [self setTempDoc:defaultDoc];
  }
  [self fromDict:_tempDoc];
  [self setTempDoc:nil];
  [self setState:kRunningState];
}

- (NSDictionary *)asDictionary {
  NSNumber *n = [NSNumber numberWithInt:_maxSeconds];
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    n, @"maxSeconds",
    [NSNumber numberWithBool:_soundOn], @"playSound",
    _soundPath, @"soundPath",
    nil];
  if ([self summary]) {
    [dict setObject:[self summary] forKey:@"summary"];
  }
  return dict;
}

- (void)fromDict:(NSDictionary *)dict {
  int tempMaxSeconds = 0;
  if (dict) {
    NSNumber *b = [dict objectForKey:@"playSound"];
    self.soundOn = [b boolValue];
    NSString *s = [dict objectForKey:@"soundPath"];
    [self setSoundPath:s]; 
    NSString *summary = [dict objectForKey:@"summary"];
    [self setSummary:summary];
    NSNumber *n = [dict objectForKey:@"maxSeconds"];
    tempMaxSeconds = [n intValue];
  }
  // initial default for new untitled documents is 5 minutes
  if (tempMaxSeconds <= 0) {
    tempMaxSeconds = 5*60;
  }
  [self setMaxSeconds:tempMaxSeconds];
}

- (void)removeCustomDocIconToURL:(NSURL *)url {
  NSWorkspace *ws = [NSWorkspace sharedWorkspace];
  [ws setIcon:nil forFile:[url path] options:0];
}

- (void)attachCustomDocIconToURL:(NSURL *)url {
  NSWorkspace *ws = [NSWorkspace sharedWorkspace];
  NSImage *docIcon = [[NSImage imageNamed:@"CountDoc.png"] copy];
  if (docIcon) {
    NSString *timeString = [self.timeFormat stringFromInt:self.maxSeconds];
    [docIcon lockFocus];
    NSRect bounds = NSMakeRect(101+4, 133, 313-2*4, 232);
    [[self.timerView class] draw:timeString color:self.timerView.color font:self.timerView.fontName bounds:bounds];
    [docIcon unlockFocus];
    [ws setIcon:docIcon forFile:[url path] options:0];
  }
}


- (BOOL)writeSafelyToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError {
  [self removeCustomDocIconToURL:url];
  BOOL result = [super writeSafelyToURL:url ofType:typeName forSaveOperation:saveOperation error:outError];
  if (result && [typeName isEqual:@"DocumentType"]) {
    [self attachCustomDocIconToURL:url];
  }
  return result;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
  NSData *result = nil;
  if ([typeName isEqual:@"DocumentType"]) {
    NSError *error = nil;
    NSDictionary *dict = [self asDictionary];
    result = [NSPropertyListSerialization
      dataWithPropertyList:dict
                    format:NSPropertyListXMLFormat_v1_0
                    options:0
                     error:&error];
    if (nil == result && outError) {
      *outError = error;
    }
  } else {
    if (outError) {
      *outError = ErrorUnknownFileType(typeName);
    }
  }
  return result;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
  BOOL result = NO;
  if ([typeName isEqual:@"DocumentType"]) {
    NSError *error = nil;
    NSDictionary *dict = [NSPropertyListSerialization 
        propertyListWithData:data
                     options:NSPropertyListImmutable
                      format:nil
                       error:&error];
    if (error) {
      if (outError) {
        *outError = error;
      }
    } else {
      [self setTempDoc:dict];
      result = YES;
    }
  } else {
    if (outError) {
      *outError = ErrorUnknownFileType(typeName);
    }
  }
  return result;
}

- (void)displayMaxSeconds {
  NSString *s = [_timeFormat stringFromInt:_maxSeconds];
  [_timerView setText:s];
}

- (void)setMaxSeconds:(int)maxSeconds {
  _maxSeconds = maxSeconds;
  _seconds = maxSeconds;
  [self displayMaxSeconds];
}

- (BOOL)isFrontDocumentWindow {
  NSArray *docs = [NSApp orderedDocuments];
  NSEnumerator *e = [docs objectEnumerator];
  CountDownDoc *doc;
  while (nil != (doc = [e nextObject])) {
    if (kIdleState != [doc state]) {
      return doc == self;
    }
  }
  return YES;
}

- (void)resetDisplay {
  if ([self isFrontDocumentWindow]) {
    NSImage *iconImage = [NSImage imageNamed:@"CountDown.icns"];
    [NSApp setApplicationIconImage:iconImage];
  }
  [self setTimer:nil];
  [self displayMaxSeconds];
}

- (void)cancelUserAttention {
  if (_requestUserID) {
    [NSApp cancelUserAttentionRequest:_requestUserID];
    _requestUserID = 0;
  }
}

- (void)enterRunningState {
  [_timerView setUseAlternateColor:NO];
  [self cancelUserAttention];
  _seconds = _maxSeconds;
  [Heartbeat.sharedInstance addSubscriber:self];
}

- (void)enterAlarmingState {
  [Heartbeat.sharedInstance removeSubscriber:self];
  _alarmPhase = 0;
  if (_soundOn && _soundPath) {
    _requestUserID = [NSApp requestUserAttention:NSCriticalRequest];
    NSSound *sound = [[NSSound alloc] initWithContentsOfFile:_soundPath byReference:YES];
    [sound setDelegate:self];
    [sound play];
  } else {
    [self setTimer:[NSTimer addedTimerWithTimeInterval:0.75 target:self selector:@selector(alarmAgainFired:) repeats:NO]];
  }
  [self displayMaxSeconds];
}

- (void)enterIdleState {
  [Heartbeat.sharedInstance removeSubscriber:self];
  [self cancelUserAttention];
  [_timerView setUseAlternateColor:NO];
  [self resetDisplay];
}

- (void)setState:(State)state {
  if (_state != state) {
    _state = state;
    [_onOffButton setState:state];

    switch(state) {
    case kRunningState:
      [self enterRunningState];
      break;
    case kAlarmingState:
      [self enterAlarmingState];
      break;
    case kIdleState:
      [self enterIdleState];
      break;
    }
  }
}

- (void)setTimer:(NSTimer *)timer {
  if (_timer != timer) {
    [_timer invalidate];
    _timer = timer;
  }
}

- (NSString *)summary {
  return [_summaryLabel stringValue];
}

- (void)setSummary:(NSString *)summary {
  [_summaryLabel setStringValue:summary];
}

- (void)drawDockImage {
  if ([self isFrontDocumentWindow]) {
    // without the copy, successive draws would dirty the image.
    NSImage *iconImage = [[NSImage imageNamed:@"Blank.icns"] copy];
    [iconImage lockFocus];
    NSRect bounds = NSMakeRect(3, 3, 118, 95);
    [_timerView drawInBounds:bounds];
    [iconImage unlockFocus];
    [NSApp setApplicationIconImage:iconImage];
  }
}

- (void)heartDidBeat {
  if (0 < _seconds) {
    --_seconds;
    NSString *s = [_timeFormat stringFromInt:_seconds];
    [_timerView setText:s];
    
    [self drawDockImage];
  } else {
    if (kRunningState == self.state) {
      [self setState:kAlarmingState];
    }
  }
}

- (void)windowWillClose:(NSNotification *)notify {
  [self setState:kIdleState];
  [self setTimer:nil];
  [_onOffButton setTarget:nil action:nil];
}

- (void)wasClicked:(OnOffButton *)button {
  int state = [button state];
  switch (state) {
  case kIdleState:      [self setState:kRunningState];  break;
  case kRunningState:
  case kAlarmingState:  [self setState:kIdleState]; break;
  }
}


- (void)insertText:(NSString *)insertString {
  if (kIdleState == self.state) {
    NSMutableString *s = [[_timeFormat stringFromInt:_maxSeconds] mutableCopy];
    [s appendString:insertString];
    id obj = nil;
    NSString *err = nil;
    if ([_timeFormat getObjectValue:&obj forString:s errorDescription:&err]) {
      int seconds = [obj intValue];
      if (0 < seconds) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[NSNumber numberWithInt:seconds] forKey:@"maxSeconds"];
        [self setMaxSeconds:seconds];
      }
    }
  }
}

- (void)deleteCharacter {
  if (kIdleState == self.state) {
    NSMutableString *s = [[_timeFormat stringFromInt:_maxSeconds] mutableCopy];
    NSArray *a = [s componentsSeparatedByString:@":"];
    s = [[a componentsJoinedByString:@""] mutableCopy];
    if (1 < [s length]) {
      [s deleteCharactersInRange:NSMakeRange([s length]-1, 1)];
    }
    id obj = nil;
    NSString *err = nil;
    if ([_timeFormat getObjectValue:&obj forString:s errorDescription:&err]) {
      int seconds = [obj intValue];
      [self setMaxSeconds:seconds];
    }
  }
}

#pragma mark -

- (NSString *)alarmTimeString {
  return [_timeFormat stringFromInt:_maxSeconds];
}

- (void)setAlarmTimeString:(NSString *)alarmTimeString {
  NSString *err = nil;
  id obj = nil;
  if ([_timeFormat getObjectValue:&obj forString:alarmTimeString errorDescription:&err]) {
    int seconds = [obj intValue];
    [self setMaxSeconds:seconds];
  }
}

- (NSString *)currentTimeString {
  switch (self.state) {
  case kIdleState:
    return [_timeFormat stringFromInt:_maxSeconds];
  case kRunningState:
    return [_timeFormat stringFromInt:_seconds];
  default:
  case kAlarmingState:
    return @"0";
  }
}

- (NSURL *)soundURL {
  NSURL *url = nil;
  if (_soundPath) {
    url = [NSURL fileURLWithPath:_soundPath];
  }
  return url;
}

- (void)setSoundURL:(NSURL*)soundURL {
  NSString *path = [soundURL path];
  if (path) {
    [self setSoundPath:path];
  }
}

- (BOOL)soundOn {
  return _soundOn;
}

- (void)setIsSoundOn:(BOOL)soundOn {
  _soundOn = soundOn;
}

- (void)setTempDoc:(NSDictionary *)doc {
  if (_tempDoc != doc) {
    _tempDoc = doc;
  }
}


- (OSType)timerState {
  switch (self.state) {
  default:
  case kIdleState:
    return 'Idle';
  case kRunningState:
    return 'Coun';
  case kAlarmingState:
    return 'Alrm';
  }
}

- (void)setTimerState:(OSType)timerState {
  switch (timerState) {
  case 'Idle':
    [self setState:kIdleState];
    break;
  case 'Coun':
    [self setState:kRunningState];
    break;
  case 'Alrm':
    [self setState:kAlarmingState];
    break;
  }
}

#pragma mark -

- (void)hideInfo {
  [NSApp endSheet:_details];
}

- (void)detailsEnd:(NSWindow *)sheet
        returnCode:(NSInteger)returnCode
       contextInfo:(void *)contextInfo {
  id obj = nil;
  if ([_timeFormat getObjectValue:&obj
                        forString:[_timeText stringValue]
                 errorDescription:nil]) {
    [self setSummary:[_summaryText stringValue]];
    [self setMaxSeconds:[obj intValue]];
    _soundOn = [_playSoundCheck state];
    NSMenuItem *item = [[_soundPopup itemArray] objectAtIndex:[_soundPopup indexOfSelectedItem]];
    NSString *path = [item representedObject];
    [self setSoundPath:path];
    NSDictionary *dict = [self asDictionary];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:dict forKey:@"defaultDoc"];
  }
  [_details orderOut:self];
  _details = nil;

  _timeText = nil;
  _playSoundCheck = nil;
  _soundPopup = nil;
}



- (void)showInfo {
  NSWindow *window = [self windowForSheet];
  NSNib *nib = [[NSNib alloc] initWithNibNamed:@"Details" bundle:nil];
  [nib instantiateWithOwner:self topLevelObjects:NULL];

  [self setTransient:NO];
  [_timeText setFormatter:_timeFormat];
  [_timeText setStringValue:[_timeFormat stringFromInt:_maxSeconds]];
  [_summaryText setStringValue:[self summary]];
  [_playSoundCheck setState:_soundOn];
  [self setPopUp:_soundPopup];

  [NSApp beginSheet:_details
     modalForWindow:window
      modalDelegate:self
     didEndSelector:@selector(detailsEnd:returnCode:contextInfo:)
        contextInfo:nil];
}

- (BOOL)isInfoShowing {
  return nil != _details;
}

- (IBAction)toggleInfo:(id)sender {
  if ([self isInfoShowing]) {
    [self hideInfo];
  } else {
    [self showInfo];
  }
}


- (IBAction)toggleOneTimer:(id)sender {
  if (kIdleState == _state) {
    [self setState:kRunningState];
  } else {
    [self setState:kIdleState];
  }
}


- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)didFinish {
  if (didFinish) {
    if (kAlarmingState == _state) {
      [_timerView setUseAlternateColor:![_timerView isUsingAlternateColor]];
      [self drawDockImage];
      [self setTimer:[NSTimer addedTimerWithTimeInterval:0.75 target:self selector:@selector(alarmAgainFired:) repeats:NO]];
    }
  }
}

- (void)alarmAgainFired:(NSTimer *)timer {
  if (kAlarmingState == _state) {
    ++_alarmPhase;
    NSSound *sound = nil;
    if (_soundOn && _soundPath) {
      sound = [[NSSound alloc] initWithContentsOfFile:_soundPath byReference:YES];
    }
    [_timerView setUseAlternateColor: ! [_timerView isUsingAlternateColor]];
    [self drawDockImage];
    if (sound) {
      [sound setDelegate:self];
      [sound play];
    } else {
      [self setTimer:[NSTimer addedTimerWithTimeInterval:0.5 target:self selector:@selector(alarmAgainFired:) repeats:NO]];
    }
  }
}


- (IBAction)popupDidChange:(id)sender {
  NSMenuItem *item = [[sender itemArray] objectAtIndex:[sender indexOfSelectedItem]];
  NSString *path = [item representedObject];
  NSSound *sound = [[NSSound alloc] initWithContentsOfFile:path byReference:YES];
  [sound setDelegate:self];
  [sound play];
}

- (IBAction)shortcutDidClick:(id)sender {
  _maxSeconds = [sender tag]*60;
  [_timeText setStringValue:[_timeFormat stringFromInt:_maxSeconds]];
  [self hideInfo];
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  if ([menuItem action] == @selector(toggleInfo:)) {
    if ([self isInfoShowing]) {
      [menuItem setTitle:NSLocalizedString(@"Hide Info", @"")];
    } else {
      [menuItem setTitle:NSLocalizedString(@"Show Info", @"")];
    }
  } 
  return YES;
}

- (NSString *)soundsFolderInDomain:(short)theDomain {
  FSRef folderRef;
  NSString *folderPath = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  OSErr err = FSFindFolder(theDomain, kSystemSoundsFolderType, kDontCreateFolder, &folderRef);
#pragma clang diagnostic pop
  if (noErr == err) {
    CFURLRef folderURL = CFURLCreateFromFSRef(kCFAllocatorSystemDefault, &folderRef);
    if (folderURL) {
      folderPath = (NSString *)CFBridgingRelease(CFURLCopyFileSystemPath(folderURL, kCFURLPOSIXPathStyle));
      CFRelease(folderURL);
    }
  }
  return folderPath;
}

#define COUNTOF(a) (sizeof(a)/sizeof(*a))

- (void)setPopUp:(NSPopUpButton *)popUp {
  [popUp removeAllItems];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  NSArray *soundFileTypes = [NSSound soundUnfilteredFileTypes];
#pragma clang diagnostic pop
  NSMutableArray *dirs = [NSMutableArray array];
  NSString *soundsDir;
  soundsDir = [[NSBundle mainBundle] resourcePath];
  if (soundsDir) {
    [dirs addObject:soundsDir];
  }
  int i, domains[] = {kUserDomain, kLocalDomain, kSystemDomain};
  for (i = 0; i < COUNTOF(domains); ++i) {
    soundsDir = [self soundsFolderInDomain:domains[i]];
    if (soundsDir) {
      [dirs addObject:soundsDir];
    }
  }
  NSEnumerator *dirEnumerator = [dirs objectEnumerator];
  NSString *dir;
  
  while ((dir = [dirEnumerator nextObject])) {
    NSString *soundFile;
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:NULL];
    NSEnumerator *soundEnumerator = [[dirContents pathsMatchingExtensions:soundFileTypes] objectEnumerator];
    while ((soundFile = [soundEnumerator nextObject])) {
      NSString *title = [soundFile stringByDeletingPathExtension];
      if (nil == [popUp itemWithTitle:title]) {
        [popUp addItemWithTitle:title];
        NSMenuItem *item = [[popUp itemArray] objectAtIndex:[popUp indexOfItemWithTitle:title]];
        [item setRepresentedObject:[dir stringByAppendingPathComponent:soundFile]];
      }
    }
  }
  int n;
  if (_soundPath && 0 <= (n = [popUp indexOfItemWithRepresentedObject:_soundPath])) {
    [popUp selectItemAtIndex:n];
  }
}


@end
