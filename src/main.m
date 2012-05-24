//
//  main.m
//  XCDataModelPrinter
//
//  Created by Chaitanya Gupta on 02/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "utils.h"
#import "MOMCompiler.h"
#import "MOMPrinter.h"

int main(int argc, const char * argv[])
{

  @autoreleasepool {
    if (argc == 2) {
      NSString *path = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
      MOMCompiler *compiler = [[[MOMCompiler alloc] init] autorelease];
      NSString *compiledPath = [compiler compilePath:path];
      if (compiledPath == nil) {
        return 2;
      }
      MOMPrinter *printer = [[[MOMPrinter alloc] init] autorelease];
      if (![printer printPath:compiledPath]) {
        return 2;
      }
    } else {
      NSPrintf(@"Usage: %@ path_to_xcdatamodel_file\n", [[NSProcessInfo processInfo] processName]);
      return 1;
    }
  }
  return 0;
}

