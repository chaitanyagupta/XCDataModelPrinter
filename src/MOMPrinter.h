//
//  MOMPrinter.h
//  XCDataModelPrinter
//
//  Created by Chaitanya Gupta on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MOMPrinterPropertiesOutputMode) {
    MOMPrinterIncludeSuperclassProperties = 1,
    MOMPrinterOmitSuperclassProperties = 2
};

@interface MOMPrinter : NSObject

- (id)initWithMode:(MOMPrinterPropertiesOutputMode)mode;

- (BOOL)printPath:(NSString *)path;

@end
