/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKServletRequestDispatcher.h"
#import "protocol/CKServletRequestMessage.h"
#import "protocol/CKServletResponseMessage.h"
#import "CKHttpDefaultPageManager.h"
#import "CKHttpServletManager.h"
#import "CKHttpSessionManager.h"
#import "CKHttpServletRequest.h"
#import "CKHttpServletResponse.h"
#import "CKHttpServlet.h"
#import "CKCookie.h"

@interface CKHttpServletResponse(Private)

- (NSArray *)cookies;

@end

@interface CKHttpServletRequest(Private)

- (void)releaseSession;

@end

@interface CKHttpServlet(Private)

- (void)service:(CKHttpServletRequest *)request response:(CKHttpServletResponse *)response;

@end

@implementation CKServletRequestDispatcher

- init
{
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

+ (CKServletRequestDispatcher *)defaultDispatcher
{
	static CKServletRequestDispatcher	*dispatcher = nil;
	if (dispatcher == nil) {
		dispatcher = [[CKServletRequestDispatcher alloc] init];
	}
	
	return dispatcher;
}

- (void)dispatch:(id<CKServletRequestMessage>)requestMessage 
        response:(id<CKServletResponseMessage>)responseMessage 
  servletManager:(CKHttpServletManager *)servletManager
  sessionManager:(CKHttpSessionManager *)sessionManager
       keepAlive:(BOOL *)keepAlive
{
	NSArray             *cookies = [requestMessage cookies];
    NSEnumerator        *cookieEnumerator = [cookies objectEnumerator];
    CKCookie            *cookie;
    NSString            *sessionId = nil;
    while ((cookie = [cookieEnumerator nextObject]) != nil) {
        if ([[cookie name] isEqualToString:[sessionManager sessionIdentifier]] == YES) {
            sessionId = [cookie value];
            
            break;
        }
    }
	CKHttpServletResponse	*servletResponse = [[[CKHttpServletResponse alloc] initWithServletResponseMessage:responseMessage] autorelease];	
    CKHttpServletRequest	*servletRequest = [[[CKHttpServletRequest alloc] initWithServletRequestMessage:requestMessage 
																					 requestedSessionId:sessionId
																						 sessionManager:sessionManager
																							   response:servletResponse] autorelease];
	CKHttpServlet *servlet = [servletManager servletForUri:[servletRequest requestUri]];
	
	if (*keepAlive == YES) {
		[servletResponse setHeaderValue:@"keep-alive" forName:@"Connection"];
	}
	else {
		[servletResponse setHeaderValue:@"close" forName:@"Connection"];
	}
	
	if (servlet == nil) {
		[servletResponse sendError:404 message:nil contextInfo:[servletRequest requestUri]];
	}
	else {
		@try {
            [servlet service:servletRequest response:servletResponse];
        } @catch (NSException *ex) {
            NSLog(@"Caught exception : %@", ex);
            if ([servletResponse isCommitted] == NO) {
                @try {
                    [servletResponse sendError:500 message:nil contextInfo:[ex reason]];
                } @catch (NSException *ex) {
                    NSLog(@"Unable to send error code : %@", ex);
                }
            }
        }
	}
    
    [servletRequest releaseSession];
	
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
}

@end
