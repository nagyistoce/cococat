/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>
#import "../CKServletConnection.h"
#import "../CKSocket.h"

//receiving messages from http server
#define CKAJP_PACKET_HEADER     0
#define CKAJP_FORWARD_REQUEST   2
#define CKAJP_SHUTDOWN          7
#define CKAJP_PING              8
#define CKAJP_CPING             10
#define CKAJP_DATA              -1

//sending messages to http server
#define CKAJP_WRITE_PACKET_HEADER		255
#define CKAJP_SEND_BODY_CHUNK			3
#define CKAJP_SEND_HEADER				4
#define CKAJP_END_RESPONSE              5
#define CKAJP_GET_BODY_CHUNK			6
#define CKAJP_GET_PARAM_BODY_CHUNK      7

@class CKAJP13ForwardRequest;
@protocol CKHttpDefaultPageManagers;
@class CKHttpSessionManager;

@interface CKAJP13Connection : CKServletConnection 
{
	CKAJP13ForwardRequest	*currentRequest;
    NSString                *mountPath;
}

- initWithAsyncSocket:(CKSOCKET_CLASS *)aSocket 
	   servletManager:(CKHttpServletManager *)aServletManager 
   defaultPageManager:(id<CKHttpDefaultPageManagers>)aDefaultPageManager
       sessionManager:(CKHttpSessionManager *)aSessionManager
            mountPath:(NSString *)aMountPath;

- (void)dealloc;

- (void)socket:(CKSOCKET_CLASS *)sock didReadData:(NSData*)data withTag:(long)tag;
- (void)readParameterChunck;

//processing ajp request
- (void)processForwardRequest:(CKAJP13ForwardRequest *)request;

//ajp response messaging
- (void)sendHeaderWithStatusCode:(unsigned int)status 
                   statusMessage:(NSString *)message 
                          header:(NSDictionary *)header 
                         cookies:(NSArray *)cookies;
- (void)sendBodyChunk:(NSData *)chunk;
- (void)sendEndResponse:(BOOL)reuse;

@end
