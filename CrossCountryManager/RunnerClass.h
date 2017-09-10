//
//  Runner.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/17/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunnerClass : NSObject {
    
    
    
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *team;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *email2;
@property (nonatomic, strong) NSString *currentlyRunning;
@property (nonatomic, strong) NSString *currentTime;
@property (nonatomic, strong) NSString *lap1;
@property (nonatomic, strong) NSString *lap2;
@property (nonatomic, strong) NSString *lap3;
@property (nonatomic, strong) NSString *averageMileTime;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *photoOrientation;

- (id)init:(NSString *)name
      team:(NSString *)team
    gender:(NSString *)gender
     email:(NSString *)email
    email2:(NSString *)email2;

@end
