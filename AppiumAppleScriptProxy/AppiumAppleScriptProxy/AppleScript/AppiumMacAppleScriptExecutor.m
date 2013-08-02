//
//  AppiumMacAppleScriptLibrary.m
//  AppiumAppleScriptProxy
//
//  Created by Dan Cuellar on 7/28/13.
//  Copyright (c) 2013 Appium. All rights reserved.
//

#import "AppiumMacAppleScriptExecutor.h"

@implementation AppiumMacAppleScriptExecutor

- (id)init
{
    self = [super init];
    if (self) {
        [self setCurrentApplicationName:nil];
        [self setCurrentProcessName:nil];
        [self setFinder:[SBApplication applicationWithBundleIdentifier:@"com.apple.finder"]];
        [self setSystemEvents:[SBApplication applicationWithBundleIdentifier:@"com.apple.systemevents"]];
    }
    return self;
}

-(NSArray*) allProcesses
{
    NSMutableArray *processes = [NSMutableArray new];
    for(SystemEventsProcess *process in [self.systemEvents processes])
    {
        [processes addObject:[process name]];
    }
    return processes;
}

-(void) activateApplication:(NSString*)applicationName
{
    NSDictionary *errorDict;
    NSAppleScript *activateScript = [[NSAppleScript alloc] initWithSource:
        [NSString stringWithFormat:@"tell application \"%@\" to activate", applicationName]];
    [activateScript executeAndReturnError:&errorDict];
    // TODO: Add error handling
}

-(NSString*) applicationForProcessName:(NSString*)processName
{
    NSDictionary *errorDict;
    NSAppleScript *appForProcNameScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"System Events\"\nset process_bid to get the bundle identifier of process \"%@\"\nset application_name to file of (application processes where bundle identifier is process_bid)\nend tell\nreturn application_name", processName]];
    NSString *statusString = [[appForProcNameScript executeAndReturnError:&errorDict] stringValue];
    // TODO: Add error handling
    return statusString;
}


-(void) clickElement:(SystemEventsUIElement*)element
{
    [element clickAt:nil];
    // TODO: error handling
    // TODO: check if element is enabled (clickable)
}

-(SystemEventsProcess*) currentProcess
{
    return [self processForName:self.currentProcessName];
}

-(SystemEventsUIElement*) elementByName:(NSString*)name baseElement:(SystemEventsUIElement*)baseElement
{
    // check if this the element
    if (baseElement != nil && [baseElement.title isEqualToString:name])
    {
        // return the element if it matches
        return baseElement;
    }
    
    // search the children
    NSArray *elementsToSearch;
    if (baseElement != nil)
    {
        // search the children if this is an element
        elementsToSearch = baseElement.UIElements;
    }
    else
    {
        SystemEventsProcess *process = self.currentProcess;
        if (process != nil)
        {
            elementsToSearch = process.UIElements;
        }
    }
    
    if (elementsToSearch != nil)
    {
        for(SystemEventsUIElement* childElement in elementsToSearch)
        {
            // check the child
            SystemEventsUIElement *childResult = [self elementByName:name baseElement:childElement];
        
            //return the child if it matches
            if (childResult != nil)
            {
                return childResult;
            }
        }
    }
    
    // return nil because there was no match
    return nil;
}

-(NSString*) frontmostApplicationName
{
    NSDictionary *errorDict;
    NSAppleScript *frontMostApplicationScript = [[NSAppleScript alloc] initWithSource:
    @"tell application \"Finder\"\nset appPath to the path to the frontmost application\nset appName to the name of file appPath\nset appName to text 1 thru ((offset of \".\" in appName) - 1) of appName\nend tell"];
    NSString *statusString = [[frontMostApplicationScript executeAndReturnError:&errorDict] stringValue];
    // TODO: Add error handling
    return statusString;
}

-(NSString*) frontmostProcessName
{
    return [self processNameForApplicationName:self.frontmostApplicationName];
}

-(NSDictionary*) pageSource
{
    NSMutableArray *children = [NSMutableArray new];
    NSDictionary *source = [NSDictionary dictionaryWithObject:children forKey:@"source"];
    SystemEventsProcess *process = [self processForName:self.currentProcessName];
    if (process.name != nil)
    {
        for(SystemEventsUIElement *element in process.entireContents)
        {
            [children addObject:[NSString stringWithFormat:@"%@ %@", element.classDescription, element.name]];
            break;
        }
    }
    return source;
}

-(int) pidForProcessName:(NSString*)processName
{
    NSDictionary *errorDict;
    NSAppleScript *pidScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"System Events\" to return unix id of process \"%@\"", processName]];
    int pid = [[pidScript executeAndReturnError:&errorDict] int32Value];
    // TODO: Add error handling
    return pid;
    
}

-(SystemEventsProcess*) processForName:(NSString*)processName
{
    for (SystemEventsProcess *process in self.systemEvents.processes)
    {
        if ([process.name isEqualToString:processName])
        {
          return process;
        }
    }
    return nil;
}

-(NSString*) processNameForApplicationName:(NSString*) applicationName
{
    NSDictionary *errorDict;
    NSAppleScript *fronstMostProcessScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"System Events\"\nset application_id to (get the id of application \"%@\" as string)\nset process_name to name of (application processes where bundle identifier is application_id)\nend tell\nreturn item 1 of process_name as text", applicationName]];
    NSString *statusString = [[fronstMostProcessScript executeAndReturnError:&errorDict] stringValue];
    // TODO: Add error handling
    return statusString;
}

-(void) selectElement:(SystemEventsUIElement*)element
{
    [element select];
}

-(void) sendKeys:(NSString*)keys
{
    [self sendKeys:keys toElement:nil];
}

-(void) sendKeys:(NSString*)keys toElement:(SystemEventsUIElement*)element
{
    [self activateApplication:self.currentApplicationName];
    if (element != nil)
    {
        [self selectElement:element];
    }
    [self.systemEvents keystroke:keys using:0];
}

@end