//
//  CommandHeader.m
//  FieldClock
//
//  Created by Bartimeus on 13.07.10.
//  Copyright 2010 Incoding.biz. All rights reserved.
//

#import "CommandHeader.h"


@implementation CommandHeader
@synthesize commandId;
@synthesize accountNumLength;
@synthesize accountNum;
@synthesize clockType; 
@synthesize majorVersionNum; 
@synthesize minorVersionNum; 
@synthesize buildVersionNum; 
@synthesize revisionVersionNum; 

- (NSMutableData *)createHeader:(short)_commandId
					 accountNum:(NSString *)_accountNum
					  clockType:(short)_clockType
				majorVersionNum:(short)_majorVersionNum
				minorVersionNum:(short)_minorVersionNum
				buildVersionNum:(short)_buildVersionNum
			 revisionVersionNum:(short)_revisionVersionNum;
{
	commandId = _commandId;
	accountNumLength = [_accountNum lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
	accountNum = _accountNum;
	clockType = _clockType;
	majorVersionNum = _majorVersionNum;
	minorVersionNum = _minorVersionNum;
	buildVersionNum = _buildVersionNum;
	revisionVersionNum = _revisionVersionNum;

	NSMutableData *h = [[NSMutableData alloc] init];
	
	unsigned short ss;
	ss = CFSwapInt16HostToBig(_commandId);
	[h appendBytes:(const void *)&ss length:2];
	
	ss = CFSwapInt16HostToBig([_accountNum length]);
	[h appendBytes:(const void *)&ss length:2];
	
	NSMutableString *str = [NSMutableString stringWithString:@""];
	if([_accountNum length] > 0)
	{
		if([_accountNum length] < 32)
		{
			[str appendString:_accountNum];
			for(int i = 0; i < (32 - [_accountNum length]); i++)
			{
				[str appendString:@" "];
			}
		}
		else 
		{
			NSMutableString *a = [NSMutableString stringWithString:_accountNum];
			NSRange range;
			range.location = 31;
			range.length = [_accountNum length] - 32;
			[a deleteCharactersInRange:range];
			str = [NSMutableString stringWithString:a];
		}

	}
	const uint8_t *strs = (uint8_t *) [str cStringUsingEncoding:NSASCIIStringEncoding];
	[h appendBytes:strs length:32];
	
	unsigned short oo;
	oo = CFSwapInt16HostToBig(_clockType);
	[h appendBytes:(const void *)&oo length:2];
	oo= CFSwapInt16HostToBig(_majorVersionNum);
	[h appendBytes:(const void *)&oo length:2];
	oo = CFSwapInt16HostToBig(_minorVersionNum);
	[h appendBytes:(const void *)&oo length:2];
	oo = CFSwapInt16HostToBig(_buildVersionNum);
	[h appendBytes:(const void *)&oo length:2];
	oo = CFSwapInt16HostToBig(_revisionVersionNum);
	[h appendBytes:(const void *)&oo length:2];
	
	return [h autorelease];}
@end
