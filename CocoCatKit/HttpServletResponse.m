/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "HttpServletResponse.h"
#import "HttpServletOutputStream.h"
#import "HttpDefaultPageManager.h"
#import "protocol/ServletResponseMessage.h"

@implementation HttpServletResponse(Private)

- (NSArray *)cookies
{
    return cookies;
}

@end

@implementation HttpServletResponse

- initWithServletResponseMessage:(id<ServletResponseMessage>)aResponseMessage
{
	responseMessage = [aResponseMessage retain];
	header = [[NSMutableDictionary alloc] init];
    cookies = [[NSMutableArray alloc] init];
	
	outputStream = [[HttpServletOutputStream alloc] initWithResponse:self];
	
	status = 200;
	
	return self;
}

- (void)dealloc
{
	[responseMessage release];
	[outputStream release];
	[header release];
    [cookies release];
	
	[super dealloc];
}

- (void)setStatus:(unsigned int)aStatus
{
    if ([responseMessage isCommitted] == YES) {
        [[NSException exceptionWithName:@"MessageCommittedException" reason:@"Can not send header, message already committed" userInfo:nil] raise];
    }
    
    status = aStatus;
}

- (unsigned int)status
{
    return status;
}

- (void)setHeaderValue:(NSString *)value forName:(NSString *)name
{
    if ([responseMessage isCommitted] == YES) {
        [[NSException exceptionWithName:@"MessageCommittedException" reason:@"Can not send header, message already committed" userInfo:nil] raise];
    }
	
    [header setObject:value forKey:name];
}

- (void)setIntHeaderValue:(int)value forName:(NSString *)name
{
	[self setHeaderValue:[NSString stringWithFormat:@"%d", value] forName:name];
}

- (NSDictionary *)header
{
    return header;
}

- (void)setContentLength:(int)length
{
	[self setIntHeaderValue:length forName:@"Content-Length"];
}

- (HttpServletOutputStream *)outputStream
{
	return outputStream;
}

- (void)addCookie:(Cookie *)cookie
{
    if ([responseMessage isCommitted] == YES) {
        [[NSException exceptionWithName:@"MessageCommittedException" reason:@"Cannot add cookie, message already committed" userInfo:nil] raise];
    }
    [cookies addObject:cookie];   
}

- (void)sendError:(unsigned int)error
{
	[self sendError:error message:[[responseMessage defaultPageManager] textForCode:error]];
}

- (void)sendError:(unsigned int)error message:(NSString *)message
{
    if ([responseMessage isCommitted] == YES) {
        [[NSException exceptionWithName:@"MessageCommittedException" reason:@"Cannot send header, message already committed" userInfo:nil] raise];
    }
    
	NSData	*errorPage = [[[responseMessage defaultPageManager] errorPageForCode:error] dataUsingEncoding:NSISOLatin1StringEncoding];

    [self setIntHeaderValue:[errorPage length] forName:@"Content-Length"];
	
    [responseMessage sendHeaderWithStatusCode:error message:message header:header cookies:cookies];
	
	[self writeData:errorPage];
	
}

- (void)writeData:(NSData *)data
{
	if ([responseMessage isCommitted] == NO) {
		[responseMessage sendHeaderWithStatusCode:status message:[[responseMessage defaultPageManager] textForCode:status] header:header cookies:cookies];
	}
	
	[responseMessage writeData:data];
}

- (BOOL)isCommitted
{
	return [responseMessage isCommitted];
}

@end
