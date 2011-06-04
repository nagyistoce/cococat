/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKServletConnection.h"
#import "../CKHttpServletManager.h"
#ifdef CK_USEGCD
#import "../Vendor/CocoaAsyncSocket/GCDAsyncSocket.h"
#else
#import "../Vendor/CocoaAsyncSocket/AsyncSocket.h"
#endif
#import "../CKHttpDefaultPageManagers.h"

@implementation CKServletConnection

- initWithAsyncSocket:(CKSOCKET_CLASS *)aSocket 
	   servletManager:(CKHttpServletManager *)aServletManager 
   defaultPageManager:(id<CKHttpDefaultPageManagers>)aDefaultPageManager
       sessionManager:(CKHttpSessionManager *)aSessionManager
{
#ifdef CK_USEGCD
    connectionQueue = dispatch_queue_create("CKServletConnection", NULL);
#endif    
	socket = [aSocket retain];
    servletManager = [aServletManager retain];
    sessionManager = [aSessionManager retain];
	defaultPageManager = [aDefaultPageManager retain];
#ifdef CK_USEGCD
	[socket setDelegate:self delegateQueue:connectionQueue];
#else
    [socket setDelegate:self];
#endif
    return self;
}

- (void)dealloc
{
#ifdef CK_USEGCD
    dispatch_release(connectionQueue);
#endif    	
	[socket release];
    [servletManager release];
    [sessionManager release];
	[defaultPageManager release];
    
    [super dealloc];
}

- (void)die
{	
	[[NSNotificationCenter defaultCenter] postNotificationName:CKServletConnectionDidDieNotification object:self];
}

- (void)close
{
    [socket disconnectAfterWriting];
}

- (void)socketDidDisconnect:(CKSOCKET_CLASS *)sock withError:(NSError *)err
{	
	[self die];
}

- (id<CKHttpDefaultPageManagers>)defaultPageManager
{
	return defaultPageManager;
}

@end
