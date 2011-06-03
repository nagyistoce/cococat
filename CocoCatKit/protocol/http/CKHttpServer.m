/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKHttpServer.h"
#import "CKHttpConnection.h"

@implementation CKHttpServer

- init
{
    self =  [super init];
    
    secure = NO; //not supported
    
    return self;
}

- initWithServletManager:(CKHttpServletManager *)manager
{
	self = [super initWithServletManager:manager];
    
    secure = NO; //not supported

	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	CKHttpConnection *newConnection = [[[CKHttpConnection alloc] initWithAsyncSocket:newSocket 
																	  servletManager:servletManager 
																  defaultPageManager:defaultPageManager
																	  sessionManager:sessionManager
																			  secure:secure] autorelease];
    [super addConnection:newConnection];
}


@end