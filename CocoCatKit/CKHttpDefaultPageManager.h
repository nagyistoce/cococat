/* Copyright (c) 2011 Glenn Ganz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>
#import <CocoCatKit/CKHttpDefaultPageManagers.h>

#define CKHTTP_RESPONSE_OK                      200
#define CKHTTP_RESPONSE_FOUND					302
#define CKHTTP_RESPONSE_NOT_FOUND				404
#define CKHTTP_RESPONSE_METHOD_NOT_ALLOWED      405
#define CKHTTP_RESPONSE_INTERNAL_SERVER_ERROR   500
#define CKHTTP_RESPONSE_NOT_IMPLEMENTED         501

@interface CKHttpDefaultPageManager : NSObject <CKHttpDefaultPageManagers> {

}

- init;
- (void)dealloc;

+ (CKHttpDefaultPageManager *)defaultManager;

- (NSString *)errorPageForCode:(unsigned int)code contextInfo:(id)contextInfo;
- (NSString *)textForCode:(unsigned int)code;


+ (NSString *)defaultTextForCode:(unsigned int)code;

@end
