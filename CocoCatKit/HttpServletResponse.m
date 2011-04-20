/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


#import "HttpServletResponse.h"
#import "HttpServletOutputStream.h"

@implementation HttpServletResponse

- initWithServletResponseMessage:(<ServletResponseMessage>)aResponseMessage
{
	responseMessage = [aResponseMessage retain];
	header = [[NSMutableDictionary alloc] init];
	
	outputStream = [[HttpServletOutputStream alloc] initWithResponse:self];
	
	status = 200;
	
	return self;
}

- (void)dealloc
{
	[responseMessage release];
	[outputStream release];
	[header release];
	
	[super dealloc];
}

- (void)setStatus:(unsigned int)aStatus
{
	status = aStatus;
}

- (void)setHeaderValue:(NSString *)value forName:(NSString *)name
{
	[header setObject:value forKey:name];
}

- (HttpServletOutputStream *)outputStream
{
	return outputStream;
}

- (void)sendError:(unsigned int)error
{
	NSString * message = @"Unknown";
	
	message = [self _errorMessage:error];
	
	[self sendError:error message:message];
}

- (void)sendError:(unsigned int)error message:(NSString *)message
{
	[responseMessage sendHeadersWithStatusCode:error message:message headers:header];
}

- (void)writeData:(NSData *)data
{
	if([responseMessage isCommited] == NO) {
		[responseMessage sendHeadersWithStatusCode:status message:[self _errorMessage:status] headers:header];
	}
	
	[responseMessage writeData:data];
}

- (void)end
{
	//if header not send
	if([responseMessage isCommited] == NO) {
		[responseMessage sendHeadersWithStatusCode:status message:[self _errorMessage:status] headers:header];
	}
	[responseMessage end];
}

- (BOOL)isCommited
{
	return [responseMessage isCommited];
}

//internal
- (NSString *)_errorMessage:(unsigned int)error
{
	switch(error) {
		case HTTP_RESPONSE_OK:
			return @"OK";
		case HTTP_RESPONSE_NOT_FOUND:
			return @"Not Found";
		case HTTP_RESPONSE_METHOD_NOT_ALLOWED:
			return @"Method Not Allowed";
		case HTTP_RESPONSE_NOT_IMPLEMENTED:
			return @"Not Implemented";
	}
	return @"Unknown";
}



@end
