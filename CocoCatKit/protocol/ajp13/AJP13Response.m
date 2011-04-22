/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


#import "AJP13Response.h"
#import "AJP13Connection.h"


@implementation AJP13Response

- initWithConnection:(AJP13Connection *)aConnection
{
	connection = [aConnection retain];
	
	committed = NO;
		
	return self;
}

- (void)dealloc
{
	[connection release];
	
	[super dealloc];
}

- (void)sendHeaderWithStatusCode:(unsigned int)code message:(NSString *)message header:(NSDictionary *)header cookies:(NSArray *)cookies
{
	if (committed == YES) {
        [[NSException exceptionWithName:@"MessageCommittedException" reason:@"Can not send header, message already committed" userInfo:nil] raise];
	}
	
	[connection sendHeaderWithStatusCode:code statusMessage:message header:header cookies:cookies];
	
	committed = YES;
}

- (void)writeData:(NSData *)data
{
	static NSUInteger chunkSize = 8192 - 4; //max is - 4 [1 byte prefix code; 2 byte length field; 1 byte 0 byte] in ajp13 message
	
	NSUInteger length = 0;
	NSUInteger offset = 0;
	
	length = [data length];
	
	do {
		NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
		NSData* chunk = [NSData dataWithBytesNoCopy:(void*)[data bytes] + offset
											 length:thisChunkSize
									   freeWhenDone:NO];
		offset += thisChunkSize;

		[connection sendBodyChunk:chunk];

	} while (offset < length);
}

- (void)end:(BOOL)keepAlive
{	
	[connection sendEndResponse:keepAlive];
}

- (BOOL)isCommitted
{
	return committed;
}

- (id<HttpDefaultPageManagers>)defaultPageManager
{
	return [connection defaultPageManager];
}

@end
