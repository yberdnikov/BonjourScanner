//
//  BSAppDelegate.m
//  BonjourScanner
//
//  Created by Iurii Skoliar on 7/26/13.
//  Copyright (c) 2013 Iurii Skoliar. All rights reserved.
//

#import "BSAppDelegate.h"
#import "BSServicesController.h"

////////////////////////////////////////////////////////////////////////////////
@interface BSAppDelegate ()
{
   @private
      UIWindow *_window;
}

@end

#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation BSAppDelegate

#pragma mark -
#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)anApplication
   didFinishLaunchingWithOptions:(NSDictionary *)anOptions
{
   // Initialize window
   UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen]
      bounds]];
   [window setBackgroundColor:[UIColor whiteColor]];
   [self setWindow:window];
   [window release];

   // Initialize root view controller
   BSServicesController *servicesController = [BSServicesController new];
   UINavigationController *navigationController = [[UINavigationController
      alloc] initWithRootViewController:servicesController];
   [servicesController release];
   [window setRootViewController:navigationController];
   [navigationController release];

   // Show window
   [window makeKeyAndVisible];
   return YES;
}

@synthesize window = _window;

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
   [_window release];
   [super dealloc];
}

@end
