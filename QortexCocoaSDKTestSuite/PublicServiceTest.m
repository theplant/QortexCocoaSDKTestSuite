//
//  PublicServiceTest.m
//  PublicServiceTest
//
//  Created by Felix Sun on 04/17/13.
//  Copyright (c) 2013 The Plant. All rights reserved.
//

#import "PublicServiceTest.h"
#import "Qortexapi.h"

@implementation PublicServiceTest

- (void)setUp {
	[super setUp];
	[[Qortexapi get] setBaseURL:@"http://localhost:5000/api"];
	[[Qortexapi get] setVerbose:YES];
	[self setPublicService:[PublicService alloc]];
}

- (void)tearDown {

	[super tearDown];
}

- (void)testGetSession {
	PublicServiceGetSessionResults *r = [_publicService GetSession:@"sunfmin@gmail.com" password:@"nopassword"];
	STAssertTrue([r.Session length] > 10, @"session is nil for correct password: %@", r.Session);
}

- (void)testGetSessionWithWrongLogin {
	PublicServiceGetSessionResults *r = [_publicService GetSession:@"user@gmail.com" password:@"wrongpassword"];
	STAssertTrue([r.Session isEqualToString:@""], @"session not nil for wrong password %@", r.Session);
	STAssertTrue(r.Err != nil, @"err is nil %@", r.Err);
	STAssertTrue(r.Err.code == 405, @"Error code is wrong %@", r.Err);
}

@end
