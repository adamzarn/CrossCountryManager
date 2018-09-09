//
//  CoachClass.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 9/8/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

#import "CoachClass.h"

@implementation CoachClass

- (id)init:(NSString *)name email:(NSString *)email email2:(NSString *)email2 {
    self = [super init];
    if (self) {
        self.name = name;
        self.email = email;
        self.email2 = email2;
    }
    return self;
}

@end

