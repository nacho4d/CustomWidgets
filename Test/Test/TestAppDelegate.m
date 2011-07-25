//
//  TestAppDelegate.m
//  Test
//
//  Created by Ignacio Enriquez Gutierrez on 7/25/11.
//  Copyright 2011 Nacho4D. All rights reserved.
//

#import "TestAppDelegate.h"
#include <objc/runtime.h>

//Add this category just to get rid of the warnings
@interface NSButtonCell (_NSThemeWidgetCell) 
- (void)alt_drawWithFrame:(NSRect)frame inView:(id)view;
- (int)buttonID;
- (int)getState:(id)view;
@end

//function prototype & implementation
//this function will be added as a new method of _NSThemeWidgetCell class
//is done in C because _NSThemeWidgetCell is a private class and we don't have the headers
void drawWithFrameInView(id this, SEL this_cmd, NSRect frame, id view);
void drawWithFrameInView(id this, SEL this_cmd, NSRect frame, id view)
{   
	//NSLog(@"hacking drawWithFrameInView ...");
	
	NSString *imageName = @"titlebarcontrols_regularwin";
		
    //Get button ID
	int buttonID = (int)[this buttonID];
	NSLog(@"%d", buttonID);
    switch (buttonID)
    {
        case 127: // Close button
            imageName = [imageName stringByAppendingFormat:@"_close"];
            break;
        case 128: // Minimize button
            imageName = [imageName stringByAppendingFormat:@"_minimize"];
            break;
        case 129: // Zoom button
            imageName = [imageName stringByAppendingFormat:@"_zoom" ];
            break;
        case 130: // Toolbar button
            imageName = [imageName stringByAppendingFormat:@"_toolbar_button" ];
            break;
    }
	
	
	//Get System preferences: Window style: (Aqua or graphite)
	NSString * const kAppleAquaColorVariant = @"AppleAquaColorVariant";
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults addSuiteNamed:NSGlobalDomain];	
	NSNumber *color = [userDefaults objectForKey:kAppleAquaColorVariant];
	if ([color intValue] == 6) {//graphite is 6 
		imageName = [imageName stringByAppendingFormat:@"_graphite"];
	}else{//defaults to aqua, (aqua is 1)
		imageName = [imageName stringByAppendingFormat:@"_colorsryg"];
	}
	
	//Get button state
	if ([this respondsToSelector:@selector(getState:)]) {
		int state = (int)[this getState:view];
		//NSLog(@"state %d", state);
		switch (state) {
			//Known states
			//active = 0
			//activenokey = not used in Writer?
			//disabled = not used in Writer?
			//inactive = 3
			//pressed = 2
			//rollover = 1
			case 0: imageName = [imageName stringByAppendingFormat:@"_active"]; break;
			case 1: imageName = [imageName stringByAppendingFormat:@"_rollover"]; break;
			case 2: imageName = [imageName stringByAppendingFormat:@"_pressed"]; break;
			case 3: imageName = [imageName stringByAppendingFormat:@"_inactive"]; break;
			case 4: break;//is this disabled? activenokey?
			case 5: break;//is this disabled? activenokey?
			default: break;
		}

		NSImage *img = [NSImage imageNamed:imageName];
		if (img){
			[img dissolveToPoint:NSMakePoint(frame.origin.x, frame.origin.y + frame.size.height+0) fraction:1.0];
			//[img dissolveToPoint:frame.origin fraction:1.0];
		}else{
			[(NSButtonCell*)this alt_drawWithFrame:frame inView:view];//this is the original implementation 
		}
	}
}

@implementation TestAppDelegate

@synthesize window;


- (void)applicationWillFinishLaunching:(NSNotification *)notification
{

	Class class = NSClassFromString(@"_NSThemeWidgetCell");
	SEL new_selector = @selector(alt_drawWithFrame:inView:);
	SEL orig_selector = @selector(drawWithFrame:inView:);

	//Add a new method dinamically because _NSThemeWidgetCell is a private class
	BOOL success = class_addMethod(class, new_selector, (IMP)drawWithFrameInView, "v@:{CGRect={CGPoint=dd}{CGSize=dd}}@");
	if (success) {
		
		//Get the methods to exchange
		Method originalMethod = class_getInstanceMethod(class, orig_selector);
		Method newMethod = class_getInstanceMethod(class, new_selector);
		
		// If both are found, swizzle them
		if ((originalMethod != nil) && (newMethod != nil)){
			method_exchangeImplementations(originalMethod, newMethod);
		}
	}

	//TEST:a new method should appear "alt_drawWithFrame:inView:" in the console
	//uint methodCount = 0;
	//class = NSClassFromString(@"UIWebDocumentView");
	//Method *mlist = class_copyMethodList(class, &methodCount);
	//for (int i = 0; i < methodCount; ++i){
	//	NSLog(@"%@", NSStringFromSelector(method_getName(mlist[i])));
	//}

	//TEST: "hacking drawWithFrameInView ..." should appear in the console
	//NSButton *but = [window standardWindowButton:NSWindowZoomButton];
	//[[but cell] drawWithFrame:NSZeroRect inView:nil];

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

@end
