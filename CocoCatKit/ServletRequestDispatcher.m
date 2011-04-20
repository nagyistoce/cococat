/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


#import "ServletRequestDispatcher.h"
#import "HttpServletManager.h"
#import "HttpServletRequest.h"
#import "HttpServletResponse.h"
#import "HttpServlet.h"


@implementation ServletRequestDispatcher

- init
{
	return self;
}

+ (ServletRequestDispatcher *)defaultDispatcher
{
	static ServletRequestDispatcher	*dispatcher = nil;
	if(dispatcher == nil) {
		dispatcher = [[ServletRequestDispatcher alloc] init];
	}
	
	return dispatcher;
}

- (void)dispatch:(<ServletRequestMessage>)requestMessage response:(<ServletResponseMessage>)responseMessage
{
	HttpServletRequest	*servletRequest = [[[HttpServletRequest alloc] initWithServletRequestMessage:requestMessage] autorelease];
	HttpServletResponse	*servletResponse = [[[HttpServletResponse alloc] initWithServletResponseMessage:responseMessage] autorelease];
	
	HttpServlet *servlet = [[HttpServletManager defaultManager] servletForUri:[servletRequest requestUri]];
	if(servlet == nil) {
		[servletResponse sendError:404];
	}
	else {
		[servlet _service:servletRequest response:servletResponse];
	}
	
	[servletResponse end];
}

@end
