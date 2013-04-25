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
    PublicService *ps = [PublicService alloc];
    PublicServiceGetSessionResults *r = [ps GetSession:@"sunfmin@gmail.com" password:@"nopassword"];
    [self setFelixAuthUserService:[ps GetAuthUserService:r.Session]];

    PublicServiceGetSessionResults *r1 = [ps GetSession:@"aaron@theplant.jp" password:@"nopassword"];
    [self setAaronAuthUserService:[ps GetAuthUserService:r1.Session]];
}

- (void)testGetClassifiedGroups {
    AuthUserServiceGetClassifiedGroupsResults *r = [_felixAuthUserService GetClassifiedGroups];
    Group *anoucement = r.AnouncementGroup;
    STAssertNotNil(anoucement, @"anouncementGroup is nil");
    STAssertTrue([anoucement.Name isEqualToString:@"Announcements"], @"anoucement group name is %@", anoucement.Name);
    STAssertTrue([r.FollowedGroups count] > 2, @"followed groups count is %@", [r.FollowedGroups count]);
}

// Too slow to execute, wait for Entry JSON to FIT
- (void)testGetMyFeedEntries {
    AuthUserServiceGetMyFeedEntriesResults *r = [_felixAuthUserService GetMyFeedEntries:@"" before:@"" limit:@20 withComments:false];
    STAssertTrue([r.Entries count] > 2, @"my feed entries count is %@", [r.Entries count]);
}

- (void)testGetEntry {
    AuthUserServiceGetEntryResults *r = [_felixAuthUserService GetEntry:@"515be30f3c5816634500593c" groupId:@"4fd78138558fbe76ff000028" updateAtUnixNanoForVersion:@"" hightlightKeywords:@""];
    STAssertEqualObjects(r.Entry.HtmlTitle, @"Monitoring Qortex – Questions", @"entry title is: %@", r.Entry);
}

- (void)testGetGroupEntries {
    AuthUserServiceGetGroupEntriesResults *r = [_felixAuthUserService GetGroupEntries:@"4fd78138558fbe76ff000028" entryType:@"" before:@"" limit:@20 withComments:NO];
    STAssertTrue([r.Entries count] > 2, @"group entries count is %@", [r.Entries count]);

}

- (void)testGetNewFeedEntries {
    AuthUserServiceGetMyFeedEntriesResults *lastEntriesResults = [_felixAuthUserService GetMyFeedEntries:@"" before:@"" limit:@1 withComments:NO];

    AuthUserServiceCreateEntryResults *newCreatedResult = [self createEntry];


    STAssertTrue(newCreatedResult.Err == nil, @"create entry error %@", newCreatedResult.Err);
    Entry *lastEntry = lastEntriesResults.Entries[0];
    NSString *nano = [NSString stringWithFormat:@"%.0f000000", [lastEntry.CreatedAt timeIntervalSince1970] * 1000 - 20000000];
    AuthUserServiceGetNewFeedEntriesResults *r2 = [_felixAuthUserService GetNewFeedEntries:@""
                                                                          fromTimeUnixNano:nano
                                                                                     limit:@2];
    Entry *newCreatedEntry = r2.Entries[0];
    STAssertEqualObjects(newCreatedEntry.Id, newCreatedResult.Entry.Id, @"new created entry wrong: %@", newCreatedEntry);

}

- (AuthUserServiceCreateEntryResults *)createEntry {
    AuthUserServiceGetNewEntryResults *newEntry = [_aaronAuthUserService GetNewEntry:@"4fd78138558fbe76ff000028"];
    EntryInput *input = [EntryInput alloc];


    NSString *title = [NSString stringWithFormat:@"New Entry %@", [NSDate date]];
    [input setTitle:title];
    [input setId:newEntry.Entry.Id];
    [input setGroupId:newEntry.Entry.GroupId];

    AuthUserServiceCreateEntryResults *newCreatedResult = [_aaronAuthUserService CreateEntry:input];
    return newCreatedResult;
}

- (void)testDeleteEntry {
    AuthUserServiceCreateEntryResults *newCreatedResult = [self createEntry];
    AuthUserServiceDeleteEntryResults *r = [_aaronAuthUserService DeleteEntry:newCreatedResult.Entry.Id groupId:newCreatedResult.Entry.Id dType:@"all"];
    STAssertTrue(r.Err == nil, @"error is %@", r.Err);
    AuthUserServiceGetEntryResults *findR = [_aaronAuthUserService GetEntry:newCreatedResult.Entry.Id groupId:newCreatedResult.Entry.GroupId updateAtUnixNanoForVersion:@"" hightlightKeywords:@""];
    STAssertTrue(findR.Entry == nil, @"delete failed entry is %@", findR.Entry);
}

- (void)testCreateEntryReturnError {
    EntryInput *input = [EntryInput alloc];
    [input setTitle:@"Hello"];
    AuthUserServiceCreateEntryResults *r = [_aaronAuthUserService CreateEntry:input];
    STAssertTrue(r.Err != nil, @"error is nil");
    STAssertEqualObjects([[r.Err.userInfo valueForKey:@"Errors"][0] valueForKey:@"Message"], @"Entry Id can't be blank", @"err is %@", r.Err);
}

@end
