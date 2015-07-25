//
//  AppDelegate.h
//  KitchenSync
//
//  Created by tom on 21/07/2015.
//  Copyright (c) 2015 tom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSTextField *sourceFolder;
@property (weak) IBOutlet NSTextField *targetFolder1;
@property (weak) IBOutlet NSTextField *targetFolder2;
@property (weak) IBOutlet NSTextField *targetFolder3;
@property (weak) IBOutlet NSButton *includeHidden;
@property (weak) IBOutlet NSButton *verify;
@property (weak) IBOutlet NSButton *verifyOnly;
@property (weak) IBOutlet NSButton *autoFolderNaming;
@property (weak) IBOutlet NSTextField *autoFolderNamingString;
- (IBAction)doCopyVerify:(id)sender;
@property (weak) IBOutlet NSTextField *commandText;
- (IBAction)browseSourceFolder:(id)sender;
- (IBAction)browseTargetFolder1:(id)sender;
- (IBAction)browseTargetFolder2:(id)sender;
- (IBAction)browseTargetFolder3:(id)sender;

@end

