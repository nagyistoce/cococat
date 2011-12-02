/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


#import "CKHttpConnection.h"
#import "CKHttpRequest.h"
#import "CKHttpResponse.h"
#import "../../CKServletRequestDispatcher.h"
#ifdef CK_USEGCD
#import "../../Vendor/CocoaAsyncSocket/GCDAsyncSocket.h"
#else
#import "../../Vendor/CocoaAsyncSocket/AsyncSocket.h"
#endif
#import "../../CKHttpSessionManager.h"

#define CKHTTP_PACKET_HEADER	0
#define CKHTTP_PACKET_PAYLOAD	1

#define CKHTTP_SEND_DATA        2


@implementation CKHttpConnection

- initWithAsyncSocket:(CKSOCKET_CLASS *)aSocket 
	   servletManager:(CKHttpServletManager *)aServletManager 
   defaultPageManager:(id<CKHttpDefaultPageManagers>)aDefaultPageManager
       sessionManager:(CKHttpSessionManager *)aSessionManager
               secure:(BOOL)isSecure
{
	self = [super initWithAsyncSocket:aSocket 
                       servletManager:aServletManager 
                   defaultPageManager:aDefaultPageManager 
                       sessionManager:aSessionManager];
    secure = isSecure;
    
    [aSocket readDataToData:[[self class] headerSeparatorData] withTimeout:-1 tag:CKHTTP_PACKET_HEADER];

	return self;
}

- (void)dealloc
{	
	[currentRequest release];
    [currentPayload release];
    
    [super dealloc];
}

- (void)socket:(CKSOCKET_CLASS *)sock didReadData:(NSData*)data withTag:(long)tag
{	
    switch (tag) {
		case CKHTTP_PACKET_HEADER: {
            [currentRequest release];

            currentRequest = [[CKHttpRequest alloc] initWithData:data secure:secure remoteAddr:[sock connectedHost]];
			if (currentRequest == nil) {
				[self close];
			}
            
            [currentPayload release];
            currentPayload = [[NSMutableData alloc] init];

            
            if([[[currentRequest header] objectForKey:@"Content-Length"] intValue] > 0) {
                [socket readDataToLength:[[[currentRequest header] objectForKey:@"Content-Length"] intValue]
                             withTimeout:-1
                                     tag:CKHTTP_PACKET_PAYLOAD];

            }
            else {
                [self processRequest:currentRequest];
            }

            break;
        }
        case CKHTTP_PACKET_PAYLOAD:
            [currentPayload appendData:data];
            [currentRequest setParameterData:data];
            if ([[[currentRequest header] objectForKey:@"Content-Type"] isEqualToString:@"application/x-www-form-urlencoded"] == YES) {
                [currentRequest setParameterData:currentPayload];
            }
            
            @try {
                [self processRequest:currentRequest];
            }
            @finally {
                [currentRequest release];
                currentRequest = nil;
            }
            break;
        default:
            break;
    }
}

- (void)sendData:(NSData *)data
{
    [socket writeData:data withTimeout:-1 tag:CKHTTP_SEND_DATA];
}

//processing http request
- (void)processRequest:(CKHttpRequest *)request
{	
    CKHttpResponse	*httpResponse = [[[CKHttpResponse alloc] initWithConnection:self] autorelease];

    BOOL keepAlive = NO;
	if ([[[request header] objectForKey:@"Connection"] isEqualToString:@"keep-alive"] == YES) {
		keepAlive = YES;
	}	
    
	[[CKServletRequestDispatcher defaultDispatcher] dispatch:request
                                                  connection:self
													response:httpResponse 
											  servletManager:servletManager 
											  sessionManager:sessionManager
												   keepAlive:&keepAlive];	    
    
    if(keepAlive == NO) {
        [self close];
    }
    else {
        [socket readDataToData:[[self class] headerSeparatorData] withTimeout:-1 tag:CKHTTP_PACKET_HEADER];
    }
}

+ (NSData *)headerSeparatorData
{
	static NSData   *headerSeparatorData = nil;
    
    if (headerSeparatorData == nil) {
        headerSeparatorData =  [[NSData alloc] initWithBytes:"\x0D\x0A\x0D\x0A" length:4];
    }
    
    return headerSeparatorData;
}

- (NSData *)readPayload
{
    NSData *data = [[currentPayload retain] autorelease];
    currentPayload = nil;
    return data;
}

@end
