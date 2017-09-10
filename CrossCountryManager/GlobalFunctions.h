//
//  GlobalFunctions.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/28/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RunnerClass.h"

@interface GlobalFunctions : NSObject {}

+ (NSArray *) getData:(NSString *)entity context:(NSManagedObjectContext *)context;
+ (NSArray *) getData:(NSString *)entity pred:(NSString *)pred context:(NSManagedObjectContext *)context;
+ (NSArray *) getData:(NSString *)entity pred:(NSString *)pred predArray:(NSArray *)predArray context:(NSManagedObjectContext *)context;
+ (RunnerClass *) getCurrentRunner:(NSString *)entity pred:(NSString *)pred name:(NSString *)name context:(NSManagedObjectContext *)context;
+ (NSString *)getAverageMileTime:(NSArray *)results;
+ (UIView *)configureTwoLineTitleView:(NSString *)topLine bottomLine:(NSString *)bottomLine;
+ (NSArray *)sortWithKey:(NSString *)key;
+ (NSString *) getFullPath:(NSString *)fileName;

@end
