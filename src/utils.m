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

void NSFPrintf(FILE *stream, NSString *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  NSString *outStr = [[[NSString alloc] initWithFormat:fmt arguments:args] autorelease];
  fprintf(stream, "%s", [outStr UTF8String]);
  va_end(args);
}

void NSPrintError(NSString *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  NSString *processName = [[NSProcessInfo processInfo] processName];
  NSString *outStr = [[[NSString alloc] initWithFormat:fmt arguments:args] autorelease];
  fprintf(stderr, "%s: %s\n", [processName UTF8String], [outStr UTF8String]);
  va_end(args);
}
