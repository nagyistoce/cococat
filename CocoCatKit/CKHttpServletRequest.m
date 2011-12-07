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

@interface CKHttpAcceptLanguageQuality : NSObject
{
    NSString    *identifier;
    double      quality;
}

- initWithIdentifier:(NSString *)anIdentifier quality:(double)aQuality;
- (void)dealloc;

- (NSString *)identifier;
- (NSString *)description;

- (NSComparisonResult)compare:(CKHttpAcceptLanguageQuality *)otherObject;

@end

@implementation CKHttpAcceptLanguageQuality

- initWithIdentifier:(NSString *)anIdentifier quality:(double)aQuality
{
    identifier = [anIdentifier retain];
    quality = aQuality;
    
    return self;
}

- (void)dealloc
{
    [identifier release];
    [super dealloc];
}

- (NSString *)identifier
{
    return identifier;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%f)", identifier, quality];
}

- (NSComparisonResult)compare:(CKHttpAcceptLanguageQuality *)otherObject 
{
    if (quality > otherObject->quality) {
        return NSOrderedAscending;
   
    }
    else if (quality > otherObject->quality) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

@end

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
                    inputStream:(CKHttpServletInputStream *)aInputStream
                 sessionManager:(CKHttpSessionManager *)aSessionManager
                       response:(CKHttpServletResponse *)aResponse
{
	requestMessage = [aRequestMessage retain];
    sessionManager = [aSessionManager retain];
    response = [aResponse retain];
    requestedSessionId = [aRequestedSessionId retain];
    inputStream = [aInputStream retain];
    
    return self;
}

- (void)dealloc
{
    [self releaseSession];
    [requestedSessionId release];
	[requestMessage release];
    [response release];    
    [sessionManager release];
    [inputStream release];
    [locales release];
	
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
    if(session == nil || [session isValid] == NO) {
        [self releaseSession];
        
        session = [sessionManager obtainSession:requestedSessionId];
        if (session == nil) {
            session = [sessionManager createAndOptainSession];
            
            CKCookie  *sessionCookie = [[[CKCookie alloc] initWithName:[sessionManager sessionIdentifier] withValue:[session sessionId]] autorelease];
            
            [sessionCookie setPath:[sessionManager path]];
            
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

- (CKHttpServletInputStream *)inputStream
{
    return inputStream;
}

- (NSLocale *)locale
{
    [self locales]; 
    
    if ([locales count] > 0) {
        return [locales objectAtIndex:0];
    } else {
        return [NSLocale systemLocale];
    }
}

- (NSArray *)locales
{
    if (locales == nil) {
        locales = [[NSMutableArray alloc] init];
        NSMutableArray *acceptLanguageQualities = [NSMutableArray array];
        NSString        *acceptLanguage = [[requestMessage header] objectForKey:@"Accept-Language"];
        NSArray         *strings = [acceptLanguage componentsSeparatedByString:@","];
        NSEnumerator    *enumerator = [strings objectEnumerator];
        NSString        *string;
        CKHttpAcceptLanguageQuality *current;
        while ((string = [enumerator nextObject]) != nil) {
            NSScanner   *alqscanner = [NSScanner scannerWithString:string];
            NSString    *identifier = nil;
            double      quality = 1.0;
            [alqscanner scanUpToString:@";" intoString:&identifier];
            if ([alqscanner scanString:@";" intoString:NULL] == YES) {
                if ([alqscanner scanString:@"q" intoString:NULL] == YES) {
                    if ([alqscanner scanString:@"=" intoString:NULL] == YES) {
                        [alqscanner scanDouble:&quality];
                    }
                }
            }
            
            [acceptLanguageQualities addObject:[[[CKHttpAcceptLanguageQuality alloc] initWithIdentifier:identifier quality:quality] autorelease]];
        }
        
        enumerator = [[acceptLanguageQualities sortedArrayUsingSelector:@selector(compare:)] objectEnumerator];
        while ((current = [enumerator nextObject]) != nil) {
            //de-ch -> de_CH, en -> en
            NSArray *components = [[current identifier] componentsSeparatedByString:@"-"];
            NSString    *identifier;
            if ([components count] > 1) {
                identifier = [NSString stringWithFormat:@"%@_%@", [components objectAtIndex:0], [[components objectAtIndex:1] uppercaseString]];
            }
            else {
                identifier = [current identifier];
            }
            [(NSMutableArray *)locales addObject:[[[NSLocale alloc] initWithLocaleIdentifier:identifier] autorelease]];
        }
    }
    
    return locales;
}

@end
