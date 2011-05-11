/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "HttpDefaultPageManager.h"

@implementation HttpDefaultPageManager

- init
{
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

+ (HttpDefaultPageManager *)defaultManager
{
	static HttpDefaultPageManager	*manager = nil;
	if (manager == nil) {
		manager = [[HttpDefaultPageManager alloc] init];
	}
	
	return manager;
}

- (NSString *)errorPageForCode:(unsigned int)code contextInfo:(NSString *)contextInfo
{
	if (contextInfo != nil) {
        return [NSString stringWithFormat:@"%@ - %@", [self textForCode:code], contextInfo];
    }
    else {
        return [self textForCode:code];
    } 
}

- (NSString *)textForCode:(unsigned int)code
{
	return [[self class] defaultTextForCode:code];
}

+ (NSString *)defaultTextForCode:(unsigned int)code
{
	switch(code) {
		case HTTP_RESPONSE_OK:
			return @"OK";
		case HTTP_RESPONSE_NOT_FOUND:
			return @"Not Found";
		case HTTP_RESPONSE_METHOD_NOT_ALLOWED:
			return @"Method Not Allowed";
		case HTTP_RESPONSE_NOT_IMPLEMENTED:
			return @"Not Implemented";
        case HTTP_RESPONSE_INTERNAL_SERVER_ERROR:
			return @"Internal Server Error";
	}
	return @"Unknown";
}


@end
