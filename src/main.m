//
//  main.m
//  XCDataModelPrinter
//
//  Created by Chaitanya Gupta on 02/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOMPrinter.h"

int main(int argc, const char * argv[])
{
  
  @autoreleasepool {
    if (argc == 2) {
      NSString *path = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
      MOMPrinter *printer = [[[MOMPrinter alloc] init] autorelease];
      [printer printPath:path];
    }
  }
  return 0;
}

