/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "HelloWorldServlet.h"

@implementation HelloWorldServlet

- init
{
	return self;
}

- (void)doGet:(HttpServletRequest *)request response:(HttpServletResponse *)response
{
	HttpServletOutputStream *outputStream = [response outputStream];
    HttpSession *session = [request session];


	//we dont calculate the content size before, so we use no persistent connection
	[response setHeaderValue:@"close" forName:@"Connection"];
	
	[response setHeaderValue:@"text/plain" forName:@"Content-Type"];
    [response setHeaderValue:@"Heoo" forName:@"Tst"];

    
    [response addCookie:[[[Cookie alloc] initWithName:@"TestCookie" withValue:@"This is a hello world test"] autorelease]];

    [outputStream writeString:@"Hello World\n" encoding:NSISOLatin1StringEncoding];
	[outputStream writeString:[NSString stringWithFormat:@"Current Time : %@", [NSDate date]] encoding:NSISOLatin1StringEncoding];

    [outputStream writeString:@"\n\n===== Session =====\n" encoding:NSISOLatin1StringEncoding];
    if([session isNew] == YES) {
        [outputStream writeString:[NSString stringWithFormat:@"New session [%@]\n", [session sessionId]] encoding:NSISOLatin1StringEncoding];
    }
    else {
     [outputStream writeString:[NSString stringWithFormat:@"Session [%@] already exists\n", [session sessionId]] encoding:NSISOLatin1StringEncoding];
    }
    
	[outputStream writeString:@"\n\n====== Headers ======\n" encoding:NSISOLatin1StringEncoding];
	[outputStream writeString:[[request header] description] encoding:NSISOLatin1StringEncoding];
	[outputStream writeString:@"\n\n===== Parameters =====\n" encoding:NSISOLatin1StringEncoding];
	[outputStream writeString:[[request parameters] description] encoding:NSISOLatin1StringEncoding];

	[outputStream writeString:@"\n\n====== Uri ======\n" encoding:NSISOLatin1StringEncoding];
	[outputStream writeString:[request requestUri] encoding:NSISOLatin1StringEncoding];
        
    [outputStream writeString:@"\n\n====== Cookies ======\n" encoding:NSISOLatin1StringEncoding];
	[outputStream writeString:[[request cookies] description] encoding:NSISOLatin1StringEncoding];
    
    
}

@end
