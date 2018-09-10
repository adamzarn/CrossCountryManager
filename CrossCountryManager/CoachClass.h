//
//  CoachClass.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 9/8/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoachClass : NSObject {
    
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *email2;

- (id)init:(NSString *)name
     email:(NSString *)email
    email2:(NSString *)email2;

@end
