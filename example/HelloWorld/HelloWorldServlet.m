/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


#import "HelloWorldServlet.h"
#import <CocoCatKit/HttpServletOutputStream.h>
#import <CocoCatKit/HttpServletResponse.h>
#import <CocoCatKit/HttpServletRequest.h>

@implementation HelloWorldServlet

- init
{
	return self;
}

- (void)doGet:(HttpServletRequest *)request response:(HttpServletResponse *)response
{
	HttpServletOutputStream *outputStream = [response outputStream];
	
	[response setHeaderValue:@"text/plain" forName:@"Content-Type"];
	[outputStream writeString:@"Hello World\n" encoding:NSISOLatin1StringEncoding];
	[outputStream writeString:[NSString stringWithFormat:@"Current Time : %@", [NSDate date]] encoding:NSISOLatin1StringEncoding];
	[outputStream writeString:@"\n\n====== Headers ======\n" encoding:NSISOLatin1StringEncoding];
	[outputStream writeString:[[request header] description] encoding:NSISOLatin1StringEncoding];
	[outputStream writeString:@"\n\n===== Parameters =====\n" encoding:NSISOLatin1StringEncoding];
	[outputStream writeString:[[request parameters] description] encoding:NSISOLatin1StringEncoding];

	[outputStream writeString:@"\n\n====== Uri ======\n" encoding:NSISOLatin1StringEncoding];
	[outputStream writeString:[request requestUri] encoding:NSISOLatin1StringEncoding];


}

@end
