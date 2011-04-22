/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "AJP13Connection.h"
#import "AJP13ForwardRequest.h"
#import "AJP13Response.h"
#import "ServletRequestDispatcher.h"
#import "../../Vendor/CocoaAsyncSocket/GCDAsyncSocket.h"
#import "HttpSessionManager.h"
#import "../../Cookie.h"

@interface AJP13Connection(Private)

- (void)addInteger:(unsigned int)integer data:(NSMutableData *)data;
- (void)addString:(NSString *)string  data:(NSMutableData *)data;
- (void)writePacketHeader:(unsigned int)length;
- (NSNumber *)codeValueForHeaderName:(NSString *)name;
+ (NSData *)sendBodyChunckIdentifierData;

@end

@implementation AJP13Connection(Private)

- (void)writePacketHeader:(unsigned int)length
{
	[socket writeData:[NSData dataWithBytes:"AB" length:2] withTimeout:-1 tag:AJP_END_RESPONSE];
	NSMutableData	*lengthData = [NSMutableData data];
    
	[self addInteger:length data:lengthData];
	
	[socket writeData:lengthData withTimeout:-1 tag:AJP_WRITE_PACKET_HEADER];
}

- (void)addInteger:(unsigned int)integer data:(NSMutableData *)data
{
	if(integer > 65535) {
		NSLog(@"integer too big");
	}
	unsigned int b1 = (unsigned int)((integer >> 8) & 0x00FF);
	unsigned int b2 = (unsigned int)integer & 0x00FF;
	
	[data appendBytes:&b1 length:1];
	[data appendBytes:&b2 length:1];
}

- (void)addString:(NSString *)string  data:(NSMutableData *)data
{	
	NSData *stringData = [string dataUsingEncoding:NSISOLatin1StringEncoding];
	[self addInteger:[stringData length] data:data];
	
	[data appendData:stringData];
	
	unsigned char null = 0;
	[data appendBytes:&null length:1];
}

- (NSNumber *)codeValueForHeaderName:(NSString *)name
{
	NSString *upper = [name uppercaseString];
	
	if ([upper isEqualToString:@"CONTENT-TYPE"] == YES) {
		return [NSNumber numberWithInt:0xA001];
	}
	else if ([upper isEqualToString:@"CONTENT-LANGUAGE"] == YES) {
		return [NSNumber numberWithInt:0xA002];
	}
	else if ([upper isEqualToString:@"CONTENT-LENGTH"] == YES) {
		return [NSNumber numberWithInt:0xA003];
	}
	else if ([upper isEqualToString:@"DATE"] == YES) {
		return [NSNumber numberWithInt:0xA004];
	}
	else if ([upper isEqualToString:@"LAST-MODIFIED"] == YES) {
		return [NSNumber numberWithInt:0xA005];
	}
	else if ([upper isEqualToString:@"LOCATION"] == YES) {
		return [NSNumber numberWithInt:0xA006];
	}
	else if ([upper isEqualToString:@"SET-COOKIE"] == YES) {
		return [NSNumber numberWithInt:0xA007];
	}
	else if ([upper isEqualToString:@"SET-COOKIE2"] == YES) {
		return [NSNumber numberWithInt:0xA008];
	}
	else if ([upper isEqualToString:@"SERVLET-ENGINE"] == YES) {
		return [NSNumber numberWithInt:0xA009];
	}
	else if ([upper isEqualToString:@"STATUS"] == YES) {
		return [NSNumber numberWithInt:0xA00A];
	}
	else if ([upper isEqualToString:@"WWW-AUTHENTICATION"] == YES) {
		return [NSNumber numberWithInt:0xA00B];
	}
	else {
		return nil;
	}	
}

+ (NSData *)sendBodyChunckIdentifierData
{
	static NSData *identifier = nil;
	if (identifier == nil) {
		unsigned char i = AJP_SEND_BODY_CHUNK;
		identifier = [[NSData alloc] initWithBytes:&i length:1];
	}
	
	return identifier;
}

@end

@implementation AJP13Connection

- initWithAsyncSocket:(GCDAsyncSocket *)aSocket 
	   servletManager:(HttpServletManager *)aServletManager 
   defaultPageManager:(id<HttpDefaultPageManagers>)aDefaultPageManager
       sessionManager:(HttpSessionManager *)aSessionManager
{
	self = [super initWithAsyncSocket:aSocket 
                       servletManager:aServletManager 
                   defaultPageManager:aDefaultPageManager 
                       sessionManager:aSessionManager];
    [aSocket readDataToLength:5
			   withTimeout:-1
					   tag:AJP_PACKET_HEADER];
	return self;
}

- (void)dealloc
{	
	[super dealloc];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag
{
	const unsigned char* bytes = [data bytes];
	NSUInteger length = [data length];
	
	switch (tag) {
		case AJP_PACKET_HEADER:
			if([data length] != 5) {
				NSLog(@"packet header length [%lu] must be 5", length);
				[self die];
			}
			if(bytes[0] != 0x12 || bytes[1] != 0x34) {
				NSLog(@"unknown header prefix %x%x", bytes[0], bytes[1]);
				[self die];
			}
			
			currentPacketLenght = (int)bytes[2] << 8 | bytes[3];
			
			switch(bytes[4]) {
				case AJP_FORWARD_REQUEST:
					[socket readDataToLength:currentPacketLenght -1
								 withTimeout:-1
										 tag:AJP_FORWARD_REQUEST];
					break;
				default:
					NSLog(@"unknown data code %x", bytes[4]);
			}
			
			break;
		case AJP_FORWARD_REQUEST: {
			AJP13ForwardRequest *request = [[[AJP13ForwardRequest alloc] initWithData:data] autorelease];
			if(request == nil) {
				[self close];
			}
			[self processForwardRequest:request];
			break;
		}
		default:
			NSLog(@"Unknown data [%@] read", data);
	}
}

//processing ajp request
- (void)processForwardRequest:(AJP13ForwardRequest *)request
{	
    BOOL keepAlive = NO;
    AJP13Response	*ajpResponse = [[AJP13Response alloc] initWithConnection:self];

	[[ServletRequestDispatcher defaultDispatcher] dispatch:request 
                                                  response:ajpResponse 
                                            servletManager:servletManager 
                                            sessionManager:sessionManager
                                                 keepAlive:&keepAlive];	
    
    if(keepAlive == NO) {
        [self close];
    }
}

//ajp response messaging
- (void)sendHeaderWithStatusCode:(unsigned int)status 
                   statusMessage:(NSString *)message 
                          header:(NSDictionary *)header 
                         cookies:(NSArray *)cookies
{
	NSMutableData	*data = [NSMutableData data];
	unsigned char prefixCode = AJP_SEND_HEADER;
	[data appendBytes:&prefixCode length:1];
	[self addInteger:status data:data];
	[self addString:message data:data];
	[self addInteger:[header count] + [cookies count] data:data];
	
	NSEnumerator	*enumerator = [header keyEnumerator];
	NSString		*key;
	
	while ((key = [enumerator nextObject]) != nil) {
		NSString	*value = [header objectForKey:key];
		NSNumber	*number = [self codeValueForHeaderName:key];
		if(number != nil) {
			[self addInteger:[number intValue] data:data];
		}
		else {
			[self addString:key  data:data];
		}
		[self addString:value  data:data];
	}
    
    NSEnumerator    *cookieEnumerator = [cookies objectEnumerator];
    Cookie          *cookie;
    
    while ((cookie = [cookieEnumerator nextObject]) != nil) {
        
        NSString    *cookieEntry = [NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]];
        NSNumber	*number = [self codeValueForHeaderName:@"SET-COOKIE"];
        [self addInteger:[number intValue] data:data];
        [self addString:cookieEntry data:data];
    }
	[self writePacketHeader:[data length]];
	[socket writeData:data withTimeout:-1 tag:AJP_SEND_HEADER];

}

- (void)sendBodyChunk:(NSData *)chunk
{
	NSMutableData	*lengthData = [NSMutableData data];
	NSUInteger		length = [chunk length];

	[self addInteger:length  data:lengthData];

	[self writePacketHeader:length + 4];
	[socket writeData:[[self class] sendBodyChunckIdentifierData] withTimeout:-1 tag:AJP_SEND_BODY_CHUNK];
	[socket writeData:lengthData withTimeout:-1 tag:AJP_SEND_BODY_CHUNK];
	[socket writeData:chunk withTimeout:-1 tag:AJP_SEND_BODY_CHUNK];
	[socket writeData:[NSData dataWithBytes:"\x00" length:1] withTimeout:-1 tag:AJP_SEND_BODY_CHUNK];
}

- (void)sendEndResponse:(BOOL)reuse
{
	[self writePacketHeader:2];

	if(reuse == YES) {
		[socket writeData:[NSData dataWithBytes:"\x05\x01" length:2] withTimeout:-1 tag:AJP_END_RESPONSE];
		
	}
	else {
		[socket writeData:[NSData dataWithBytes:"\x05\x00" length:2] withTimeout:-1 tag:AJP_END_RESPONSE];
	}
}
	   
@end
