//
//  RaceClass.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/21/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "RaceClass.h"

@implementation RaceClass

- (id)init:(NSString *)distance dateString:(NSString *)dateString meet:(NSString *)meet gender:(NSString *)gender team:(NSString *)team  group:(NSString *)group runnerOrder:(NSMutableArray *)runnerOrder status:(NSString *)status {
    self = [super init];
    if (self) {
        self.distance = distance;
        self.dateString = dateString;
        self.meet = meet;
        self.gender = gender;
        self.group = group;
        self.team = team;
        self.runnerOrder = runnerOrder;
        self.status = status;
    }
    return self;
}

@end

