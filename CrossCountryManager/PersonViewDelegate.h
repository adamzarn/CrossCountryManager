//
//  PersonViewDelegate.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 9/8/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PersonViewDelegate <NSObject>
@required
-(void)didPressSave;
-(void)didPressCancel;

@end
