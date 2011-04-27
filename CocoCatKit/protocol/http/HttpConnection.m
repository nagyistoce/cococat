/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


#import "HttpConnection.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "ServletRequestDispatcher.h"
#import "../../Vendor/CocoaAsyncSocket/GCDAsyncSocket.h"
#import "HttpSessionManager.h"

@implementation HttpConnection

- initWithAsyncSocket:(GCDAsyncSocket *)aSocket 
	   servletManager:(HttpServletManager *)aServletManager 
   defaultPageManager:(id<HttpDefaultPageManagers>)aDefaultPageManager
       sessionManager:(HttpSessionManager *)aSessionManager
{
	self = [super initWithAsyncSocket:aSocket 
                       servletManager:aServletManager 
                   defaultPageManager:aDefaultPageManager 
                       sessionManager:aSessionManager];
    [aSocket readDataToData:[[self class] headerSeparatorData] withTimeout:-1 tag:HTTP_PACKET_HEADER];

	return self;
}

- (void)dealloc
{	
	[currentRequest release];
    
    [super dealloc];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag
{	
    switch (tag) {
		case HTTP_PACKET_HEADER: {
            [currentRequest release];
            currentRequest = [[HttpRequest alloc] initWithData:data];
			if (currentRequest == nil) {
				[self close];
			}
            
            if ([[currentRequest method] isEqualToString:@"POST"] && [[[currentRequest header] objectForKey:@"Content-Type"] isEqualToString:@"application/x-www-form-urlencoded"] == YES) {
                unsigned int contentLength = [[[currentRequest header] objectForKey:@"Content-Length"] intValue];
                [self readParameterDataWithLength:contentLength];
            }
            else {
                [self processRequest:currentRequest];
            }
            break;
        }
        case HTTP_PACKET_PARAMS:
            [currentRequest setParameterData:data];
            [self processRequest:currentRequest];
            break;
        default:
            break;
    }
}

- (void)sendData:(NSData *)data
{
    [socket writeData:data withTimeout:-1 tag:HTTP_SEND_DATA];
}

- (void)readParameterDataWithLength:(unsigned int)length
{
    [socket readDataToLength:length
                 withTimeout:-1
                      buffer:nil
                bufferOffset:0
                         tag:HTTP_PACKET_PARAMS];    
}

//processing http request
- (void)processRequest:(HttpRequest *)request
{	
    HttpResponse	*httpResponse = [[HttpResponse alloc] initWithConnection:self];

    BOOL keepAlive = NO;
    //TODO fix keepAlive
	/*if ([[[request header] objectForKey:@"Connection"] isEqualToString:@"keep-alive"] == YES) {
		keepAlive = YES;
	}*/	
    
	[[ServletRequestDispatcher defaultDispatcher] dispatch:request 
                                                  response:httpResponse 
                                            servletManager:servletManager 
                                            sessionManager:sessionManager
                                                 keepAlive:&keepAlive];	
    
    if(keepAlive == NO) {
        [self close];
    }
    else {
        [socket readDataToData:[[self class] headerSeparatorData] withTimeout:-1 tag:HTTP_PACKET_HEADER];
    }
}

+ (NSData *)headerSeparatorData
{
	return [NSData dataWithBytes:"\x0D\x0A\x0D\x0A" length:4];
}

@end
