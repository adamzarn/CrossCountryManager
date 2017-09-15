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
@property (nonatomic, strong) NSString *lap1;
@property (nonatomic, strong) NSString *lap2;
@property (nonatomic, strong) NSString *lap3;
@property (nonatomic, strong) NSString *meet;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *dateString;

- (id)init:(NSString *)name
      time:(NSString *)time
      pace:(NSString *)pace
      lap1:(NSString *)lap1
      lap2:(NSString *)lap2
      lap3:(NSString *)lap3;

@end

