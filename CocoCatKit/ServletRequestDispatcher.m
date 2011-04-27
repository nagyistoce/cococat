/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "ServletRequestDispatcher.h"
#import "protocol/ServletRequestMessage.h"
#import "protocol/ServletResponseMessage.h"
#import "HttpDefaultPageManager.h"
#import "HttpServletManager.h"
#import "HttpSessionManager.h"
#import "HttpServletRequest.h"
#import "HttpServletResponse.h"
#import "HttpServlet.h"
#import "Cookie.h"

@interface HttpServletResponse(Private)

- (NSArray *)cookies;

@end

@interface HttpServlet(Private)

- (void)service:(HttpServletRequest *)request response:(HttpServletResponse *)response;

@end

@implementation ServletRequestDispatcher

- init
{
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

+ (ServletRequestDispatcher *)defaultDispatcher
{
	static ServletRequestDispatcher	*dispatcher = nil;
	if (dispatcher == nil) {
		dispatcher = [[ServletRequestDispatcher alloc] init];
	}
	
	return dispatcher;
}

- (void)dispatch:(id<ServletRequestMessage>)requestMessage 
        response:(id<ServletResponseMessage>)responseMessage 
  servletManager:(HttpServletManager *)servletManager
  sessionManager:(HttpSessionManager *)sessionManager
       keepAlive:(BOOL *)keepAlive
{
	NSArray             *cookies = [requestMessage cookies];
    NSEnumerator        *cookieEnumerator = [cookies objectEnumerator];
    Cookie              *cookie;
    NSString            *sessionId = nil;
    while ((cookie = [cookieEnumerator nextObject]) != nil) {
        if ([[cookie name] isEqualToString:[sessionManager sessionIdentifier]] == YES) {
            sessionId = [cookie value];
            
            break;
        }
    }
    HttpSession         *session = [sessionManager obtainSession:sessionId];
	HttpServletResponse	*servletResponse = [[[HttpServletResponse alloc] initWithServletResponseMessage:responseMessage] autorelease];	
    HttpServletRequest	*servletRequest = [[[HttpServletRequest alloc] initWithServletRequestMessage:requestMessage 
                                                                                    retainedSession:session
                                                                                     sessionManager:sessionManager
                                                                                           response:servletResponse] autorelease];
	HttpServlet *servlet = [servletManager servletForUri:[servletRequest requestUri]];
	
	if (*keepAlive == YES) {
		[servletResponse setHeaderValue:@"keep-alive" forName:@"Connection"];
	}
	else {
		[servletResponse setHeaderValue:@"close" forName:@"Connection"];
	}
	
	if (servlet == nil) {
		[servletResponse sendError:404];
	}
	else {
		@try {
            [servlet service:servletRequest response:servletResponse];
        } @catch (NSException *ex) {
            NSLog(@"Caught exception : %@", ex);
            if ([servletResponse isCommitted] == NO) {
                @try {
                    [servletResponse sendError:500];
                } @catch (NSException *ex) {
                    NSLog(@"Unable to send error code : %@", ex);
                }
            }
        }
	}
	
	//get keep alive from response again, maybe the servlet modified it
	if ([[[servletResponse header] objectForKey:@"Connection"] isEqualToString:@"keep-alive"] == YES
        && [[servletResponse header] objectForKey:@"Content-Length"] != nil) {
		int contentLength = [[[servletResponse header] objectForKey:@"Content-Length"] intValue];
		if ([servletResponse responsePayloadSize] >=  contentLength) {
			*keepAlive = YES;
		}
		else {
			*keepAlive = NO;
		}
	}
	else {
		*keepAlive = NO;
	}
	
    if ([responseMessage isCommitted] == NO) {
		[responseMessage sendHeaderWithStatusCode:[servletResponse status] message:[[responseMessage defaultPageManager] textForCode:[servletResponse status]] header:[servletResponse header] cookies:[servletResponse cookies]];
	}
	[responseMessage end:*keepAlive];
    
    [sessionManager releaseSession:session];
}

@end
