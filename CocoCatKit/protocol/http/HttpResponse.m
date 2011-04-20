/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


#import "HttpResponse.h"
#import "HttpConnection.h"


@implementation HttpResponse

- initWithConnection:(HttpConnection *)aConnection
{
    connection = [aConnection retain];
    return self;
}

- (void)dealloc
{
    [connection release];
    
    [super dealloc];
}

- (void)writeData:(NSData *)data
{
    [connection sendData:data];
}

- (BOOL)isCommitted
{
	return committed;
}

- (void)sendHeaderWithStatusCode:(unsigned int)code message:(NSString *)message header:(NSDictionary *)header
{
    if (committed == YES) {
        [[NSException exceptionWithName:@"MessageCommittedException" reason:@"Can not send header, message already committed" userInfo:nil] raise];
	}
    
    committed = YES;
    
    NSString        *statusLine = [NSString stringWithFormat:@"HTTP/1.1 %d %@\r\n", code, message];
    NSEnumerator    *enumerator = [header keyEnumerator];
    NSString        *key;
    
    [connection sendData:[statusLine dataUsingEncoding:NSASCIIStringEncoding]];

    while ((key = [enumerator nextObject]) != nil) {
        NSString *value = [header objectForKey:key];
        NSString    *headerEntry = [NSString stringWithFormat:@"%@: %@\r\n", key, value];
        [connection sendData:[headerEntry dataUsingEncoding:NSASCIIStringEncoding]];
    }
    
    [connection sendData:[NSData dataWithBytes:"\x0D\x0A" length:2]];
}

- (void)end:(BOOL)keepAlive
{
    //nothing todo
}

- (HttpDefaultPageManager *)defaultPageManager
{
	return [connection defaultPageManager];
}

@end
