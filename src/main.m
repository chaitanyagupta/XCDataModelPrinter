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

int run(NSString *path, BOOL includeSuperclassProperites);

int main(int argc, const char * argv[])
{
  @autoreleasepool {
    if (argc == 2) {
      NSString *path = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
    
      return run(path, YES);
        
    } else if (argc == 3) {
      NSString *parameter = [NSString stringWithCString:argv[1] encoding:NSASCIIStringEncoding];
      if ([parameter isEqualToString:@"--compact"] ||
          [parameter isEqualToString:@"-c"] ) {
        NSString *path = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
        
        return run(path, NO);
      }
    }
  }
    
  NSPrintf(@"Usage: [--compact] %@ path_to_xcdatamodel_file\n", [[NSProcessInfo processInfo] processName]);
  return 1;
}

int run(NSString *path, BOOL includeSuperclassProperites) {

    MOMCompiler *compiler = [[[MOMCompiler alloc] init] autorelease];
    NSString *compiledPath = [compiler compilePath:path];
    if (compiledPath == nil) {
        return 2;
    }
    MOMPrinter *printer = nil;
    
    if (includeSuperclassProperites) {
      printer = [[[MOMPrinter alloc] init] autorelease];
    } else {
      printer = [[[MOMPrinter alloc] initWithMode:MOMPrinterOmitSuperclassProperties] autorelease];
    }

    if (![printer printPath:compiledPath]) {
        return 2;
    }
    
    return 0;
}

