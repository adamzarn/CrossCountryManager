//
//  AppDelegate.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/17/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property UITabBarController *myTabBarController;
@property UINavigationController * racesNavigationController;

@property UIColor *darkBlue;
@property UIColor *lightBlue;

- (void)saveContext:(NSManagedObjectContext *)context;
- (void)saveContext;

@end

