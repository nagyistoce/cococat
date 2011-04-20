#import <Foundation/Foundation.h>
#import "AJP13Server.h"
#import "HelloWorldServlet.h"
#import "HttpServletManager.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	[[HttpServletManager defaultManager] registerServlet:[[HelloWorldServlet alloc] init] forUrlPattern:@".*"];

	AJP13Server *server = [[[AJP13Server alloc] init] autorelease];
	[server listen:8009];
		
	[[NSRunLoop currentRunLoop] run];
    
	[pool drain];
    return 0;
}
