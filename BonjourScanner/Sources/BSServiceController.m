//
//  BSServiceController.m
//  BonjourScanner
//
//  Created by Iurii Skoliar on 7/26/13.
//  Copyright (c) 2013 Iurii Skoliar. All rights reserved.
//

#import "BSServiceController.h"

////////////////////////////////////////////////////////////////////////////////
@interface BSServiceController ()
{
   @private
      NSNetService *_service;
}

+ (NSArray *)keysArray;

@end

////////////////////////////////////////////////////////////////////////////////
static NSString *const kReusableCellIdentifier = @"ReusableCellIdentifier";
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
@implementation BSServiceController

- (id)initWithService:(NSNetService *)aService
{
   if (nil == aService)
   {
      [self release];
      self = nil;
   }
   else
   {
      self = [super init];
      if (nil != self)
      {
        _service = [aService retain];
      }
   }
   return self;
}

@synthesize service = _service;

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView
   numberOfRowsInSection:(NSInteger)aSection
{
   return [[[self class] keysArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView
   cellForRowAtIndexPath:(NSIndexPath *)aPath
{
   UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:
      kReusableCellIdentifier];
   if (nil == cell)
   {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
         reuseIdentifier:kReusableCellIdentifier] autorelease];
   }
   NSString *key = [[[self class] keysArray] objectAtIndex:[aPath row]];
   [[cell textLabel] setText:key];
   [[cell detailTextLabel] setText:[[[self service] valueForKey:key]
      description]];
   return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
   return 1;
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   [[self tableView] setAllowsSelection:NO];
}

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
   [_service release];
   [super dealloc];
}

#pragma mark -
#pragma mark BSServiceController ()

+ (NSArray *)keysArray
{
   static NSArray *sArray = nil;
   static dispatch_once_t sToken;
   dispatch_once(&sToken, ^
   {
       sArray = [[NSArray alloc] initWithObjects:@"addresses", @"domain",
         @"hostName", @"name", @"type", @"TXTRecordData", nil];
   });
   return sArray;
}

@end
