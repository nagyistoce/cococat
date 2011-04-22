/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "HttpSession.h"

@implementation HttpSession(Private)

- (void)setLastAccessedTime:(NSDate *)aDate
{
    [lastAccessedTime release];
    lastAccessedTime = [aDate retain];
}

@end

@implementation HttpSession

- initWithSessionId:(NSString *)aSessionId maxInactiveInterval:(NSTimeInterval)interval
{    
    sessionId = [aSessionId retain];
    NSDate *currentTime = [NSDate date];
    
    creationTime = [currentTime retain];
    lastAccessedTime = [currentTime retain];

    maxInactiveInterval = interval;
    
    return self;
}

- (void)dealloc
{
    [sessionId release];
    [creationTime release];
    [lastAccessedTime release];
    
    [super dealloc];
}

- (NSDate *)creationTime
{
    return creationTime;
}

- (NSDate *)lastAccessedTime
{
    return lastAccessedTime;
}

- (NSTimeInterval)maxInactiveInterval
{
    return maxInactiveInterval;
}

- (BOOL)isNew
{
    return (creationTime == lastAccessedTime ? YES: NO);
}

- (NSString *)sessionId
{
    return sessionId;
}

@end
