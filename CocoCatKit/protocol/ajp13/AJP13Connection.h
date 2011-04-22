/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>
#import "../ServletConnection.h"

//receiving messages from http server
#define AJP_PACKET_HEADER	0
#define AJP_FORWARD_REQUEST 2
#define AJP_SHUTDOWN		7
#define AJP_PING			8
#define AJP_CPING			10
#define AJP_DATA			-1

//sending messages to http server
#define AJP_WRITE_PACKET_HEADER 255
#define AJP_SEND_BODY_CHUNK		3
#define AJP_SEND_HEADER			4
#define AJP_END_RESPONSE		5
#define AJP_GET_BODY_CHUNK		6

@class AJP13ForwardRequest;
@protocol HttpDefaultPageManagers;
@class HttpSessionManager;

@interface AJP13Connection : ServletConnection {
}

- initWithAsyncSocket:(GCDAsyncSocket *)aSocket 
	   servletManager:(HttpServletManager *)aServletManager 
   defaultPageManager:(id<HttpDefaultPageManagers>)aDefaultPageManager
       sessionManager:(HttpSessionManager *)aSessionManager;

- (void)dealloc;

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag;

//processing ajp request
- (void)processForwardRequest:(AJP13ForwardRequest *)request;

//ajp response messaging
- (void)sendHeaderWithStatusCode:(unsigned int)status 
                   statusMessage:(NSString *)message 
                          header:(NSDictionary *)header 
                         cookies:(NSArray *)cookies;
- (void)sendBodyChunk:(NSData *)chunk;
- (void)sendEndResponse:(BOOL)reuse;


//helper for writing responses
- (void)_addInteger:(unsigned int)integer data:(NSMutableData *)data;
- (void)_addString:(NSString *)string  data:(NSMutableData *)data;
- (void)_writePacketHeader:(unsigned int)length;
- (NSNumber *)_codeValueForHeaderName:(NSString *)name;
+ (NSData *)_sendBodyChunckIdentifierData;

@end
