//
//  main.m
//  MOMPrinter
//
//  Created by Chaitanya Gupta on 02/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSData+Base64.h"


void NSPrintf(NSString *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  NSString *outStr = [[[NSString alloc] initWithFormat:fmt arguments:args] autorelease];
  printf("%s", [outStr UTF8String]);
  va_end(args);
}

NSString *commonFlagsStringForProperty(NSPropertyDescription *property) {
  NSMutableString *str = [NSMutableString string];
  if ([property isOptional]) {
    [str appendString:@"O"];
  }
  if ([property isTransient]) {
    [str appendString:@"T"];
  }
  if ([property isIndexed]) {
    [str appendString:@"I"];
  }
  return str;
}

NSNumber *orderNumberForClassOfProperty(NSPropertyDescription *property) {
  if ([property isKindOfClass:[NSAttributeDescription class]]) {
    return [NSNumber numberWithInt:0];
  } else if ([property isKindOfClass:[NSRelationshipDescription class]]) {
    return [NSNumber numberWithInt:1];
  } else if ([property isKindOfClass:[NSFetchedPropertyDescription class]]) {
    return [NSNumber numberWithInt:2];
  } else {
    @throw @"Invalid property description passed";
  }
}

NSString *deleteRuleString(NSDeleteRule rule) {
  switch (rule) {
    case NSNoActionDeleteRule: return @"None";
    case NSNullifyDeleteRule:  return @"Nullify";
    case NSCascadeDeleteRule:  return @"Cascade";
    case NSDenyDeleteRule:     return @"Deny";
    default: @throw @"Invalid delete rule";
  }
}

void printMOM(NSString *path) {
  NSURL *url = [NSURL fileURLWithPath:path];
  NSManagedObjectModel *model = [[[NSManagedObjectModel alloc] initWithContentsOfURL:url] autorelease];
  NSArray *entities = [model entities];
  for (NSEntityDescription *entity in entities) {
    NSPrintf(@"Entity: %@", [entity name]);
    NSEntityDescription *superentity = [entity superentity];
    if (superentity) {
      NSPrintf(@" : %@", [superentity name]);
    }
    printf("\n");
    NSMutableArray *properties = [NSMutableArray arrayWithArray:[entity properties]];
    [properties sortUsingComparator:^(id obj1, id obj2) {
      NSNumber *n1 = orderNumberForClassOfProperty(obj1);
      NSNumber *n2 = orderNumberForClassOfProperty(obj2);
      return [n1 compare:n2];
    }];
    for (id property in properties) {
      const char *name = [[property name] UTF8String];
      const char *commonFlags = [commonFlagsStringForProperty(property) UTF8String];
      NSString *hash = [[property versionHash] base64EncodedString];
      if ([property isKindOfClass:[NSAttributeDescription class]]) {
        NSPrintf(@"  Att: %-25s %-10s %45c %-3s %@\n", 
                 name,
                 [[property attributeValueClassName] UTF8String],
                 ' ',
                 commonFlags,
                 hash);
      } else if ([property isKindOfClass:[NSRelationshipDescription class]]) {
        NSPrintf(@"  Rel: %-25s %-15s %-25s %-6s %-7s %-3s %@\n",
                 name,
                 [[[property destinationEntity] name] UTF8String],
                 [[[property inverseRelationship] name] UTF8String],
                 [property isToMany] ? "ToMany" : "",
                 [deleteRuleString([property deleteRule]) UTF8String],
                 commonFlags,
                 hash);
      } else if ([property isKindOfClass:[NSFetchedPropertyDescription class]]) {
        NSPrintf(@"  FPr: %-25s %56c %-3s %@\n",
                 name,
                 ' ',
                 commonFlags,
                 hash);
      }
    }
    printf("\n");
  }
}


int main(int argc, const char * argv[])
{
  
  @autoreleasepool {
    if (argc == 2) {
      NSString *path = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
      printMOM(path);
    }
  }
  return 0;
}

