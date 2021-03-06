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
+ (RunnerClass *) getCurrentRunner:(NSString *)name context:(NSManagedObjectContext *)context;
+ (NSString *)getAverageMileTime:(NSArray *)results;
+ (double)getSecondsPerMile:(NSString *)averageMileTime;
+ (UIView *)configureTwoLineTitleView:(NSString *)topLine bottomLine:(NSString *)bottomLine;
+ (NSArray *)sortWithKey:(NSString *)key;
+ (NSString *) getFullPath:(NSString *)fileName;
+ (NSString *) getLapString:(NSString *)lap1 lap2:(NSString *)lap2 lap3:(NSString *)lap3;
+ (NSString *) getGroup:(NSInteger)g t:(NSInteger)t;
+ (NSString *) getPredicate:(NSInteger)g t:(NSInteger)t;
+ (NSString *) getPredicate:(NSString *)indices;
+ (NSString *) getIndicesFromGroup:(NSString *)group;

@end
