/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>
#import "../CKServletRequestMessage.h"

#define CKAJP13_HTTPMETHOD_OPTIONS			1
#define CKAJP13_HTTPMETHOD_GET				2
#define CKAJP13_HTTPMETHOD_HEAD				3
#define CKAJP13_HTTPMETHOD_POST				4
#define CKAJP13_HTTPMETHOD_PUT				5
#define CKAJP13_HTTPMETHOD_DELETE           6
#define CKAJP13_HTTPMETHOD_TRACE            7
#define CKAJP13_HTTPMETHOD_PROPFIND			8
#define CKAJP13_HTTPMETHOD_PROPPATCH        9
#define CKAJP13_HTTPMETHOD_MKCOL            10
#define CKAJP13_HTTPMETHOD_COPY				11
#define CKAJP13_HTTPMETHOD_MOVE				12
#define CKAJP13_HTTPMETHOD_LOCK				13
#define CKAJP13_HTTPMETHOD_UNLOCK           14
#define CKAJP13_HTTPMETHOD_ACL				15
#define CKAJP13_HTTPMETHOD_REPORT           16
#define CKAJP13_HTTPMETHOD_VERSION_CONTROL	17
#define CKAJP13_HTTPMETHOD_CHECKIN			18
#define CKAJP13_HTTPMETHOD_CHECKOUT			19
#define CKAJP13_HTTPMETHOD_UNCHECKOUT       20
#define CKAJP13_HTTPMETHOD_SEARCH           21
#define CKAJP13_HTTPMETHOD_MKWORKSPACE		22
#define CKAJP13_HTTPMETHOD_UPDATE           23
#define CKAJP13_HTTPMETHOD_LABEL            24
#define CKAJP13_HTTPMETHOD_MERGE            25
#define CKAJP13_HTTPMETHOD_BASELINE_CONTROL	26
#define CKAJP13_HTTPMETHOD_MKACTIVITY       27

@interface CKAJP13ForwardRequest : NSObject <CKServletRequestMessage> {
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
    NSMutableArray      *cookies;
	NSData				*data;
    NSString            *mountPath;
    BOOL                secure;
    NSString            *queryString;
	
	//derived
	NSMutableDictionary	*parameters;
	
	//only used for initializing
	unsigned int		_position;
}

//without data prefix code
- initWithData:(NSData *)someData mountPath:(NSString *)aMountPath;
- (void)dealloc;
- (void)setParameterData:(NSData *)someData;

- (NSString *)method;
- (NSString *)requestUri;
- (NSDictionary *)header;
- (NSDictionary *)parameters;
- (NSArray *)cookies;
- (NSString *)queryString;
- (NSString *)remoteAddr;
- (NSString *)remoteHost;
- (BOOL)secure;

@end
