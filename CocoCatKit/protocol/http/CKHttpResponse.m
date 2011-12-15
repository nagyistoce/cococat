/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKHttpResponse.h"
#import "CKHttpConnection.h"
#import "../../CKCookie.h"

@implementation CKHttpResponse

- initWithConnection:(CKHttpConnection *)aConnection
{
    connection = [aConnection retain];
	responsePayloadSize = 0;
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
	responsePayloadSize += [data length];
}

- (unsigned int)responsePayloadSize
{
	return responsePayloadSize;
}

- (BOOL)isCommitted
{
	return committed;
}

- (void)sendHeaderWithStatusCode:(unsigned int)code message:(NSString *)message header:(NSDictionary *)header cookies:(NSArray *)cookies
{
    if (committed == YES) {
        [[NSException exceptionWithName:@"MessageCommittedException" reason:@"Can not send header, message already committed" userInfo:nil] raise];
	}
    
    committed = YES;
    
    NSString        *statusLine = [NSString stringWithFormat:@"HTTP/1.1 %d %@\r\n", code, message];
    NSEnumerator    *headerEnumerator = [header keyEnumerator];
    NSString        *key;
    
    [connection sendData:[statusLine dataUsingEncoding:NSASCIIStringEncoding]];

    while ((key = [headerEnumerator nextObject]) != nil) {
        NSString    *value = [header objectForKey:key];
        NSString    *headerEntry = [NSString stringWithFormat:@"%@: %@\r\n", key, value];
        [connection sendData:[headerEntry dataUsingEncoding:NSASCIIStringEncoding]];
    }
    
    NSEnumerator    *cookieEnumerator = [cookies objectEnumerator];
    CKCookie		*cookie;
    
    while ((cookie = [cookieEnumerator nextObject]) != nil) {
        NSString    *cookieEntry = [NSString stringWithFormat:@"Set-Cookie: %@\r\n", [cookie description]];
        [connection sendData:[cookieEntry dataUsingEncoding:NSASCIIStringEncoding]];
    }
    
    [connection sendData:[NSData dataWithBytes:"\x0D\x0A" length:2]];
}

- (void)end:(BOOL)keepAlive
{
    //we need to read the whole request if connection is keep alive
    if (keepAlive == YES) {
        while (YES) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSData  * data = [connection readPayload];
            if (data == nil) {
                [pool release];
                break;
            }
            [pool release];
        }
    }
}

- (id<CKHttpDefaultPageManagers>)defaultPageManager
{
	return [connection defaultPageManager];
}

@end
