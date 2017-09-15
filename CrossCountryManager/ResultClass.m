//
//  Result.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "ResultClass.h"

@implementation ResultClass

- (id)init:(NSString *)name time:(NSString *)time pace:(NSString *)pace lap1:(NSString *)lap1 lap2:(NSString *)lap2 lap3:(NSString *)lap3 {
    self = [super init];
    if (self) {
        self.name = name;
        self.time = time;
        self.pace = pace;
        self.lap1 = lap1;
        self.lap2 = lap2;
        self.lap3 = lap3;
    }
    return self;
}


@end
