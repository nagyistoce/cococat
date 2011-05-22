/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKCookie.h"

@implementation CKCookie

- initWithName:(NSString *)aName withValue:(NSString *)aValue
{
    name = [aName retain];
    value = [aValue retain];

    return self;
}


- (void)dealloc
{
    [name release];
    [value release];
    [domain release];
    [path release];
    
    [super dealloc];
}

- (NSString *)name
{
    return name;
}

- (NSString *)value
{
    return value;
}

- (void)setMaxAge:(NSTimeInterval)seconds
{
    maxAge = seconds;
}

- (void)setDomain:(NSString *)aDomain
{
    [domain release];
    domain = [aDomain retain];
}

- (void)setPath:(NSString *)aPath
{
    [path release];
    path = [aPath retain];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ = %@", name ,value];
}

@end
