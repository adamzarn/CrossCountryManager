//
//  QuickRaces.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 9/9/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickRaces : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

