//
//  Runner.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/17/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "RunnerClass.h"

@implementation RunnerClass

- (id)init:(NSString *)name team:(NSString *)team gender:(NSString *)gender email:(NSString *)email email2:(NSString *)email2 {
    self = [super init];
    if (self) {
        self.name = name;
        self.team = team;
        self.gender = gender;
        self.email = email;
        self.email2 = email2;
    }
    return self;
}


@end
