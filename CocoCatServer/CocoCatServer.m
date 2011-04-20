/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CocoCatServer.h"
#include <CocoCatKit/AJP13Server.h>
#include <CocoCatKit/HttpServer.h>
#include <CocoCatKit/HttpServletManager.h>
#import "AdminServlet.h"


@implementation CocoCatServer

- init
{
    adminServletManager = [[HttpServletManager alloc] init];
    [adminServletManager registerServlet:[[AdminServlet alloc] init] forUrlPattern:@".*"];
    
    servletManager = [[HttpServletManager alloc] init];
    
    ajpServer = [[AJP13Server alloc] initWithServletManager:servletManager];
    adminServer = [[AJP13Server alloc] initWithServletManager:adminServletManager];

    return self;
}

- (void)dealloc
{
    [adminServletManager release];
    [servletManager release];
    [ajpServer release];
    [adminServer release];
    
    [super dealloc];
}

- (void)listen:(unsigned int)ajpPort adminPort:(unsigned int)adminPort
{
}

@end
