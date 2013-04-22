//
//  AuthUserServiceTest.m
//  QortexCocoaSDKTestSuite
//
//  Created by Felix Sun on 4/22/13.
//  Copyright (c) 2013 The Plant. All rights reserved.
//

#import "AuthUserServiceTest.h"
#import "Qortexapi.h"

@implementation AuthUserServiceTest
- (void)setUp {
	[super setUp];
	[[Qortexapi get] setBaseURL:@"http://localhost:5000/api"];
	[[Qortexapi get] setVerbose:YES];
    PublicService * ps = [PublicService alloc];
    PublicServiceGetSessionResults *r = [ps GetSession:@"sunfmin@gmail.com" password:@"nopassword"];
	[self setAuthUserService: [ps GetAuthUserService:r.Session]];
}

- (void)testGetClassifiedGroups{
    AuthUserServiceGetClassifiedGroupsResults *r = [_authUserService GetClassifiedGroups];
    Group * anoucement = r.AnouncementGroup;
    STAssertNotNil(anoucement, @"anouncementGroup is nil");
    STAssertTrue([anoucement.Name isEqualToString:@"Announcements"], @"anoucement group name is %@", anoucement.Name);
    STAssertTrue([r.FollowedGroups count] > 2, @"followed groups count is @d", [r.FollowedGroups count]);
}
@end
