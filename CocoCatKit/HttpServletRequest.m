/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "HttpServletRequest.h"
#import "HttpSession.h"
#import "protocol/ServletRequestMessage.h"

@implementation HttpServletRequest

- initWithServletRequestMessage:(id<ServletRequestMessage>)aRequestMessage session:(HttpSession *)aSession
{
	requestMessage = [aRequestMessage retain];
    session = [aSession retain];
	
    return self;
}

- (void)dealloc
{
	[requestMessage release];
    [session release];
	
	[super dealloc];
}

- (NSString *)method
{
	return [requestMessage method];
}

- (NSString *)requestUri
{
	return [requestMessage requestUri];
}

- (NSDictionary *)header
{
	return [requestMessage header];
}

- (NSDictionary *)parameters
{
	return [requestMessage parameters];
}

- (HttpSession *)session
{
    return session;
}


@end
