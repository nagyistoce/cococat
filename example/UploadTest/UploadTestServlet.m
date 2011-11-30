/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "UploadTestServlet.h"

@implementation UploadTestServlet

- init
{
	return self;
}

- (void)doGet:(CKHttpServletRequest *)request response:(CKHttpServletResponse *)response
{
	CKHttpServletOutputStream *outputStream = [response outputStream];
	
	[response setHeaderValue:@"text/html" forName:@"Content-Type"];
    
    NSMutableString *string = [NSMutableString stringWithString:@"<html><form name=\"input\" action=\"UploadTestServlet\" method=\"post\">\n"];
    [string appendString:@"File: <input type=\"file\" name=\"name\" />"];
    [string appendString:@"<input type=\"submit\" value=\"Submit\" /></form></html>"];
    NSData  *data = [string dataUsingEncoding:NSISOLatin1StringEncoding];
    [response setContentLength:[data length]];
    [outputStream writeData:data];
}

- (void)doPost:(CKHttpServletRequest *)request response:(CKHttpServletResponse *)response
{
    CKHttpServletOutputStream *outputStream = [response outputStream];

    [response setHeaderValue:@"text/plain" forName:@"Content-Type"];

    [outputStream writeString:[NSString stringWithFormat:@"Hello %@", [[request parameters] objectForKey:@"name"]] encoding:NSISOLatin1StringEncoding];
	
    NSMutableData  *fileData = [[NSMutableData alloc] init];
    
    while (true) {
    NSData *data = [[request inputStream] read];
        if (data == nil) {
            break;
        }
        else {
            [fileData appendData:data];
        }
    }
    
    [fileData writeToFile:[NSString stringWithFormat:@"/tmp/%@", [[request parameters] objectForKey:@"name"]] atomically:NO];
}


@end
