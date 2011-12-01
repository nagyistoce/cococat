/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKHttpServletInputStream.h"
#import "protocol/CKServletConnection.h"

@implementation CKHttpServletInputStream

- initWithConnection:(CKServletConnection *)aServletConnection
{
    servletConnection = [aServletConnection retain];
    
    return self;
}

- (void)dealloc
{
    [servletConnection release];
    
    [super dealloc];
}

- (NSData *)readData
{
    return [servletConnection readPayload];
}

//TODO make it faster with not copy data every time 
//(especially for small read blocks)
//use a bufferPosition
- (unsigned char)read
{
    NSData  *data = [self readData:1];
    
    if ([data length] == 0) {
        return EOF;
    }
    
    return ((char *)[data bytes])[0];
}

- (NSData *)readData:(unsigned int)length
{
    
    while ([buffer length] < length) {
        NSData  *data = [self readData];
        if ([data length] == 0) {
            NSData *returnData = [buffer autorelease];
            buffer = nil;
            return returnData;
        }
        else {
            if (buffer == nil) {
                buffer = [[NSMutableData alloc] init];
            }
            [buffer appendData:data];
        }
    }
    
    NSData  *ret = [buffer subdataWithRange:NSMakeRange(0, length)];
    [buffer autorelease];
    buffer = [[buffer subdataWithRange:NSMakeRange(length, [buffer length] - length)] mutableCopy];
    
    return ret;
}

@end
