/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>
#import <CocoCatKit/CKServletRequest.h>

@protocol CKServletRequestMessage;
@class CKHttpSession;
@class CKHttpSessionManager;
@class CKHttpServletResponse;
@class CKHttpServletInputStream;

@interface CKHttpServletRequest : NSObject <CKServletRequest> {
	id<CKServletRequestMessage>	requestMessage;
    CKHttpSession               *session;
    CKHttpSessionManager        *sessionManager;
    CKHttpServletInputStream    *inputStream;
    CKHttpServletResponse       *response;
    NSString                    *requestedSessionId;
    NSArray                     *locales;
}

- initWithServletRequestMessage:(id<CKServletRequestMessage>)aRequestMessage 
             requestedSessionId:(NSString *)aRequestedSessionId 
                    inputStream:(CKHttpServletInputStream *)aInputStream
                 sessionManager:(CKHttpSessionManager *)aSessionManager
                       response:(CKHttpServletResponse *)aResponse;
- (void)dealloc;

- (NSString *)method;
- (NSString *)requestUri;
- (NSString *)requestUrl;
- (NSString *)queryString;
- (NSString *)remoteAddr;
- (NSString *)remoteHost;

- (NSDictionary *)header;
- (NSDictionary *)parameters;
- (CKHttpSession *)session;
- (CKHttpSession *)session:(BOOL)create;
- (NSArray *)cookies;
- (BOOL)secure;
- (NSString *)contextPath;
- (CKHttpServletInputStream *)inputStream;
- (NSLocale *)locale;
- (NSArray *)locales;

@end
