//
//
//
//  Copyright 2010 Incoding. All rights reserved.
//


#import <sys/utsname.h>

/**
 @brief helper class to detects the device on which the program is running
 */
@interface STDeviceDetection : NSObject

enum {
    MODEL_UNKNOWN=0,/**< unknown model */
    MODEL_IPHONE_SIMULATOR,/**< iphone simulator */
    MODEL_IPHONE_SIMULATOR_RETINA,/**< iphone simulator retina */
    MODEL_IPAD_SIMULATOR,/**< ipad simulator */
    MODEL_IPOD_TOUCH_GEN1,/**< ipod touch 1st Gen */
    MODEL_IPOD_TOUCH_GEN2,/**< ipod touch 2nd Gen */
    MODEL_IPOD_TOUCH_GEN3,/**< ipod touch 3th Gen */
	MODEL_IPOD_TOUCH_GEN4,/**< ipod touch 3th Gen */
    MODEL_IPHONE,/**< iphone  */
    MODEL_IPHONE_3G,/**< iphone 3G */
    MODEL_IPHONE_3GS,/**< iphone 3GS */
    MODEL_IPHONE_4,	/**< iphone 4 */
	MODEL_IPAD/** ipad  */
};

/**
 get the id of the detected device
 */
+ (uint) detectDevice;
/**
 get the string for the detected device
 */
+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator;

@end
