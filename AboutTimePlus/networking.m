//
//  networking.m
//  FieldClock
//
//  Created by Bartimeus on 08.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "networking.h"

#import "NSStreamAdditions.h"
#import "Employee.h"

@implementation myNetWorking
@synthesize iStream;
@synthesize oStream;
NSMutableData *data;
     


-(void) connectToServerUsingStream:(NSString *)urlStr 
                            portNo: (uint) portNo {
	
	
    if (![urlStr isEqualToString:@""]) {
        NSURL *website = [NSURL URLWithString:urlStr];
        if (!website) {
            NSLog(@"%@ is not a valid URL");
            return;
        } else {
			 NSLog(@"valid URL");
            [NSStream getStreamsToHostNamed:urlStr 
                                       port:portNo 
                                inputStream:&iStream
                               outputStream:&oStream];            
            [iStream retain];
            [oStream retain];
			
            
            [iStream setDelegate:self];
            [oStream setDelegate:self];
            
            //[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            //[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            [oStream open];
            [iStream open];            
        }
	}    
}

//write to server sample data
-(void) writeToServer:(const uint8_t *) buf {
	NSUInteger i = strlen((char*)buf);
    [oStream write:buf maxLength:i];    
}

-(void)writeInt:(int)i
{
	unsigned int s2 = CFSwapInt32HostToBig(i);
	NSMutableData *h = [[[NSMutableData alloc] init] autorelease];
	[h appendBytes:(const void *)&s2 length:4];
	NSInteger l = [h length];
	[oStream write:[h bytes] maxLength:l]; 
	//[h release];
}

-(void)writeLong:(uint64_t)i
{
	uint64_t s2 = CFSwapInt64HostToBig(i);
	//CFSwappedFloat64 s2 = CFConvertDoubleHostToSwapped(i);
	//uint64_t t = s2.v;
	
	NSMutableData *h = [[[NSMutableData alloc] init] autorelease];
	[h appendBytes:(const void *)&s2 length:8];
	NSInteger l = [h length];
	[oStream write:[h bytes] maxLength:l]; 
	//[h release];
}

-(uint32_t)readIntFromServer
{
	//NSLog(@"Data received");
	
	NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	
	uint8_t buf[4];
	int len = 0;
	len = [iStream read:buf maxLength:4];
	if(len > 0 && len == 4) {    
		[data appendBytes:(const void *)buf length:len];
		
	}
	else {
		
		@try {
			if(len > 0)
			{
				[data appendBytes:(const void *)buf length:len];
				int len2 = 4 - len;
				uint8_t buf2[len2];
				int len3 = [iStream read:buf2 maxLength:len2];
				if(len3 > 0 && len3 == len2){
					[data appendBytes:(const void *)buf2 length:len3];
				} 
				else{
					if(len3 > 0){
						[data appendBytes:(const void *)buf2 length:len3];
						int len4 = len2 - len3;
						uint8_t buf3[len4];
						int len5 = [iStream read:buf3 maxLength:len4];
						[data appendBytes:(const void *)buf3 length:len5];
					}
				}
				
			}
			else {
				NSLog(@"int No data. len = %d", len);
				
				@throw [NSException
						exceptionWithName:@"readIntFromServer error"
						reason:@"Can't read from server"
						userInfo:nil];
			}
		}
		@catch (NSException * e) {
			@throw e;
		}
	
		
		
	}
	uint32_t p = 0;
	[data getBytes:&p length:sizeof(uint32_t)];
	uint32_t i = CFSwapInt32BigToHost(p);
	//NSLog(@"len = %d", len);
	//NSLog(@"number = %d", i);
	//[data release];
	return i;
	
}

-(double)readDoubleFromServer
{
	//NSLog(@"Data received");
	
	NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	
	uint8_t buf[8];
	unsigned int len = 0;
	len = [iStream read:buf maxLength:8];
	if(len > 0 && len == 8) {    
		[data appendBytes:(const void *)buf length:len];
	}
	else {
		if(len > 0)
		{
			[data appendBytes:(const void *)buf length:len];
			int len2 = 8 - len;
			uint8_t buf2[len2];
			int len3 = [iStream read:buf2 maxLength:len2];
			[data appendBytes:(const void *)buf2 length:len3];
		}
		else {
			NSLog(@" double No data. len = %d", len);
			@throw [NSException
					exceptionWithName:@"readDoubleFromServer error"
					reason:@"Can't read from server"
					userInfo:nil];
			return;
		}
	}
	
	CFSwappedFloat64 p;
	[data getBytes:&p length:sizeof(double)];
	double i = CFConvertDoubleSwappedToHost(p);
	//[data release];
	return i;
	
}

-(uint16_t)readShortFromServer
{
	//NSLog(@"Data received");
	
	NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	
	uint8_t buf[2];
	unsigned int len = 0;
	len = [iStream read:buf maxLength:2];
	if(len > 0 && len == 2) {    
		[data appendBytes:(const void *)buf length:len];
		
	} else {
		if(len > 0)
		{
			[data appendBytes:(const void *)buf length:len];
			int len2 = 2 - len;
			uint8_t buf2[len2];
			int len3 = [iStream read:buf2 maxLength:len2];
			[data appendBytes:(const void *)buf2 length:len3];
		}
		else {
			NSLog(@"short No data. len = %d", len);
			@throw [NSException
					exceptionWithName:@"readShortFromServer error"
					reason:@"Can't read from server"
					userInfo:nil];
			return;
		}
		
		
	}
	
	uint16_t p;
	[data getBytes:&p length:sizeof(unsigned short)];
	uint16_t i = CFSwapInt16BigToHost(p);
	//NSLog(@"len = %d", len);
	//NSLog(@"number = %d", i);
	//[data release];
	return i;
	
}

-(NSString *)readStringFromServer:(int)l
{
	NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	uint8_t buf[l];
	unsigned int len = 0;
	len = [iStream read:buf maxLength:l];
	if(len == l && len > 0) {    
		[data appendBytes:(const void *)buf length:len];

	} else {		
		if(len > 0)
		{
			[data appendBytes:(const void *)buf length:len];
			int len2 = l - len;
			uint8_t buf2[len2];
			int len3 = [iStream read:buf2 maxLength:len2];
			[data appendBytes:(const void *)buf2 length:len3];
		}
		else {
			NSLog(@"short No data. len = %d", len);
			@throw [NSException
					exceptionWithName:@"readStringFromServer error"
					reason:@"Can't read from server"
					userInfo:nil];
			return @"";
		}
	}
	
	NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	return [str autorelease];
}

/*[
//handle stream events
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    NSLog(@"handleEvent in networking");
    switch(eventCode) {
		case NSStreamEventHasSpaceAvailable:
		{
			NSLog(@"NSStreamEventHasSpaceAvailable");
		} break;
		case NSStreamEventErrorOccurred:
		{
			NSLog(@"NSStreamEventErrorOccurred");
		} break;
		case NSStreamEventEndEncountered:
		{
			NSLog(@"NSStreamEventEndEncountered");
		} break;	
        case NSStreamEventHasBytesAvailable:
        {
			NSLog(@"Data received");
            if (data == nil) {
                data = [[NSMutableData alloc] init];
            }
            uint8_t buf[8];
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:8];
            if(len) {    
                [data appendBytes:(const void *)buf length:len];
                int bytesRead;
                bytesRead += len;
            } else {
                NSLog(@"No data.");
            }
            
            NSString *str = [[NSString alloc] initWithData:data 
												  encoding:NSUTF8StringEncoding];
            NSLog(str);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"From server" 
                                                            message:str 
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
			
            [str release];
            [data release];        
            data = nil;
        } break;
    }
}
*/
//disconnect from server

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    //NSLog(@"stream:handleEvent: is invoked...");
	
    switch(eventCode) {
        case NSStreamEventErrorOccurred:
        {
            NSError *theError = [stream streamError];
            /*NSAlert *theAlert = [[NSAlert alloc] init]; // modal delegate releases
            [theAlert setMessageText:@"Error reading stream!"];
            [theAlert setInformativeText:[NSString stringWithFormat:@"Error %i: %@",
										  [theError code], [theError localizedDescription]]];
            [theAlert addButtonWithTitle:@"OK"];
            [theAlert beginSheetModalForWindow:[NSApp mainWindow]
								 modalDelegate:self
								didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
								   contextInfo:nil];*/
			NSLog(@"Error %i: %@",[theError code], [theError localizedDescription]);
			
            [stream close];
            [stream release];
            break;
        }
			// continued ....
    }
}

-(void) disconnect {
    [iStream close];
    [oStream close];
}

- (void)dealloc {

	[iStream release];
	[oStream release];
    [super dealloc];
}
@end
