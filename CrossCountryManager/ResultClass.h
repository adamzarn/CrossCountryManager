//
//  Result.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResultClass : NSObject {
    
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *pace;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *email2;
@property (nonatomic, strong) NSString *laps;
@property (nonatomic, strong) NSString *meet;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *dateString;

- (id)init:(NSString *)name
      time:(NSString *)time
      pace:(NSString *)pace
     email:(NSString *)email
    email2:(NSString *)email2
      laps:(NSString *)laps;

@end

