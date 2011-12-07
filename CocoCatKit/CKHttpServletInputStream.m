/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKHttpServletInputStream.h"
#import "protocol/CKServletConnection.h"

@interface CKHttpServletInputStream(Private) 

- (void)shrinkBuffer;

@end

@implementation CKHttpServletInputStream(Private) 

- (void)shrinkBuffer
{
    if (bufferPosition > 4096) {
        [buffer autorelease];
        buffer = [[buffer subdataWithRange:NSMakeRange(bufferPosition, [buffer length] - bufferPosition)] mutableCopy];
        bufferPosition = 0;
    }
}

@end

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
    NSData  *data;
    if([buffer length] > bufferPosition) {
        //there is something in the buffer return the buffer
        data =[buffer subdataWithRange:NSMakeRange(bufferPosition, [buffer length] - bufferPosition)];
    }
    else {
        data = [servletConnection readPayload];
    }
    
    [buffer release];
    buffer = nil;
    bufferPosition = 0;
    
    return data;
}

- (int)peek
{
    if([buffer length] > bufferPosition) {
        return ((unsigned char *)[buffer bytes])[bufferPosition];
    }
    else {
        buffer = [[servletConnection readPayload] mutableCopy];
        bufferPosition = 0;
        if ([buffer length] == 0) {
            return EOF;
        }
        else {
            return ((unsigned char *)[buffer bytes])[0];
        }
    }
}

- (int)read
{
    unsigned char b = [self peek];
    bufferPosition++;
    return b;
}

- (NSData *)readData:(unsigned int)length
{
    
    while ([buffer length] < length + bufferPosition) {
        NSData  *data = [servletConnection readPayload];
        if ([data length] == 0) {
            NSData *returnData = [buffer autorelease];
            buffer = nil;
            return returnData;
        }
        else {
            if (buffer == nil) {
                buffer = [[NSMutableData alloc] initWithData:data];
            }
            else {
                [buffer appendData:data];
            }
        }
    }
    
    NSData  *data = [buffer subdataWithRange:NSMakeRange(bufferPosition, length)];
    
    bufferPosition += length;
    
    [self shrinkBuffer];
    
    return data;
}

@end
