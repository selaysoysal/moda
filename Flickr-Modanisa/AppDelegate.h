//
//  AppDelegate.h
//  Flickr-Modanisa
//
//  Created by Selay Soysal on 26/04/2017.
//  Copyright © 2017 Selay Soysal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

