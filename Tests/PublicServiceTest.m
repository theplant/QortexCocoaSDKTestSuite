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
	[[Qortexapi get] setVerbose:NO];
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

- (void)testGetBlogEntries {
	PublicServiceGetBlogEntriesResults *r = [_publicService GetBlogEntries:@"theplant" pageNum:@1 limit:@10];
	STAssertTrue(r.Err == nil, @"has error %@", r.Err);
	STAssertTrue([r.BlogEntries count] > 0, @"blog entries count is %d", [r.BlogEntries count]);
	BlogEntry *be = r.BlogEntries[0];
	STAssertTrue(be.CreatedAt != nil, @"created at is %@", be.CreatedAt);
	STAssertEqualObjects(@"Anatole Varin", be.Author.Name, @"author is %@", be.Author.Name);
}

@end
