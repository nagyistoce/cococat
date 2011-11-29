/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKHttpServletRequest.h"
#import "CKHttpServletResponse.h"
#import "CKHttpSession.h"
#import "CKCookie.h"
#import "CKHttpSessionManager.h"
#import "protocol/CKServletRequestMessage.h"

@interface CKHttpServletRequest(Private)

- (void)releaseSession;

@end

@implementation CKHttpServletRequest(Private)

- (void)releaseSession
{
    if (session != nil) {
        [sessionManager releaseSession:session];
        session = nil;
    }
}

@end

@implementation CKHttpServletRequest

- initWithServletRequestMessage:(id<CKServletRequestMessage>)aRequestMessage 
             requestedSessionId:(NSString *)aRequestedSessionId 
                 sessionManager:(CKHttpSessionManager *)aSessionManager
                       response:(CKHttpServletResponse *)aResponse
{
	requestMessage = [aRequestMessage retain];
    sessionManager = [aSessionManager retain];
    response = [aResponse retain];
    requestedSessionId = [aRequestedSessionId retain];
    
    return self;
}

- (void)dealloc
{
    [self releaseSession];
    [requestedSessionId release];
	[requestMessage release];
    [response release];    
    [sessionManager release];
	
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

- (NSString *)requestUrl
{
    return [requestMessage requestUrl];
}

- (NSString *)queryString
{
	return [requestMessage queryString];
}

- (NSString *)remoteAddr
{
    return [requestMessage remoteAddr];
}

- (NSString *)remoteHost
{
    return [requestMessage remoteHost];
}

- (NSDictionary *)header
{
	return [requestMessage header];
}

- (NSDictionary *)parameters
{
	return [requestMessage parameters];
}

- (CKHttpSession *)session
{
    if(session == nil) {
        session = [sessionManager obtainSession:requestedSessionId];
        if (session == nil) {
            session = [sessionManager createAndOptainSession];
            
            CKCookie  *sessionCookie = [[[CKCookie alloc] initWithName:[sessionManager sessionIdentifier] withValue:[session sessionId]] autorelease];
            [response addCookie:sessionCookie];
        }
    }
    
    return session;
}

- (CKHttpSession *)session:(BOOL)create
{
    if(session == nil) {
        session = [sessionManager obtainSession:requestedSessionId];
    }
    
    return session;
    
}

- (NSArray *)cookies
{
    return [requestMessage cookies];
}

- (BOOL)secure
{
    return [requestMessage secure];
}

- (NSString *)contextPath
{
    return [requestMessage contextPath];

}

@end
