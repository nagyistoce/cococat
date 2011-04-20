/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


#import "AJP13ForwardRequest.h"


@implementation AJP13ForwardRequest

//without data prefix code
- initWithData:(NSData *)someData
{
	header = [[NSMutableDictionary alloc] init];
	attributes = [[NSMutableDictionary alloc] init];
	parameters = [[NSMutableDictionary alloc] init];

	data = [someData retain];
	const unsigned char* bytes = [data bytes];
	NSUInteger length = [data length];

	//last byte must be a request terminator (0xFF)
	if (bytes[length -1] != 0xFF) {
		[self release];
		return nil;
	}
	
	method = bytes[0];
		
	_position = 1;
	protocol = [[self _readNextString] retain];
	reqUri = [[self _readNextString] retain];
	remoteAddr = [[self _readNextString] retain];
	remoteHost = [[self _readNextString] retain];
	serverName = [[self _readNextString] retain];
	serverPort = [self _readNextInteger];
	isSsl = [self _readNextBOOL];
	int numHeaderFields = [self _readNextInteger];
	for (int i = 0; i < numHeaderFields; i++) {
		int codeValue = [self _readNextInteger];
		NSString	*headerName = nil;
		unsigned int b1 = (unsigned int)((codeValue >> 8) & 0x00FF);
		if ((b1 & 0xA0) == 0xA0) {
			//header name is a int
			headerName = [self _lookupHeaderNameWithCodeValue:codeValue];
		}
		else {
			//header is a string
			_position -= 2;
			headerName = [self _readNextString];
		}

		NSString	*value = [self _readNextString];
		if (headerName != nil) {
			[header setObject:value forKey:headerName];
		}
	}
	
	unsigned int attributeCode = 0;
	while ((attributeCode = [self _readNextByte]) != 0xFF) {
		NSString	*attributeName = nil;
		
		if(attributeCode == 0x0A) {
			attributeName = [self _readNextString];
		}
		else {
			attributeName = [self _lookupAttributeNameWithCodeValue:attributeCode];
		}
		
		NSString	*value = [self _readNextString];
		if(attributeName != nil) {
			[attributes setObject:value forKey:attributeName];
		}
	}
	
	//derived
	NSString		*queryString = [attributes objectForKey:@"query_string"];
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
	
	[super dealloc];
}

- (NSString *)method
{
	switch(method) {
		case HTTPMETHOD_OPTIONS:
			return @"OPTIONS";
		case HTTPMETHOD_GET:
			return @"GET";
		case HTTPMETHOD_HEAD:
			return @"HEAD";		
		case HTTPMETHOD_POST:
			return @"POST";
		case HTTPMETHOD_PUT:
			return @"PUT";		
		case HTTPMETHOD_DELETE:
			return @"DELETE";		
		case HTTPMETHOD_TRACE:
			return @"TRACE";		
		case HTTPMETHOD_PROPFIND:
			return @"PROPFIND";
		default:
			return nil;
	}
}

- (NSString *)requestUri
{
	return reqUri;
}

- (NSDictionary *)header
{
	return header;
}

- (NSDictionary *)parameters
{
	return parameters;
}

//internal
- (NSString *)_readNextString
{
	NSString	*result = nil;
	unsigned const char *bytes = [data bytes];
	unsigned char b1 = bytes[_position++];
	unsigned char b2 = bytes[_position++];

	
	int length = (int)b1 << 8 | b2;
	
	if(length == -1) {
		return result;
	}
	
	result = [NSString stringWithCString:[data bytes]+_position encoding:NSISOLatin1StringEncoding];
	
	//skip null byte
	_position += length + 1;
	
	return result;
}

- (int)_readNextInteger
{
	int result = 0;
	unsigned const char *bytes = [data bytes];
	unsigned char b1 = bytes[_position++];
	unsigned char b2 = bytes[_position++];
	
	
	result = (int)b1 << 8 | b2;
	
	return result;
}

- (int)_readNextByte
{
	int result = 0;
	unsigned const char *bytes = [data bytes];
	unsigned char b1 = bytes[_position++];
		
	result = (int)b1;
	
	return result;
}

- (BOOL)_readNextBOOL
{
	unsigned const char *bytes = [data bytes];
	unsigned char b1 = bytes[_position++];
	
	if(b1 != 0) {
		return YES;
	}
	
	return NO;
}

- (NSString *)_lookupHeaderNameWithCodeValue:(int)codeValue
{
	switch(codeValue) {
		case 0xA001:
			return @"accept";
		case 0xA002:
			return @"accept-charset";
		case 0xA003:
			return @"accept-encoding";
		case 0xA004:
			return @"accept-language";
		case 0xA005:
			return @"authorization";
		case 0xA006:
			return @"connection";
		case 0xA007:
			return @"content-type";
		case 0xA008:
			return @"content-length";
		case 0xA009:
			return @"cookie";
		case 0xA00A:
			return @"cookie2";
		case 0xA00B:
			return @"host";
		case 0xA00C:
			return @"pragma";
		case 0xA00D:
			return @"referer";
		case 0xA00E:
			return @"user-agent";
		default:
			return nil;
	}
}

- (NSString *)_lookupAttributeNameWithCodeValue:(int)codeValue
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
