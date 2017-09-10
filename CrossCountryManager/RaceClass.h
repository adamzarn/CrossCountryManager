//
//  RaceClass.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/21/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RaceClass : NSObject {
    
}

@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, strong) NSString *meet;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *team;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSMutableArray *runnerOrder;
@property (nonatomic, strong) NSString *status;

- (id)init:(NSString *)distance
dateString:(NSString *)dateString
      meet:(NSString *)meet
    gender:(NSString *)gender
      team:(NSString *)team
     group:(NSString *)group
runnerOrder:(NSMutableArray *)runnerOrder
  status:(NSString *)status;

@end
