/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKServletServer.h"
#import "CKServletConnection.h"
#import "../CKHttpServletManager.h"
#import "../CKHttpSessionManager.h"
#import "../CKHttpDefaultPageManager.h"
#ifdef CK_USEGCD
#import "../Vendor/CocoaAsyncSocket/GCDAsyncSocket.h"
#else
#import "../Vendor/CocoaAsyncSocket/AsyncSocket.h"
#endif
@implementation CKServletServer

- init
{
    return [self initWithServletManager:[CKHttpServletManager defaultManager]];
}

- initWithServletManager:(CKHttpServletManager *)manager
{
    servletManager = [manager retain];
	defaultPageManager = [[CKHttpDefaultPageManager defaultManager] retain];
    sessionManager = [[CKHttpSessionManager defaultManager] retain];
    connections = [[NSMutableArray alloc] init];
#ifdef CK_USEGCD
	serverQueue = dispatch_queue_create("CKServletServer", NULL);
    socket = (CKSOCKET_CLASS *)[[GCDAsyncSocket alloc] init];
#else
    socket = (CKSOCKET_CLASS *)[[AsyncSocket alloc] init];
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectionDidDie:)
												 name:CKServletConnectionDidDieNotification
											   object:nil];
    
    return self;
}

- (void)dealloc
{
    [servletManager release];
	[defaultPageManager release];
    [sessionManager release];
#ifdef CK_USEGCD
    dispatch_release(serverQueue);
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[connections release];
	[socket release];
    
    [super dealloc];
}

- (void)setDefaultPageManager:(id<CKHttpDefaultPageManagers>)aDefaultPageManager
{
	[defaultPageManager release];
	defaultPageManager = [aDefaultPageManager retain];
}

- (void)setSessionManager:(CKHttpSessionManager *)aSessionManager
{
    [sessionManager release];
	sessionManager = [aSessionManager retain];
}

- (BOOL)listen:(unsigned int)port
{     
#ifdef CK_USEGCD 
    [socket setDelegate:self delegateQueue:serverQueue];
#else
    [socket setDelegate:self];
#endif
    
#ifdef CK_USEGCD
    __block BOOL success;
	dispatch_sync(serverQueue, ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		success = [socket acceptOnPort:port error:NULL];
		
		[pool release];
	});
	
	return success;
#else
    return [socket acceptOnPort:port error:NULL];
#endif
}

- (void)stop
{
    [socket setDelegate:nil];
    [socket disconnect];
}

- (void)connectionDidDie:(NSNotification *)notification
{	
	@synchronized(connections) {
		[connections removeObject:[notification object]];
	}
}

- (void)addConnection:(CKServletConnection *)connection
{
    @synchronized(connections) {
		[connections addObject:connection];
	}	
}

@end
