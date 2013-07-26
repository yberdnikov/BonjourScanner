//
//  BSServiceController.h
//  BonjourScanner
//
//  Created by Iurii Skoliar on 7/26/13.
//  Copyright (c) 2013 Iurii Skoliar. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////
//! Service controller.
@interface BSServiceController : UITableViewController

//! Initialize service controller.
//! @param aService Network service.
//! @returns Service controller.
- (id)initWithService:(NSNetService *)aService;

//! Network service.
@property (nonatomic, retain, readonly) NSNetService *service;

@end
