//
//  AboutTimePlusAppDelegate.h
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 24.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncCenter.h"
#import "AppSettings.h"
#import "ClockState.h"
#import "Reachability.h"
@interface AboutTimePlusAppDelegate : NSObject <UIApplicationDelegate> {
    BOOL isIphone;
    SyncCenter *sc;
    AppSettings *settings;
    ClockState *cs;
    Reachability* hostReach;
}
@property (nonatomic, retain) SyncCenter *sc;
@property (nonatomic, retain) ClockState *cs;
@property (nonatomic, retain) AppSettings *settings;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (assign) BOOL isIphone;
@property (nonatomic, retain) Reachability* hostReach;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)initAll;
@end
