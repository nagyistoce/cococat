/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


#import <Foundation/Foundation.h>

#import "../ServletRequestMessage.h"

#define HTTPMETHOD_OPTIONS			1
#define HTTPMETHOD_GET				2
#define HTTPMETHOD_HEAD				3
#define HTTPMETHOD_POST				4
#define HTTPMETHOD_PUT				5
#define HTTPMETHOD_DELETE			6
#define HTTPMETHOD_TRACE			7
#define HTTPMETHOD_PROPFIND			8
#define HTTPMETHOD_PROPPATCH		9
#define HTTPMETHOD_MKCOL			10
#define HTTPMETHOD_COPY				11
#define HTTPMETHOD_MOVE				12
#define HTTPMETHOD_LOCK				13
#define HTTPMETHOD_UNLOCK			14
#define HTTPMETHOD_ACL				15
#define HTTPMETHOD_REPORT			16
#define HTTPMETHOD_VERSION_CONTROL	17
#define HTTPMETHOD_CHECKIN			18
#define HTTPMETHOD_CHECKOUT			19
#define HTTPMETHOD_UNCHECKOUT		20
#define HTTPMETHOD_SEARCH			21
#define HTTPMETHOD_MKWORKSPACE		22
#define HTTPMETHOD_UPDATE			23
#define HTTPMETHOD_LABEL			24
#define HTTPMETHOD_MERGE			25
#define HTTPMETHOD_BASELINE_CONTROL	26
#define HTTPMETHOD_MKACTIVITY		27

@interface AJP13ForwardRequest : NSObject <ServletRequestMessage> {
	unsigned int		method;
	NSString			*protocol;
	NSString			*reqUri;
	NSString			*remoteAddr;
	NSString			*remoteHost;
	NSString			*serverName;
	unsigned int		serverPort;
	BOOL				isSsl;
	NSMutableDictionary	*header;
	NSMutableDictionary	*attributes;
	NSData				*data;
	
	//derived
	NSMutableDictionary	*parameters;
	
	//only used for initializing
	unsigned int		_position;
}

//without data prefix code
- initWithData:(NSData *)someData;
- (void)dealloc;

- (NSString *)method;
- (NSString *)requestUri;
- (NSDictionary *)header;
- (NSDictionary *)parameters;

//internal
- (NSString *)_readNextString;
- (int)_readNextInteger;
- (int)_readNextByte;
- (BOOL)_readNextBOOL;
- (NSString *)_lookupHeaderNameWithCodeValue:(int)codeValue;
- (NSString *)_lookupAttributeNameWithCodeValue:(int)codeValue;

@end
