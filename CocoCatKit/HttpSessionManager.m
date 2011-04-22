/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "HttpSessionManager.h"
#import "HttpSession.h"

static NSString * const defaultSessionIdentifier = @"COCOCAT-SESSION";

@interface HttpSessionManager(Private)

- (void)_cleanupExpiredSession:(NSTimer *)theTimer;
+ (NSString *)_createSessionId;

@end

@interface HttpSession(Private)

- (void)setLastAccessedTime:(NSDate *)aDate;

@end

@implementation HttpSessionManager

- initWithSessionIdentifier:(NSString *)aSessionIdentifier
{
    sessionIdentifier = [aSessionIdentifier retain];
    sessions = [[NSMutableDictionary alloc] init];
    maxInactiveInterval = 300; //5 minutes
    cleanupTimer = [[NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(_cleanupExpiredSession:) userInfo:nil repeats:YES] retain];
        
    return self;
}

- (void)dealloc
{
    [sessions release];
    [cleanupTimer release];
    [sessionIdentifier release];
    
    [super dealloc];
}

+ (HttpSessionManager *)defaultManager
{
	static HttpSessionManager	*manager = nil;
	if (manager == nil) {
		manager = [[HttpSessionManager alloc] initWithSessionIdentifier:defaultSessionIdentifier];
	}
	
	return manager;
}

- (HttpSession *)obtainSession:(NSString *)sessionId
{
    HttpSession *session = nil;
    
    if(sessionId == nil) {
        return nil;
    }
  
    @synchronized (sessions) {
        session = [[sessions objectForKey:sessionId] retain];
        NSDate              *lastAccessedTime = [session lastAccessedTime];
        NSDate              *invalidDate = [[[NSDate alloc] initWithTimeInterval:[session maxInactiveInterval] sinceDate:lastAccessedTime] autorelease];
        NSComparisonResult  result = [invalidDate compare:[NSDate date]];
        if (result == NSOrderedAscending) {
            [sessions removeObjectForKey:sessionId];
            [session release];
            session = nil;
        }
        else {
            [session setLastAccessedTime:[NSDate date]];
        }
    }
    
    return session;
}

- (void)releaseSession:(HttpSession *)session
{
    [session release];
}

- (HttpSession *)createAndOptainSession
{
    HttpSession *session;
    @synchronized (sessions) {
        NSString *sessionId = [[self class] _createSessionId];
        session = [[HttpSession alloc] initWithSessionId:sessionId maxInactiveInterval:maxInactiveInterval];
        [sessions setValue:session forKey:sessionId];
    }
    return session;
}

- (NSString *)sessionIdentifier
{
    return sessionIdentifier;
}

+ (NSString *)_createSessionId 
{
    CFUUIDRef	uuid = CFUUIDCreate(nil);
    NSString	*sessionId = (NSString *)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    return [sessionId autorelease];
}

- (void)_cleanupExpiredSession:(NSTimer *)theTimer
{
    @synchronized (sessions) {
        NSEnumerator    *keyEnumerator = [[sessions allKeys] objectEnumerator];
        NSString        *sessionId;
        while ((sessionId = [keyEnumerator nextObject]) != nil) {
            HttpSession *session = [sessions objectForKey:sessionId];
            NSDate      *lastAccessedTime = [session lastAccessedTime];
            NSDate      *invalidDate = [[[NSDate alloc] initWithTimeInterval:[session maxInactiveInterval] sinceDate:lastAccessedTime] autorelease];
            
            NSComparisonResult  result = [invalidDate compare:[NSDate date]];
            
            if (result == NSOrderedAscending) {
                [sessions removeObjectForKey:sessionId];
            }
        }
    }
}

@end
