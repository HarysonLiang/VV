//
//  AppDelegate.m
//  V&V
//
//  Created by Haryson Liang on 12/6/14.
//  Copyright (c) 2014 MobileGameTree. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Setting.h"
#import "Language.h"

#ifdef ENABLE_VUNGLE
#import <VungleSDK/VungleSDK.h>
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[Setting getInstance] loadSetting];
    [Language loadLanguage];
#ifdef ENABLE_VUNGLE
    NSString* appID = @"942104029";
    VungleSDK *sdk = [VungleSDK sharedSDK];
    
    // start vungle publisher library
    [sdk startWithAppId:appID];
    [sdk setLoggingEnabled:YES];
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[ViewController sharedViewController] stopGame];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[ViewController sharedViewController] startGame];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[ViewController sharedViewController] stopGame];
}

@end
