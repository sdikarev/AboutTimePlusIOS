//
//  CommandHeader.h
//  FieldClock
//
//  Created by Bartimeus on 13.07.10.
//  Copyright 2010 Incoding.biz. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CommandHeader : NSObject {
	short commandId;
	short accountNumLength;
	NSString *accountNum;
	short clockType;
	short majorVersionNum;
	short minorVersionNum;
	short buildVersionNum;
	short revisionVersionNum;
}
@property (assign) short commandId;
@property (assign) short accountNumLength;
@property (nonatomic, retain) NSString *accountNum;
@property (assign) short clockType; 
@property (assign) short majorVersionNum; 
@property (assign) short minorVersionNum; 
@property (assign) short buildVersionNum; 
@property (assign) short revisionVersionNum; 
- (NSMutableData *)createHeader:(short)_commandId 
		accountNum:(NSString *)_accountNum
		 clockType:(short)_clockType
   majorVersionNum:(short)_majorVersionNum
   minorVersionNum:(short)_minorVersionNum
   buildVersionNum:(short)_buildVersionNum
revisionVersionNum:(short)_revisionVersionNum;
@end
