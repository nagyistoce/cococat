/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKAJP13Connection.h"
#import "CKAJP13ForwardRequest.h"
#import "CKAJP13Response.h"
#import "../../CKServletRequestDispatcher.h"
#ifdef CK_USEGCD
#import "../../Vendor/CocoaAsyncSocket/GCDAsyncSocket.h"
#else
#import "../../Vendor/CocoaAsyncSocket/AsyncSocket.h"
#endif
#import "../../CKHttpSessionManager.h"
#import "../../CKCookie.h"

//receiving messages from http server
#define CKAJP_PACKET_HEADER     0
#define CKAJP_FORWARD_REQUEST   2
#define CKAJP_SHUTDOWN          7
#define CKAJP_PING              8
#define CKAJP_CPING             10
#define CKAJP_DATA              -1

//sending messages to http server
#define CKAJP_WRITE_PACKET_HEADER		255
#define CKAJP_GET_BODY_CHUNCK_SIZE      100
#define CKAJP_SEND_BODY_CHUNK			3
#define CKAJP_SEND_HEADER				4
#define CKAJP_END_RESPONSE              5
#define CKAJP_GET_BODY_CHUNK			6

@interface CKAJP13Connection(Private)

- (void)addInteger:(unsigned int)integer data:(NSMutableData *)data;
- (void)addString:(NSString *)string  data:(NSMutableData *)data;
- (void)writePacketHeader:(unsigned int)length;
- (NSNumber *)codeValueForHeaderName:(NSString *)name;
+ (NSData *)sendBodyChunckIdentifierData;
+ (NSData *)getBodyChunckIdentifierData;

@end

@implementation CKAJP13Connection(Private)

- (void)writePacketHeader:(unsigned int)length
{
	[socket writeData:[NSData dataWithBytes:"AB" length:2] withTimeout:-1 tag:CKAJP_WRITE_PACKET_HEADER];
	NSMutableData	*lengthData = [NSMutableData data];
    
	[self addInteger:length data:lengthData];
	
	[socket writeData:lengthData withTimeout:-1 tag:CKAJP_WRITE_PACKET_HEADER];
}

- (void)addInteger:(unsigned int)integer data:(NSMutableData *)data
{
	if(integer > 65535) {
		NSLog(@"Internal error: integer [%d] too big. maximum [65535]", integer);
        [self close];
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
		unsigned char i = CKAJP_SEND_BODY_CHUNK;
		identifier = [[NSData alloc] initWithBytes:&i length:1];
	}
	
	return identifier;
}

+ (NSData *)getBodyChunckIdentifierData
{
	static NSData *identifier = nil;
	if (identifier == nil) {
		unsigned char i = CKAJP_GET_BODY_CHUNK;
		identifier = [[NSData alloc] initWithBytes:&i length:1];
	}
	
	return identifier;
}

@end

@implementation CKAJP13Connection

- initWithAsyncSocket:(CKSOCKET_CLASS *)aSocket 
	   servletManager:(CKHttpServletManager *)aServletManager 
   defaultPageManager:(id<CKHttpDefaultPageManagers>)aDefaultPageManager
       sessionManager:(CKHttpSessionManager *)aSessionManager
            contextPath:(NSString *)aContextPath
{
	self = [super initWithAsyncSocket:aSocket 
                       servletManager:aServletManager 
                   defaultPageManager:aDefaultPageManager 
                       sessionManager:aSessionManager];
    contextPath = [aContextPath retain];
    
    [aSocket readDataToLength:5
			   withTimeout:-1
					   tag:CKAJP_PACKET_HEADER];
	return self;
}

- (void)dealloc
{	
	[currentRequest release];
    [contextPath release];
    [currentPayload release];
    
	[super dealloc];
}

- (void)socket:(CKSOCKET_CLASS *)sock didReadData:(NSData*)data withTag:(long)tag
{
	const unsigned char* bytes = [data bytes];
	NSUInteger length = [data length];
	
	switch (tag) {
		case CKAJP_PACKET_HEADER:
			if (length < 4) {
				[self close];
				break;

			}
			if (bytes[0] != 0x12 || bytes[1] != 0x34) {
				[self close];
				break;
			}
			
			unsigned int currentPacketLength = (int)bytes[2] << 8 | bytes[3];
			
            if (currentRequest == nil) {
                switch (bytes[4]) {
                    case CKAJP_FORWARD_REQUEST:
                        [socket readDataToLength:currentPacketLength -1
                                     withTimeout:-1
                                             tag:CKAJP_FORWARD_REQUEST];
                        break;
                    default:
                        [self close];
                        break;
                }
            }
            else {
                //body chunck
                [socket readDataToLength:currentPacketLength
                             withTimeout:-1
                                     tag:CKAJP_GET_BODY_CHUNK];
            }
			
			break;
		case CKAJP_FORWARD_REQUEST: {
			[currentRequest release];
			currentRequest = [[CKAJP13ForwardRequest alloc] initWithData:data contextPath:contextPath];            
            if (currentRequest == nil) {
				[self close];
			}
            
            [currentPayload release];
            currentPayload = [[NSMutableData alloc] init];
            
            if ([[[currentRequest header] objectForKey:@"Content-Length"] intValue] > 0) {
                    [socket readDataToLength:4
                             withTimeout:-1
                                     tag:CKAJP_PACKET_HEADER];
            }
            else {
                @try {
                    [self processForwardRequest:currentRequest];
                }
                @finally {
                    [currentRequest release];
                    currentRequest = nil;
                }
            }
			break;
		}

		case CKAJP_GET_BODY_CHUNK: {
            //first bytes are the data chunck size
            [currentPayload appendData:[data subdataWithRange:NSMakeRange(2, [data length] - 2)]];

            unsigned int contentLength = [[[currentRequest header] objectForKey:@"Content-Length"] intValue];
            unsigned int remaining = contentLength - [currentPayload length];
            if(contentLength > [currentPayload length]) {
                unsigned int requestedLength  = remaining > 8186 ? 8186 : remaining;
                [self getBodyChunk:requestedLength];
            }
            else {
                if ([[[currentRequest header] objectForKey:@"Content-Type"] isEqualToString:@"application/x-www-form-urlencoded"] == YES) {
                    [currentRequest setParameterData:currentPayload];
                }
                @try {
                    [self processForwardRequest:currentRequest];
                }
                @finally {
                    [currentRequest release];
                    currentRequest = nil;
                }
            }
			
			break;
		}

		default: {
            [self close];
            break;
        }
	}
}

//processing ajp request
- (void)processForwardRequest:(CKAJP13ForwardRequest *)request
{	
    BOOL keepAlive = NO;
    if ([[[request header] objectForKey:@"Connection"] isEqualToString:@"keep-alive"] == YES) {
	 keepAlive = YES;
    }	
    CKAJP13Response	*ajpResponse = [[[CKAJP13Response alloc] initWithConnection:self] autorelease];
	
	[[CKServletRequestDispatcher defaultDispatcher] dispatch:request
                                                  connection:self
													response:ajpResponse 
											  servletManager:servletManager 
											  sessionManager:sessionManager
												   keepAlive:&keepAlive];	
    
    if(keepAlive == NO) {
        [self close];
    }
    else {
        [socket readDataToLength:5 withTimeout:-1 tag:CKAJP_PACKET_HEADER];   
    }
}

//ajp response messaging
- (void)sendHeaderWithStatusCode:(unsigned int)status 
                   statusMessage:(NSString *)message 
                          header:(NSDictionary *)header 
                         cookies:(NSArray *)cookies
{
	NSMutableData	*data = [NSMutableData data];
	unsigned char prefixCode = CKAJP_SEND_HEADER;
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
    CKCookie        *cookie;
    
    while ((cookie = [cookieEnumerator nextObject]) != nil) {
        
        NSString    *cookieEntry = [NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]];
        NSNumber	*number = [self codeValueForHeaderName:@"SET-COOKIE"];
        [self addInteger:[number intValue] data:data];
        [self addString:cookieEntry data:data];
    }
	[self writePacketHeader:[data length]];
	[socket writeData:data withTimeout:-1 tag:CKAJP_SEND_HEADER];

}

- (void)sendBodyChunk:(NSData *)chunk
{
	NSMutableData	*lengthData = [NSMutableData data];
	NSUInteger		length = [chunk length];

	[self addInteger:length  data:lengthData];

	[self writePacketHeader:length + 4];
	[socket writeData:[[self class] sendBodyChunckIdentifierData] withTimeout:-1 tag:CKAJP_SEND_BODY_CHUNK];
	[socket writeData:lengthData withTimeout:-1 tag:CKAJP_SEND_BODY_CHUNK];
	[socket writeData:chunk withTimeout:-1 tag:CKAJP_SEND_BODY_CHUNK];
	[socket writeData:[NSData dataWithBytes:"\x00" length:1] withTimeout:-1 tag:CKAJP_SEND_BODY_CHUNK];
}

- (void)getBodyChunk:(unsigned int)requestedLength
{
    NSMutableData	*lengthData = [NSMutableData data];    
    
	[self addInteger:requestedLength  data:lengthData];
    
	[self writePacketHeader:4];
	[socket writeData:[[self class] getBodyChunckIdentifierData] withTimeout:-1 tag:CKAJP_GET_BODY_CHUNK];
    [socket writeData:lengthData withTimeout:-1 tag:CKAJP_SEND_BODY_CHUNK];
    [socket writeData:[NSData dataWithBytes:"\x00" length:1] withTimeout:-1 tag:CKAJP_SEND_BODY_CHUNK];

    [socket readDataToLength:4
				 withTimeout:-1
						 tag:CKAJP_PACKET_HEADER];
}

- (void)sendEndResponse:(BOOL)reuse
{
	[self writePacketHeader:2];

	if(reuse == YES) {
		[socket writeData:[NSData dataWithBytes:"\x05\x01" length:2] withTimeout:-1 tag:CKAJP_END_RESPONSE];
	}
	else {
		[socket writeData:[NSData dataWithBytes:"\x05\x00" length:2] withTimeout:-1 tag:CKAJP_END_RESPONSE];
	}
}

- (NSData *)readPayload
{
    NSData *data = [[currentPayload retain] autorelease];
    currentPayload = nil;
    return data;
}
	   
@end
