//
//  AppDelegate.m
//  KitchenSync
//
//  Created by tom on 21/07/2015.
//  Copyright (c) 2015 tom. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (NSString *)createCommandString
{
    NSMutableString *commandString = [NSMutableString stringWithString:@"KitchenSync.sh"];
    
    if(_includeHidden.state == NSOnState)
    {
        [commandString appendString:@" --include-hidden"];
    }
    
    if(_verify.state == NSOffState)
    {
        [commandString appendString:@" --no-checksums"];
    }
    
    if(_verifyOnly.state == NSOnState)
    {
        [commandString appendString:@" --checksums-only"];
    }
    
    if(_autoFolderNaming.state == NSOnState)
    {
        [commandString appendString:@" --auto-folder-naming"];
        [commandString appendString:@" \""];
        [commandString appendString:_autoFolderNamingString.stringValue];
        [commandString appendString:@"\""];
    }
    
    [commandString appendString:@" \""];
    [commandString appendString:_sourceFolder.stringValue];
    [commandString appendString:@"\""];
    
    [commandString appendString:@" \""];
    [commandString appendString:_targetFolder1.stringValue];
    [commandString appendString:@"\""];
    
    if(_targetFolder2.stringValue.length > 0)
    {
        [commandString appendString:@" \""];
        [commandString appendString:_targetFolder2.stringValue];
        [commandString appendString:@"\""];
    }
    
    if(_targetFolder3.stringValue.length > 0)
    {
        [commandString appendString:@" \""];
        [commandString appendString:_targetFolder3.stringValue];
        [commandString appendString:@"\""];
    }

    return commandString;
}

- (IBAction)doCopyVerify:(id)sender
{
    NSString *scriptPath = [[NSBundle mainBundle] pathForResource: @"KitchenSync.sh" ofType: nil];

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = scriptPath;
    NSMutableArray *arguments = [NSMutableArray array];
    
    if(_includeHidden.state == NSOnState)
    {
        [arguments addObject:@"--include-hidden"];
    }
    
    if(_verify.state == NSOffState)
    {
        [arguments addObject:@"--no-checksums"];
    }
    
    if(_verifyOnly.state == NSOnState)
    {
        [arguments addObject:@"--checksums-only"];
    }
    
    if(_autoFolderNaming.state == NSOnState)
    {
        NSString *arg = [NSString stringWithFormat:@"--auto-folder-naming \"%@\"", _autoFolderNamingString.stringValue];
        [arguments addObject:arg];
    }

    //NSString *arg = [NSString stringWithFormat:@"\"%@\"", _sourceFolder.stringValue];
    
    [arguments addObject:[NSString stringWithFormat:@"\"%@\"", _sourceFolder.stringValue]];
    [arguments addObject:[NSString stringWithFormat:@"\"%@\"", _targetFolder1.stringValue]];
    
    if(_targetFolder2.stringValue.length > 0)
    {
        [arguments addObject:[NSString stringWithFormat:@"\"%@\"", _targetFolder2.stringValue]];
    }
    
    if(_targetFolder3.stringValue.length > 0)
    {
        [arguments addObject:[NSString stringWithFormat:@"\"%@\"", _targetFolder3.stringValue]];
    }
    
    [task setArguments:arguments];
    
    _commandText.stringValue = [self createCommandString];
}

- (NSString *)browseForFolder
{
    __block NSString *path;
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    panel.canChooseDirectories = true;
    panel.canChooseFiles = false;
    panel.title = @"Choose directory";
    
    /*
    [panel beginWithCompletionHandler:^(NSInteger result)
    {
        if(result == NSFileHandlingPanelOKButton)
        {
            NSURL *url = [[panel URLs] objectAtIndex:0];
            path = url.path;
            
            NSLog(@"Path: %@", path);
        }
    }];
    */
    
    if([panel runModal] == NSFileHandlingPanelOKButton)
    {
        NSURL *url = [[panel URLs] objectAtIndex:0];
        path = url.path;
    }
    
    return path;
}

- (IBAction)browseSourceFolder:(id)sender
{
    _sourceFolder.stringValue = [self browseForFolder];
}

- (IBAction)browseTargetFolder1:(id)sender
{
    _targetFolder1.stringValue = [self browseForFolder];
}

- (IBAction)browseTargetFolder2:(id)sender
{
    _targetFolder2.stringValue = [self browseForFolder];
}

- (IBAction)browseTargetFolder3:(id)sender
{
    _targetFolder3.stringValue = [self browseForFolder];
}
@end
