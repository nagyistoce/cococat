/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "ServletServer.h"
#import "ServletConnection.h"
#import "../HttpServletManager.h"
#import "../Vendor/CocoaAsyncSocket/GCDAsyncSocket.h"

@implementation ServletServer

- init
{
    return [self initWithServletManager:[HttpServletManager defaultManager]];
}

- initWithServletManager:(HttpServletManager *)manager
{
    servletManager = [manager retain];
    connections = [[NSMutableArray alloc] init];
	serverQueue = dispatch_queue_create("ServletServer", NULL);
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:serverQueue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectionDidDie:)
												 name:ServletConnectionDidDieNotification
											   object:nil];
    
    return self;
}

- (void)dealloc
{
    [servletManager release];
    dispatch_release(serverQueue);
    
	[connections release];
	[socket release];
    
    [super dealloc];
}

- (BOOL)listen:(unsigned int)port
{
    __block BOOL success;
	dispatch_sync(serverQueue, ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		success = [socket acceptOnPort:port error:NULL];
		
		[pool release];
	});
	
	return success;
}

- (void)connectionDidDie:(NSNotification *)notification
{
	// Note: This method is called on the connection queue that posted the notification
	
	@synchronized(connections) {
		[connections removeObject:[notification object]];
	}
}

- (void)addConnection:(ServletConnection *)connection
{
    @synchronized(connections) {
		[connections addObject:connection];
	}	
}

@end
