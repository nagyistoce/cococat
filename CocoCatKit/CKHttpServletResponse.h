/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>
#import <CocoCatKit/CKServletResponse.h>

@protocol CKServletResponseMessage;
@class CKHttpServletOutputStream;
@class CKCookie;

@interface CKHttpServletResponse : NSObject <CKServletResponse> {
	id<CKServletResponseMessage>	responseMessage;
	unsigned						int status;
	CKHttpServletOutputStream		*outputStream;
	NSMutableDictionary				*header;
    NSMutableArray					*cookies;
}

- initWithServletResponseMessage:(id<CKServletResponseMessage>)aResponseMessage;
- (void)dealloc;

- (void)setStatus:(unsigned int)aStatus;
- (unsigned int)status;

- (void)setHeaderValue:(NSString *)value forName:(NSString *)name;
- (void)setIntHeaderValue:(int)value forName:(NSString *)name;
- (NSDictionary *)header;

- (void)setContentLength:(int)length;
- (void)setContentType:(NSString *)type;

- (CKHttpServletOutputStream *)outputStream;

- (void)addCookie:(CKCookie *)cookie;

- (void)sendError:(unsigned int)error;
- (void)sendError:(unsigned int)error message:(NSString *)message;
- (void)sendError:(unsigned int)error message:(NSString *)message contextInfo:(id)contextInfo;
- (void)sendRedirect:(NSString *)location;

- (void)writeData:(NSData *)data;
- (unsigned int)responsePayloadSize;

- (BOOL)isCommitted;

@end
