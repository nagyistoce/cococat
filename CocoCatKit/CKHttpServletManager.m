/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKHttpServletManager.h"
#import "CKHttpServlet.h"

@interface CKHttpServletMapping : NSObject
{
    CKHttpServlet	*servlet;
    NSString		*pattern;
}

- initWithServlet:(CKHttpServlet *)aServlet forPattern:(NSString *)aPattern;
- (void)dealloc;

- (NSString *)pattern;
- (CKHttpServlet *)servlet;

@end

@implementation CKHttpServletMapping

- initWithServlet:(CKHttpServlet *)aServlet forPattern:(NSString *)aPattern
{
    servlet = [aServlet retain];
    pattern = [aPattern retain];
    
    return self;
}

- (void)dealloc
{
    [servlet release];
    [pattern release];
    
    [super dealloc];
}

- (NSString *)pattern
{
    return pattern;
}

- (CKHttpServlet *)servlet
{
    return servlet; 
}

@end


@implementation CKHttpServletManager

- init
{
	servletMappings = [[NSMutableArray alloc] init];
	return self;
}

- (void)dealloc
{
	[servletMappings release];
	
	[super dealloc];
}

+ (CKHttpServletManager *)defaultManager
{
	static CKHttpServletManager	*manager = nil;
	if (manager == nil) {
		manager = [[CKHttpServletManager alloc] init];
	}
	
	return manager;
}

- (CKHttpServlet *)servletForUri:(NSString *)uri
{
	NSEnumerator			*enumerator = [servletMappings objectEnumerator];
	CKHttpServletMapping	*mapping;
	
	while ((mapping = [enumerator nextObject]) != nil) {
		NSPredicate *pred = [NSPredicate
								  predicateWithFormat:@"SELF MATCHES %@", [mapping pattern]];
		if ([pred evaluateWithObject:uri] == YES) {
			return [mapping servlet];
		} 
	}
	
	return nil;
}

- (void)registerServlet:(CKHttpServlet *)servlet forUrlPattern:(NSString *)pattern
{
    [servletMappings addObject:[[[CKHttpServletMapping alloc] initWithServlet:servlet forPattern:pattern] autorelease]];
}

@end

void ckHttpServletInit()
{
}
