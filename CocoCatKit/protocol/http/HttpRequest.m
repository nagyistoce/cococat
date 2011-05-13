/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "HttpRequest.h"
#import "../../Cookie.h"

@implementation HttpRequest

- initWithData:(NSData *)someData secure:(BOOL)isSecure
{
    NSString	*headerString = [[[NSString alloc]initWithData:someData encoding:NSISOLatin1StringEncoding] autorelease];
	NSScanner	*scanner = [NSScanner scannerWithString:headerString];
	
	header = [[NSMutableDictionary alloc] init];
	parameters = [[NSMutableDictionary alloc] init];
    cookies = [[NSMutableArray alloc] init];
    secure = isSecure;

	if ([scanner scanUpToString:@" " intoString:&method] != YES) {
		[self release];
		return nil;
	}
	[method retain];
	
	NSString *fullUri;
	if ([scanner scanUpToString:@" " intoString:&fullUri] != YES) {
		[self release];
		return nil;
	}
	NSRange parameterDelimiterPosition = [fullUri rangeOfString:@"?"];
	if (parameterDelimiterPosition.location != NSNotFound) {
		requestUri = [[fullUri substringToIndex:parameterDelimiterPosition.location] retain];
        queryString = [[fullUri substringFromIndex:parameterDelimiterPosition.location + 1] retain];
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
		
	}
	else {
		requestUri = [fullUri retain];
	}

	if ([scanner scanUpToString:@"\r\n" intoString:&httpVersion] != YES) {
		[self release];
		return nil;
	}
	[httpVersion retain];
	NSString	*keyValue;
	while ([scanner scanUpToString:@"\r\n" intoString:&keyValue] == YES) {
		NSRange range = [keyValue rangeOfString:@": "];
		if (range.location != NSNotFound) {
			NSString *name = [keyValue substringToIndex:range.location];
			NSString *value = [keyValue substringFromIndex:range.location + 2];
			[header setObject:value forKey:name];
		}
		else {
			[header setObject:@"" forKey:keyValue];
		}
		
	}
	[httpVersion retain];
    
    NSString        *cookieHeaderString = [header objectForKey:@"Cookie"];
    NSArray         *cookieStrings = [cookieHeaderString componentsSeparatedByString:@"; "];
    NSEnumerator    *cookieEnumerator = [cookieStrings objectEnumerator];
    NSString        *cookieString;

    while ((cookieString = [cookieEnumerator nextObject]) != nil) {
        NSRange range = [cookieString rangeOfString:@"="];
        if (range.location != NSNotFound) {
            NSString *name = [cookieString substringToIndex:range.location];
            NSString *value = [cookieString substringFromIndex:range.location + 1];
            Cookie  *cookie = [[[Cookie alloc] initWithName:name withValue:value] autorelease];
            [cookies addObject:cookie];
        }
        else {
            Cookie  *cookie = [[[Cookie alloc] initWithName:cookieString withValue:@""] autorelease];
            [cookies addObject:cookie];
        }
    }
    
    [header removeObjectForKey:@"Cookie"];
        		
	return self;
}

- (void)dealloc
{
    [method release];
	[requestUri release];
	[httpVersion release];
	[header release];
	[parameters release];
    [queryString release];
	
	[super dealloc];
}

- (NSString *)method
{
	return method;
}

- (NSString *)requestUri
{
	return requestUri;
}

- (NSString *)requestUrl
{
    if (secure == YES) {
        return [NSString stringWithFormat:@"https://%@%@", [[self header] objectForKey:@"Host"], [self requestUri]];
    }
    else {
        return [NSString stringWithFormat:@"http://%@%@", [[self header] objectForKey:@"Host"], [self requestUri]];
    }
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
- (BOOL)secure
{
    return secure;
}

- (void)setParameterData:(NSData *)data
{
    NSString    *parametersString = [[[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] autorelease];
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

@end
