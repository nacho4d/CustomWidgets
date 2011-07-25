//
//  TestAppDelegate.h
//  Test
//
//  Created by Ignacio Enriquez Gutierrez on 7/25/11.
//  Copyright 2011 Nacho4D. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TestAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
