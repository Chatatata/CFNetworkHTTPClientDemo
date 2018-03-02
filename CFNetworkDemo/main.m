//
//  main.m
//  CFNetworkDemo
//
//  Created by Buğra Ekuklu on 2.03.2018.
//  Copyright © 2018 BuyBuddy. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <CFNetwork/CFNetwork.h>
#import <stdio.h>
#import <stdlib.h>

int main(int argc, const char * argv[]) {
    CFStringRef bodyString = CFSTR("");
    CFDataRef bodyData =
    CFStringCreateExternalRepresentation(kCFAllocatorDefault,
                                         bodyString,
                                         kCFStringEncodingUTF8,
                                         0);
    
    CFStringRef urlString = CFSTR("http://example.com");
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, urlString, NULL);
    
    CFStringRef requestMethod = CFSTR("GET");
    CFHTTPMessageRef request = CFHTTPMessageCreateRequest(kCFAllocatorDefault,
                                                          requestMethod,
                                                          url,
                                                          kCFHTTPVersion1_1);
    
    //  Set body
    CFHTTPMessageSetBody(request,
                         bodyData);
    
    //  Add header fields
    CFHTTPMessageSetHeaderFieldValue(request,
                                     CFSTR("X-My-Favorite-Field"),
                                     CFSTR("Dreams"));
    CFHTTPMessageSetHeaderFieldValue(request,
                                     CFSTR("Host"),
                                     CFSTR("example.com"));
    
    
//    CFDataRef serializedRequest = CFHTTPMessageCopySerializedMessage(request);
//    CFStringRef serializedRequestString = CFStringCreateFromExternalRepresentation(kCFAllocatorDefault, serializedRequest, kCFStringEncodingUTF8);
//
//    printf("Serialized Request: %s\n", CFStringGetCStringPtr(serializedRequestString, kCFStringEncodingUTF8));

    CFReadStreamRef readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault,
                                                                  request);
    
    BOOL readStreamSuccess = CFReadStreamOpen(readStream);
    
    if (!readStreamSuccess) {
        fputs("cannot open read stream", stderr);
        
        exit(9);
    }
    
    UInt8 *buffer = calloc(BUFSIZ, sizeof(UInt8));
    
    while (CFReadStreamRead(readStream, buffer, BUFSIZ) > 0) {
        printf("%s", buffer);
        
        memset(buffer, 0, BUFSIZ * sizeof(UInt8));
    }
    
    CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault,
                                                            200,
                                                            CFSTR("OK"),
                                                            kCFHTTPVersion1_1);
    
    CFDataRef responseBodyData = CFHTTPMessageCopyBody(response);
    
    CFStringRef responseBodyString = CFStringCreateFromExternalRepresentation(kCFAllocatorDefault,
                                                                              responseBodyData,
                                                                              kCFStringEncodingUTF8);
    
    UInt64 responseStatusCode = CFHTTPMessageGetResponseStatusCode(response);
    
    printf("Body: \n%s\n, status code: %llu\n",
           CFStringGetCStringPtr(responseBodyString,
                                 kCFStringEncodingUTF8),
           responseStatusCode);
    
    return 0;
}
