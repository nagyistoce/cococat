/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "ServletConnection.h"
#import "../HttpServletManager.h"
#import "../Vendor/CocoaAsyncSocket/GCDAsyncSocket.h"
#import "../HttpDefaultPageManagers.h"

@implementation ServletConnection

- initWithAsyncSocket:(GCDAsyncSocket *)aSocket 
	   servletManager:(HttpServletManager *)aServletManager 
   defaultPageManager:(id<HttpDefaultPageManagers>)aDefaultPageManager
       sessionManager:(HttpSessionManager *)aSessionManager
{
    connectionQueue = dispatch_queue_create("ServletConnection", NULL);
    
	socket = [aSocket retain];
    servletManager = [aServletManager retain];
    sessionManager = [aSessionManager retain];
	defaultPageManager = [aDefaultPageManager retain];
	[socket setDelegate:self delegateQueue:connectionQueue];
    
    return self;
}

- (void)dealloc
{
    dispatch_release(connectionQueue);
	
	[socket release];
    [servletManager release];
    [sessionManager release];
	[defaultPageManager release];
    
    [super dealloc];
}

- (void)die
{	
	[[NSNotificationCenter defaultCenter] postNotificationName:ServletConnectionDidDieNotification object:self];
}

- (void)close
{
	[socket disconnect];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{	
	[self die];
}

- (id<HttpDefaultPageManagers>)defaultPageManager
{
	return defaultPageManager;
}

@end
