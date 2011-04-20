/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


#import "HttpConnection.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "ServletRequestDispatcher.h"
#import "../../Vendor/CocoaAsyncSocket/GCDAsyncSocket.h"

@implementation HttpConnection

- initWithAsyncSocket:(GCDAsyncSocket *)aSocket servletManager:(HttpServletManager *)aServletManager
{
	self = [super initWithAsyncSocket:aSocket servletManager:aServletManager];
    [aSocket readDataToData:[[self class] headerSeparatorData] withTimeout:-1 tag:HTTP_PACKET_HEADER];

	return self;
}

- (void)dealloc
{	
	[super dealloc];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag
{	
	switch (tag) {
		case HTTP_PACKET_HEADER: {
            HttpRequest *request = [[[HttpRequest alloc] initWithData:data] autorelease];
			
			[self processRequest:request];
            break;
        }
        default:
			NSLog(@"Unknown data [%@] read", data);
    }
}

//processing http request
- (void)processRequest:(HttpRequest *)request
{	
    BOOL keepAlive = NO;
    HttpResponse	*httpResponse = [[HttpResponse alloc] initWithConnection:self];
    
	[[ServletRequestDispatcher defaultDispatcher] dispatch:request response:httpResponse servletManager:servletManager keepAlive:keepAlive];	
    
    if(keepAlive == NO) {
        [self close];
    }
}

+ (NSData *)headerSeparatorData
{
	return [NSData dataWithBytes:"\x0D\x0A\x0D\x0A" length:4];
}

@end
