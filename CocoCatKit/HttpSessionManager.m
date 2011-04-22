/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "HttpSessionManager.h"
#import "HttpSession.h"

@implementation HttpSessionManager

- init
{
    sessions = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)dealloc
{
    [sessions release];
    
    [super dealloc];
}

+ (HttpSessionManager *)defaultManager
{
	static HttpSessionManager	*manager = nil;
	if (manager == nil) {
		manager = [[HttpSessionManager alloc] init];
	}
	
	return manager;
}

- (HttpSession *)obtainSession:(NSString *)sessionId
{
    HttpSession *session = nil;
    
    @synchronized(sessions) {
        session = [[sessions objectForKey:sessionId] retain];
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
    @synchronized(sessions) {
        NSString *sessionId = [[self class] _createSessionId];
        session = [[HttpSession alloc] initWithSessionId:sessionId];
        [session setValue:session forKey:sessionId];
    }
    return session;
}

+ (NSString *)_createSessionId 
{
    CFUUIDRef	uuid = CFUUIDCreate(nil);
    NSString	*sessionId = (NSString*)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    return [sessionId autorelease];
}

@end
