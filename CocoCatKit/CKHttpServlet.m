/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKHttpServlet.h"
#import "CKHttpServletRequest.h"
#import "CKHttpServletResponse.h"

@implementation CKHttpServlet

- (void)doDelete:(CKHttpServletRequest *)request response:(CKHttpServletResponse *)response
{
	[response sendError:501];
}

- (void)doGet:(CKHttpServletRequest *)request response:(CKHttpServletResponse *)response
{
	[response sendError:501];
}

- (void)doHead:(CKHttpServletRequest *)request response:(CKHttpServletResponse *)response
{
	[response sendError:501];
}

- (void)doOptions:(CKHttpServletRequest *)request response:(CKHttpServletResponse *)response
{
	[response sendError:501];
}

- (void)doPost:(CKHttpServletRequest *)request response:(CKHttpServletResponse *)response
{
	[response sendError:501];
}

- (void)doPut:(CKHttpServletRequest *)request response:(CKHttpServletResponse *)response
{
	[response sendError:501];
}

- (void)doTrace:(CKHttpServletRequest *)request response:(CKHttpServletResponse *)response
{
	[response sendError:501];
}

@end

@implementation CKHttpServlet(Private)

- (void)service:(CKHttpServletRequest *)request response:(CKHttpServletResponse *)response
{
	NSString	*upperMethod = [[request method] uppercaseString];
	
	if ([upperMethod isEqualToString:@"GET"] == YES) {
		[self doGet:request response:response];
	}
	else if ([upperMethod isEqualToString:@"POST"] == YES) {
		[self doPost:request response:response];
	}
	else {
		[response sendError:405];
	}
}

@end
