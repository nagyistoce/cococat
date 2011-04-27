/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "FormTestServlet.h"

@implementation FormTestServlet

- init
{
	return self;
}

- (void)doGet:(HttpServletRequest *)request response:(HttpServletResponse *)response
{
	HttpServletOutputStream *outputStream = [response outputStream];
	
	[response setHeaderValue:@"text/html" forName:@"Content-Type"];
    
    [outputStream writeString:@"<html><form name=\"input\" action=\"FormTestServlet\" method=\"post\">\n" encoding:NSISOLatin1StringEncoding];
    [outputStream writeString:@"Name: <input type=\"text\" name=\"name\" />" encoding:NSISOLatin1StringEncoding];
    [outputStream writeString:@"<input type=\"submit\" value=\"Submit\" /></html>" encoding:NSISOLatin1StringEncoding];
    [outputStream writeString:@"</form>" encoding:NSISOLatin1StringEncoding];
}

- (void)doPost:(HttpServletRequest *)request response:(HttpServletResponse *)response
{
    HttpServletOutputStream *outputStream = [response outputStream];

    [response setHeaderValue:@"text/plain" forName:@"Content-Type"];

    [outputStream writeString:[NSString stringWithFormat:@"Hello %@", [[request parameters] objectForKey:@"name"]] encoding:NSISOLatin1StringEncoding];	
}


@end
