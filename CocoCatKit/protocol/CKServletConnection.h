/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>
#import "CKSocket.h"

#define CKServletConnectionDidDieNotification  @"ServletConnectionDidDie"

@protocol CKHttpDefaultPageManagers;
@class CKSOCKET_CLASS;
@class CKHttpServletManager;
@class CKHttpSessionManager;

@interface CKServletConnection : NSObject {
	CKSOCKET_CLASS					*socket;
    CKHttpServletManager			*servletManager;
#ifdef CK_USEGCD
	dispatch_queue_t				connectionQueue;
#endif
	id<CKHttpDefaultPageManagers>	defaultPageManager;
    CKHttpSessionManager			*sessionManager;
}

- initWithAsyncSocket:(CKSOCKET_CLASS *)aSocket 
	   servletManager:(CKHttpServletManager *)aServletManager 
   defaultPageManager:(id<CKHttpDefaultPageManagers>)aDefaultPageManager
       sessionManager:(CKHttpSessionManager *)aSessionManager;

- (void)dealloc;

- (void)die;
- (void)close;
- (NSData *)readPayload;

- (void)socketDidDisconnect:(CKSOCKET_CLASS *)sock withError:(NSError *)err;

- (id<CKHttpDefaultPageManagers>)defaultPageManager;

@end
