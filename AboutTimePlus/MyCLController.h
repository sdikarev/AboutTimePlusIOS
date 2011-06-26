//
//  MyCLController.h
//  iFieldClock
//
//  Created by Bartimeus on 17.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyCLController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	CLLocation *currentCoord;
}

@property (nonatomic, retain) CLLocationManager *locationManager;  
@property (nonatomic, retain) CLLocation *currentCoord;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end
