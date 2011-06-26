//
//  AboutTimePlusAppDelegate.h
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 24.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutTimePlusAppDelegate : NSObject <UIApplicationDelegate> {
    BOOL isIphone;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (assign) BOOL isIphone;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
