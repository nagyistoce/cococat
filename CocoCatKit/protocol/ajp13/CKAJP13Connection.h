/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>
#import "../CKServletConnection.h"
#import "../CKSocket.h"

@class CKAJP13ForwardRequest;
@protocol CKHttpDefaultPageManagers;
@class CKHttpSessionManager;

@interface CKAJP13Connection : CKServletConnection 
{
	CKAJP13ForwardRequest	*currentRequest;
    NSString                *contextPath;
    NSMutableData           *currentPayload;
}

- initWithAsyncSocket:(CKSOCKET_CLASS *)aSocket 
	   servletManager:(CKHttpServletManager *)aServletManager 
   defaultPageManager:(id<CKHttpDefaultPageManagers>)aDefaultPageManager
       sessionManager:(CKHttpSessionManager *)aSessionManager
            contextPath:(NSString *)aContextPath;

- (void)dealloc;

- (void)socket:(CKSOCKET_CLASS *)sock didReadData:(NSData*)data withTag:(long)tag;

//processing ajp request
- (void)processForwardRequest:(CKAJP13ForwardRequest *)request;

//ajp response messaging
- (void)sendHeaderWithStatusCode:(unsigned int)status 
                   statusMessage:(NSString *)message 
                          header:(NSDictionary *)header 
                         cookies:(NSArray *)cookies;
- (void)sendBodyChunk:(NSData *)chunk;
- (void)getBodyChunk:(unsigned int)requestedLength;

- (void)sendEndResponse:(BOOL)reuse;
- (NSData *)readPayload;

@end
