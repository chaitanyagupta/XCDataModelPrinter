//
//  utils.m
//  XCDataModelPrinter
//
//  Created by Chaitanya Gupta on 24/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "utils.h"


void NSPrintf(NSString *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  NSString *outStr = [[[NSString alloc] initWithFormat:fmt arguments:args] autorelease];
  printf("%s", [outStr UTF8String]);
  va_end(args);
}
