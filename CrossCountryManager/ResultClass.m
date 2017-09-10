//
//  Result.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "ResultClass.h"

@implementation ResultClass

- (id)init:(NSString *)name time:(NSString *)time pace:(NSString *)pace email:(NSString *)email email2:(NSString *)email2 laps:(NSString *)laps {
    self = [super init];
    if (self) {
        self.name = name;
        self.time = time;
        self.pace = pace;
        self.email = email;
        self.email2 = email2;
        self.laps = laps;
    }
    return self;
}


@end
