/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "CKAJP13ForwardRequest.h"
#import "../../CKCookie.h"

@interface CKAJP13ForwardRequest(Private)

- (NSString *)readNextString;
- (int)readNextInteger;
- (int)readNextByte;
- (BOOL)readNextBOOL;
- (NSString *)lookupHeaderNameWithCodeValue:(int)codeValue;
- (NSString *)lookupAttributeNameWithCodeValue:(int)codeValue;

@end

@implementation CKAJP13ForwardRequest(Private)

- (NSString *)readNextString
{
	NSString	*result = nil;
	unsigned const char *bytes = [data bytes];
	unsigned char b1 = bytes[_position++];
	unsigned char b2 = bytes[_position++];
    
	
	int length = (int)b1 << 8 | b2;
	
	if (length == -1) {
		return result;
	}
	
	result = [NSString stringWithCString:[data bytes]+_position encoding:NSISOLatin1StringEncoding];
	
	//skip null byte
	_position += length + 1;
	
	return result;
}

- (int)readNextInteger
{
	int result = 0;
	unsigned const char *bytes = [data bytes];
	unsigned char b1 = bytes[_position++];
	unsigned char b2 = bytes[_position++];
	
	
	result = (int)b1 << 8 | b2;
	
	return result;
}

- (int)readNextByte
{
	int result = 0;
	unsigned const char *bytes = [data bytes];
	unsigned char b1 = bytes[_position++];
    
	result = (int)b1;
	
	return result;
}

- (BOOL)readNextBOOL
{
	unsigned const char *bytes = [data bytes];
	unsigned char b1 = bytes[_position++];
	
	if (b1 != 0) {
		return YES;
	}
	
	return NO;
}

- (NSString *)lookupHeaderNameWithCodeValue:(int)codeValue
{
	switch (codeValue) {
		case 0xA001:
			return @"Accept";
		case 0xA002:
			return @"Accept-Charset";
		case 0xA003:
			return @"Accept-Encoding";
		case 0xA004:
			return @"Accept-Language";
		case 0xA005:
			return @"Authorization";
		case 0xA006:
			return @"Connection";
		case 0xA007:
			return @"Content-Type";
		case 0xA008:
			return @"Content-Length";
		case 0xA009:
			return @"Cookie";
		case 0xA00A:
			return @"Cookie2";
		case 0xA00B:
			return @"Host";
		case 0xA00C:
			return @"Pragma";
		case 0xA00D:
			return @"Referer";
		case 0xA00E:
			return @"User-Agent";
		default:
			return nil;
	}
}

- (NSString *)lookupAttributeNameWithCodeValue:(int)codeValue
{
	switch(codeValue) {
		case 0x01:
			return @"context";
		case 0x02:
			return @"servlet_path";
		case 0x03:
			return @"remote_user";
		case 0x04:
			return @"auth_type";
		case 0x05:
			return @"query_string";
		case 0x06:
			return @"jvm_route";
		case 0x07:
			return @"ssl_cert";
		case 0x08:
			return @"ssl_cipher";
		case 0x09:
			return @"ssl_session";
		case 0x0A:
			return @"req_attribute";
		case 0x0B:
			return @"ssl_key_size";
		default:
			return nil;
	}
}

@end

@implementation CKAJP13ForwardRequest

//without data prefix code
- initWithData:(NSData *)someData contextPath:(NSString *)aContextPath
{
	header = [[NSMutableDictionary alloc] init];
	attributes = [[NSMutableDictionary alloc] init];
	parameters = [[NSMutableDictionary alloc] init];
    cookies = [[NSMutableArray alloc] init];

	data = [someData retain];
    contextPath = [aContextPath retain];
	const unsigned char* bytes = [data bytes];
	NSUInteger length = [data length];
    
    if (contextPath == nil) {
        contextPath = @"";
    }

	//last byte must be a request terminator (0xFF)
	if (bytes[length -1] != 0xFF) {
		[self release];
		return nil;
	}
	
	method = bytes[0];
		
	_position = 1;
	protocol = [[self readNextString] retain];
	reqUri = [[self readNextString] retain];
	remoteAddr = [[self readNextString] retain];
	remoteHost = [[self readNextString] retain];
	serverName = [[self readNextString] retain];
	serverPort = [self readNextInteger];
	isSsl = [self readNextBOOL];
	int numHeaderFields = [self readNextInteger];
	for (int i = 0; i < numHeaderFields; i++) {
		int codeValue = [self readNextInteger];
		NSString	*headerName = nil;
		unsigned int b1 = (unsigned int)((codeValue >> 8) & 0x00FF);
		if ((b1 & 0xA0) == 0xA0) {
			//header name is a int
			headerName = [self lookupHeaderNameWithCodeValue:codeValue];
		}
		else {
			//header is a string
			_position -= 2;
			headerName = [self readNextString];
		}

		NSString	*value = [self readNextString];
		if (headerName != nil) {
			[header setObject:value forKey:headerName];
		}
	}
	
	unsigned int attributeCode = 0;
	while ((attributeCode = [self readNextByte]) != 0xFF) {
		NSString	*attributeName = nil;
		
		if (attributeCode == 0x0A) {
			attributeName = [self readNextString];
		}
		else {
			attributeName = [self lookupAttributeNameWithCodeValue:attributeCode];
		}
		
		NSString	*value = [self readNextString];
		if (attributeName != nil) {
			[attributes setObject:value forKey:attributeName];
		}
	}
    
    if ([attributes objectForKey:@"ssl_session"] != nil) {
        secure = YES;
    }
    else {
        secure = NO;
    }
    
    queryString = [[attributes objectForKey:@"query_string"] retain];
	
	//derived
	NSArray			*keyValues = [queryString componentsSeparatedByString:@"&"];
	NSEnumerator	*kVEnumerator = [keyValues objectEnumerator];
	NSString		*keyValue;
	
	while ((keyValue = [kVEnumerator nextObject]) != nil) {
		NSRange range = [keyValue rangeOfString:@"="];
		if (range.location != NSNotFound) {
			NSString *name = [keyValue substringToIndex:range.location];
			NSString *value = [keyValue substringFromIndex:range.location + 1];
			[parameters setObject:value forKey:name];
		}
		else {
			[parameters setObject:@"" forKey:keyValue];
		}
	}
    
    NSString        *cookieHeaderString = [header objectForKey:@"Cookie"];
    NSArray         *cookieStrings = [cookieHeaderString componentsSeparatedByString:@"; "];
    NSEnumerator    *cookieEnumerator = [cookieStrings objectEnumerator];
    NSString        *cookieString;
    
    while ((cookieString = [cookieEnumerator nextObject]) != nil) {
        NSRange range = [cookieString rangeOfString:@"="];
        if (range.location != NSNotFound) {
            NSString	*name = [cookieString substringToIndex:range.location];
            NSString	*value = [cookieString substringFromIndex:range.location + 1];
            CKCookie	*cookie = [[[CKCookie alloc] initWithName:name withValue:value] autorelease];
            
			[cookies addObject:cookie];
        }
        else {
            CKCookie  *cookie = [[[CKCookie alloc] initWithName:cookieString withValue:@""] autorelease];
			
            [cookies addObject:cookie];
        }
    }
        
    [header removeObjectForKey:@"Cookie"];
    
    NSString        *cookie2HeaderString = [header objectForKey:@"Cookie2"];
    NSArray         *cookie2Strings = [cookie2HeaderString componentsSeparatedByString:@"; "];
    NSEnumerator    *cookie2Enumerator = [cookie2Strings objectEnumerator];
    NSString        *cookie2String;
    
    while ((cookie2String = [cookie2Enumerator nextObject]) != nil) {
        NSRange range = [cookie2String rangeOfString:@"="];
        if (range.location != NSNotFound) {
            NSString	*name = [cookie2String substringToIndex:range.location];
            NSString	*value = [cookie2String substringFromIndex:range.location + 1];
            CKCookie	*cookie = [[[CKCookie alloc] initWithName:name withValue:value] autorelease];
			
            [cookies addObject:cookie];
        }
        else {
            CKCookie  *cookie = [[[CKCookie alloc] initWithName:cookieString withValue:@""] autorelease];
			
            [cookies addObject:cookie];
        }
    }
    
    [header removeObjectForKey:@"Cookie2"];

	return self;
}

- (void)dealloc
{
	[protocol release];
	[reqUri release];
	[remoteAddr release];
	[remoteHost release];
	[serverName release];
	[header release];
	[attributes release];
	[parameters release];
    [cookies release];
    [contextPath release];
    [queryString release];
	
	[super dealloc];
}

- (void)setParameterData:(NSData *)someData
{
	NSString		*parametersString = [[[NSString alloc] initWithData:someData encoding:NSISOLatin1StringEncoding] autorelease];
	
    NSArray			*keyValues = [parametersString componentsSeparatedByString:@"&"];
    NSEnumerator	*kVEnumerator = [keyValues objectEnumerator];
    NSString		*keyValue;
    
    while ((keyValue = [kVEnumerator nextObject]) != nil) {
        NSRange range = [keyValue rangeOfString:@"="];
        if (range.location != NSNotFound) {
            NSString *name = [keyValue substringToIndex:range.location];
            NSString *value = [keyValue substringFromIndex:range.location + 1];
            [parameters setObject:value forKey:name];
        }
        else {
            [parameters setObject:@"" forKey:keyValue];
        }
    }
}

- (NSString *)method
{
	switch (method) {
		case CKAJP13_HTTPMETHOD_OPTIONS:
			return @"OPTIONS";
		case CKAJP13_HTTPMETHOD_GET:
			return @"GET";
		case CKAJP13_HTTPMETHOD_HEAD:
			return @"HEAD";		
		case CKAJP13_HTTPMETHOD_POST:
			return @"POST";
		case CKAJP13_HTTPMETHOD_PUT:
			return @"PUT";		
		case CKAJP13_HTTPMETHOD_DELETE:
			return @"DELETE";		
		case CKAJP13_HTTPMETHOD_TRACE:
			return @"TRACE";		
		case CKAJP13_HTTPMETHOD_PROPFIND:
			return @"PROPFIND";
		default:
			return nil;
	}
}

- (NSString *)requestUri
{
	return reqUri;
}

- (NSString *)requestUrl
{
    NSString    *protocolString = nil;
    if (secure == YES) {
        protocolString = @"https://";
    }
    else {
        protocolString = @"http://";

    }
 
    return [NSString stringWithFormat:@"%@%@%@%@", protocolString, [[self header] objectForKey:@"Host"], contextPath, [self requestUri]];
}

- (NSDictionary *)header
{
	return header;
}

- (NSDictionary *)parameters
{
	return parameters;
}

- (NSArray *)cookies
{
    return cookies;
}

- (NSString *)queryString
{
    return queryString;
}

- (NSString *)remoteAddr
{
    return remoteAddr;
}

- (NSString *)remoteHost
{
    if ([remoteHost length] <= 0) {
        [remoteHost release];
        remoteHost = [[[NSHost hostWithAddress:remoteAddr] name] retain];
        if (remoteHost == nil) {
            remoteHost = [remoteAddr retain];
        }
    }
    return remoteHost;
}

- (BOOL)secure
{
    return secure;
}

- (NSString *)contextPath
{
    return contextPath;
}

@end
