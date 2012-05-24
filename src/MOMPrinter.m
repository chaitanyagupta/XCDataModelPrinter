//
//  MOMPrinter.m
//  XCDataModelPrinter
//
//  Created by Chaitanya Gupta on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MOMPrinter.h"
#import <CoreData/CoreData.h>
#import "NSData+Base64.h"
#import "utils.h"

@implementation MOMPrinter

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

NSString *attributeTypeString(NSAttributeType type) {
  switch (type) {
    case NSUndefinedAttributeType: return @"Undefined";
    case NSInteger16AttributeType: return @"Integer16";
    case NSInteger32AttributeType: return @"Integer32";
    case NSInteger64AttributeType: return @"Integer64";
    case NSDecimalAttributeType: return @"Decimal";
    case NSDoubleAttributeType: return @"Double";
    case NSFloatAttributeType: return @"Float";
    case NSStringAttributeType: return @"String";
    case NSBooleanAttributeType: return @"Boolean";
    case NSDateAttributeType: return @"Date";
    case NSBinaryDataAttributeType: return @"BinaryData";
    case NSTransformableAttributeType: return @"Transformable";
    case NSObjectIDAttributeType: return @"ObjectID";
    default: return nil;
  }
}

// Field widths

#define WHeader 6
#define WEntityName 15
#define WPropName 25
#define WFlags 3

#define WAttrTypeName 13

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
+ WAttrTypeName + 1 \
+ WFlags)

#define WFPrTotal (WHeader + 1 \
+ WPropName + 1 \
+ WFlags)

- (BOOL)printPath:(NSString *)path {
  NSFileManager *dfm = [NSFileManager defaultManager];
  if (![dfm fileExistsAtPath:path]) {
    NSPrintError(@"Cannot find file: %@", path);
    return NO;
  }
  NSURL *url = [NSURL fileURLWithPath:path];
  NSManagedObjectModel *model = [[[NSManagedObjectModel alloc] initWithContentsOfURL:url] autorelease];
  if (model == nil) {
    NSPrintError(@"Could not load model");
    return NO;
  }

  NSComparator nameCmptr = ^(id obj1, id obj2) {
    return [[obj1 name] caseInsensitiveCompare:[obj2 name]];
  };

  // Print entities
  NSArray *entities = [[model entities] sortedArrayUsingComparator:nameCmptr];
  for (NSEntityDescription *entity in entities) {
    NSMutableString *entityStr = [NSMutableString stringWithFormat:@"Entity: %@", [entity name]];
    NSEntityDescription *superentity = [entity superentity];
    if (superentity) {
      [entityStr appendFormat:@" : %@", [superentity name]];
    }
    [entityStr appendFormat:@" (%@)", [entity managedObjectClassName]];
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
                 WAttrTypeName, [attributeTypeString([property attributeType]) UTF8String],
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

  // Print Configurations
  NSArray *configurations = [[model configurations] sortedArrayUsingComparator:nameCmptr];
  for (NSString *configuration in configurations) {
    NSPrintf(@"Configuration: %@\n", configuration);
    for (NSEntityDescription *entity in [model entitiesForConfiguration:configuration]) {
      NSPrintf(@"  Entity: %@\n", [entity name]);
    }
    printf("\n");
  }

  // Print Fetch Requests
  NSDictionary *fetchRequestsByName = [model fetchRequestTemplatesByName];
  NSArray *names = [[fetchRequestsByName allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  for (NSString *name in names) {
    NSFetchRequest *request = [fetchRequestsByName objectForKey:name];
    NSPrintf(@"Fetch Request: %@\n", name);
    NSPrintf(@"  %@\n", request);
    printf("\n");
  }
  return YES;
}

@end
