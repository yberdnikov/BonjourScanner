//
//  BSServicesController.m
//  BonjourScanner
//
//  Created by Iurii Skoliar on 7/26/13.
//  Copyright (c) 2013 Iurii Skoliar. All rights reserved.
//

#import "BSServicesController.h"
#import "BSServiceController.h"

////////////////////////////////////////////////////////////////////////////////
@interface BSServicesController () <NSNetServiceBrowserDelegate>
{
   @private
      NSMutableDictionary *_serviceMap;
      NSMutableArray *_serviceGroups;
      NSNetServiceBrowser *_browser;
}

@property (nonatomic, retain, readonly) NSMutableDictionary *serviceMap;
@property (nonatomic, retain, readonly) NSMutableArray *serviceGroups;
@property (nonatomic, retain, readonly) NSNetServiceBrowser *browser;

- (void)startSearchButtonAction:(id)aSender;
- (void)stopSearchButtonAction:(id)aSender;
- (void)updateSearchButtonWithSearch:(BOOL)aSearch animated:(BOOL)anAnimated;

@end

////////////////////////////////////////////////////////////////////////////////
static NSString *const kReusableCellIdentifier = @"ReusableCellIdentifier";
static NSString *const kSearchServiceType = @"_services._dns-sd._udp.";
static NSString *const kSearchDomain = @"";
////////////////////////////////////////////////////////////////////////////////

#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation BSServicesController

#pragma mark -
#pragma mark NSNetServiceBrowserDelegate

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aBrowser
{
   [self updateSearchButtonWithSearch:YES animated:YES];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aBrowser
{
   [self updateSearchButtonWithSearch:NO animated:YES];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser
   didNotSearch:(NSDictionary *)anErrorDict
{
   NSString *message = [[NSString alloc] initWithFormat:
      NSLocalizedString(@"ERROR_MESSAGE_FORMAT", nil), [anErrorDict
      objectForKey:NSNetServicesErrorCode], [anErrorDict objectForKey:
      NSNetServicesErrorDomain]];
   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
      NSLocalizedString(@"ERROR_TITLE", nil) message:
      message delegate:nil cancelButtonTitle:
      NSLocalizedString(@"ERROR_CANCEL_BUTTON_TITLE", nil) otherButtonTitles:
      nil];
   [message release];
   [alertView show];
   [alertView release];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser
   didFindService:(NSNetService *)aService moreComing:(BOOL)aFlag
{
   NSMutableDictionary *serviceMap = [self serviceMap];
   NSString *type = [aService type];
   NSMutableArray *services = [serviceMap objectForKey:type];
   if (nil == services)
   {
      // Add services list
      services = [[NSMutableArray alloc] initWithObjects:aService, nil];
      [serviceMap setValue:services forKey:type];
      [services release];

      // Add services group
      NSMutableArray *serviceGroups = [self serviceGroups];
      [serviceGroups addObject:type];
      [[self tableView] insertSections:[NSIndexSet
         indexSetWithIndex:[serviceGroups indexOfObject:type]] withRowAnimation:
         UITableViewRowAnimationAutomatic];
   }
   else
   {
      // Add service
      [services addObject:aService];
      [[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath
         indexPathForRow:[services indexOfObject:aService] inSection:[[self
         serviceGroups] indexOfObject:type]]] withRowAnimation:
         UITableViewRowAnimationAutomatic];
   }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser
   didRemoveService:(NSNetService *)aService moreComing:(BOOL)aFlag
{
   NSMutableDictionary *serviceMap = [self serviceMap];
   NSString *type = [aService type];
   NSMutableArray *services = [serviceMap objectForKey:type];
   if (1 == [services count])
   {
      // Remove services list
      [serviceMap removeObjectForKey:type];

      // Remove services group
      NSMutableArray *serviceGroups = [self serviceGroups];
      NSUInteger index = [serviceGroups indexOfObject:type];
      [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:index]
         withRowAnimation:UITableViewRowAnimationAutomatic];
      [serviceGroups removeObjectAtIndex:index];
   }
   else
   {
      // Remove service
      NSUInteger index = [services indexOfObject:aService];
      [[self tableView] deleteRowsAtIndexPaths:@[[NSIndexPath
         indexPathForRow:index inSection:[[self serviceGroups] indexOfObject:
         type]]] withRowAnimation:UITableViewRowAnimationAutomatic];
      [services removeObjectAtIndex:index];
   }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView
   numberOfRowsInSection:(NSInteger)aSection
{
   return [[[self serviceMap] objectForKey:[[self serviceGroups] objectAtIndex:
      aSection]] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView
   cellForRowAtIndexPath:(NSIndexPath *)aPath
{
   UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:
      kReusableCellIdentifier];
   if (nil == cell)
   {
      cell = [[[UITableViewCell alloc] initWithStyle:
         UITableViewCellStyleSubtitle reuseIdentifier:kReusableCellIdentifier]
         autorelease];
   }
   NSNetService *service = [[[self serviceMap] objectForKey:[[self
      serviceGroups] objectAtIndex:[aPath section]]] objectAtIndex:[aPath row]];
   [[cell textLabel] setText:[service name]];
   [[cell detailTextLabel] setText:[service domain]];
   return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
   return [[self serviceGroups] count];
}

- (NSString *)tableView:(UITableView *)aTableView
   titleForHeaderInSection:(NSInteger)aSection
{
   return [[self serviceGroups] objectAtIndex:aSection];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)aTableView
   didSelectRowAtIndexPath:(NSIndexPath *)aPath
{
   NSNetService *service = [[[self serviceMap] objectForKey:[[self
      serviceGroups] objectAtIndex:[aPath section]]] objectAtIndex:[aPath row]];
   BSServiceController *controller = [[BSServiceController alloc]
      initWithService:service];
   [[self navigationController] pushViewController:controller animated:YES];
   [controller release];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   [self updateSearchButtonWithSearch:NO animated:NO];
}

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
   [_browser setDelegate:nil];
   [_browser release];
   [_serviceGroups release];
   [_serviceMap release];
   [super dealloc];
}

#pragma mark -
#pragma mark BSServicesController ()

- (NSMutableDictionary *)serviceMap
{
   if (nil == _serviceMap)
   {
      _serviceMap = [NSMutableDictionary new];
   }
   return [[_serviceMap retain] autorelease];
}

- (NSMutableArray *)serviceGroups
{
   if (nil == _serviceGroups)
   {
      _serviceGroups = [NSMutableArray new];
   }
   return [[_serviceGroups retain] autorelease];
}

- (NSNetServiceBrowser *)browser
{
   if (nil == _browser)
   {
      _browser = [NSNetServiceBrowser new];
      [_browser setDelegate:self];
   }
   return [[_browser retain] autorelease];
}

- (void)startSearchButtonAction:(id)aSender
{
   [[self browser] searchForServicesOfType:kSearchServiceType inDomain:
      kSearchDomain];
}

- (void)stopSearchButtonAction:(id)aSender
{
   [[self browser] stop];
}

- (void)updateSearchButtonWithSearch:(BOOL)aSearch animated:(BOOL)anAnimated
{
   UIBarButtonItem *button = nil;
   if (aSearch)
   {
      button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
         UIBarButtonSystemItemStop target:self action:
         @selector(stopSearchButtonAction:)];
   }
   else
   {
      button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
         UIBarButtonSystemItemRefresh target:self action:
         @selector(startSearchButtonAction:)];
   }
   [[self navigationItem] setRightBarButtonItem:button animated:anAnimated];
   [button release];
}

@end
