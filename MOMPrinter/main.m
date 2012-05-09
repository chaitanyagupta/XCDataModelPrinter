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
  char ochar = [property isOptional] ? 'O' : ' ';
  char tchar = [property isTransient] ? 'T' : ' ';
  char ichar = [property isIndexed] ? 'I' : ' ';
  return [NSString stringWithFormat:@"%c%c%c", ochar, tchar, ichar];
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


// Field widths

#define WHeader 6
#define WEntityName 15
#define WPropName 25
#define WFlags 3

#define WAttrClassName 10

#define WRelToMany 6
#define WRelDeleteRule 7

// Calculating lengths

#define WRelTotal (WHeader + 1 \
  + WPropName + 1 \
  + WEntityName + 1 \
  + WPropName + 1 \
  + WRelToMany + 1 \
  + WRelDeleteRule + 1 \
  + WFlags)

#define WAttrTotal (WHeader + 1 \
  + WPropName + 1 \
  + WAttrClassName + 1 \
  + WFlags)

#define WFPrTotal (WHeader + 1 \
  + WPropName + 1 \
  + WFlags)

void printMOM(NSString *path) {
  NSURL *url = [NSURL fileURLWithPath:path];
  NSManagedObjectModel *model = [[[NSManagedObjectModel alloc] initWithContentsOfURL:url] autorelease];
  NSMutableArray *entities = [NSMutableArray arrayWithArray:[model entities]];
  [entities sortUsingComparator:^(id obj1, id obj2) {
    return [[obj1 name] compare:[obj2 name]];
  }];
  for (NSEntityDescription *entity in entities) {
    NSMutableString *entityStr = [NSMutableString stringWithFormat:@"Entity: %@", [entity name]];
    NSEntityDescription *superentity = [entity superentity];
    if (superentity) {
      [entityStr appendFormat:@" : %@", [superentity name]];
    }
    NSPrintf(@"%@ %*c %@\n", 
             entityStr,
             (WRelTotal - [entityStr length] - 1), ' ',
             [[entity versionHash] base64EncodedString]);
    NSMutableArray *properties = [NSMutableArray arrayWithArray:[entity properties]];
    [properties sortUsingComparator:^(id obj1, id obj2) {
      NSNumber *n1 = orderNumberForClassOfProperty(obj1);
      NSNumber *n2 = orderNumberForClassOfProperty(obj2);
      NSComparisonResult result =  [n1 compare:n2];
      if (result == NSOrderedSame) {
        return [[obj1 name] compare:[obj2 name]];
      } else {
        return result;
      }
    }];
    for (id property in properties) {
      const char *name = [[property name] UTF8String];
      const char *commonFlags = [commonFlagsStringForProperty(property) UTF8String];
      NSString *hash = [[property versionHash] base64EncodedString];
      if ([property isKindOfClass:[NSAttributeDescription class]]) {
        NSPrintf(@"  Att: %-*s %-*s %*c %-*s %@\n", 
                 WPropName, name,
                 WAttrClassName, [[property attributeValueClassName] UTF8String],
                 (WRelTotal - WAttrTotal - 1), ' ',
                 WFlags, commonFlags,
                 hash);
      } else if ([property isKindOfClass:[NSRelationshipDescription class]]) {
        NSPrintf(@"  Rel: %-*s %-*s %-*s %-*s %-*s %-*s %@\n",
                 WPropName, name,
                 WEntityName, [[[property destinationEntity] name] UTF8String],
                 WPropName, [[[property inverseRelationship] name] UTF8String],
                 WRelToMany, [property isToMany] ? "ToMany" : "",
                 WRelDeleteRule, [deleteRuleString([property deleteRule]) UTF8String],
                 WFlags, commonFlags,
                 hash);
      } else if ([property isKindOfClass:[NSFetchedPropertyDescription class]]) {
        NSPrintf(@"  FPr: %-*s %*c %-*s %@\n",
                 WPropName, name,
                 (WRelTotal - WFPrTotal - 1), ' ',
                 WFlags, commonFlags,
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

