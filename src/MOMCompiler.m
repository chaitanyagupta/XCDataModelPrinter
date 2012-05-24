//
//  MOMCompiler.m
//  XCDataModelPrinter
//
//  Created by Chaitanya Gupta on 24/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MOMCompiler.h"
#import "utils.h"


#define MOMC_PATH_ENV_VAR @"MOMC_PATH"
#define XCODE_4_3_2_MOMC_PATH @"/Applications/Xcode.app/Contents/Developer/usr/bin/momc"
#define OLD_MOMC_PATH @"/Developer/usr/bin/momc"


NSString *tempDirectoryPath() {
  NSURL *tmpURL = [NSURL fileURLWithPath:@"/tmp/"];
  NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSItemReplacementDirectory
                                                      inDomain:NSUserDomainMask
                                             appropriateForURL:tmpURL
                                                        create:YES
                                                         error:NULL];
  return [url path];
}

NSString *findFileInPaths(NSArray *testPaths) {
  for (NSString *testPath in testPaths) {
    if ([[NSFileManager defaultManager] fileExistsAtPath:testPath]) {
      return testPath;
    }
  }
  return nil;
}

@implementation MOMCompiler

- (NSString *)compilePath:(NSString *)path {
  BOOL isDirectory;
  NSFileManager *dfm = [NSFileManager defaultManager];
  if (![dfm fileExistsAtPath:path isDirectory:&isDirectory]) {
    NSPrintError(@"%@ does not exist", path);
    return nil;
  }
  NSString *tmpdir = tempDirectoryPath();
  NSString *xcdatamodelDir;
  if (isDirectory) {
    xcdatamodelDir = path;
  } else {
    // assume .xcdatamodel/elements file is passed
    // create a .xcdatamodel directory inside tmpdir
    // and copy the elements file there
    xcdatamodelDir = [tmpdir stringByAppendingPathComponent:@"in.xcdatamodel"];
    NSError *error;
    if (![dfm createDirectoryAtPath:xcdatamodelDir withIntermediateDirectories:YES attributes:nil error:&error]) {
      NSPrintError(@"Couldn't create temporary .xcdatamodel directory\n%@", error);
      return nil;
    }
    if (![dfm copyItemAtPath:path toPath:[xcdatamodelDir stringByAppendingPathComponent:@"elements"] error:&error]) {
      NSPrintError(@"Couldn't copy elements file\n%@", error);
      return nil;
    }
  }
  NSString *outfile = [tmpdir stringByAppendingPathComponent:@"out.mom"];

  // Figure out the momc path
  NSMutableArray *trypaths = [NSMutableArray arrayWithObjects:XCODE_4_3_2_MOMC_PATH, OLD_MOMC_PATH, @"./momc", nil];
  NSString *envMomcPath = [[[NSProcessInfo processInfo] environment] objectForKey:MOMC_PATH_ENV_VAR];
  if (envMomcPath) {
    [trypaths insertObject:envMomcPath atIndex:0];
  }
  NSString *momc = findFileInPaths(trypaths);
  if (momc == nil) {
    NSPrintError(@"Couldn't find momc");
    return nil;
  }

  // Run momc to compile .xcdatamodel to .mom
  NSTask *task = [NSTask launchedTaskWithLaunchPath:momc arguments:[NSArray arrayWithObjects:xcdatamodelDir, outfile, nil]];
  [task waitUntilExit];
  int status = [task terminationStatus];
  if (status != 0) {
    NSPrintError(@"momc exited with status: %d", status);
    return nil;
  }
  return outfile;
}

@end
