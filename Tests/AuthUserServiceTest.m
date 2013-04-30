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
    [[QXQortexapi get] setBaseURL:@"http://localhost:5000/api"];
    [[QXQortexapi get] setVerbose:YES];
    QXPublicService *ps = [QXPublicService alloc];
    QXPublicServiceGetSessionResults *r = [ps GetSession:@"sunfmin@gmail.com" password:@"nopassword"];
    [self setFelixAuthUserService:[ps GetAuthUserService:r.Session]];

    QXPublicServiceGetSessionResults *r1 = [ps GetSession:@"aaron@theplant.jp" password:@"nopassword"];
    [self setAaronAuthUserService:[ps GetAuthUserService:r1.Session]];
}

- (void)testGetClassifiedGroups {
    QXAuthUserServiceGetClassifiedGroupsResults *r = [_felixAuthUserService GetClassifiedGroups];
    QXGroup *anoucement = r.AnouncementGroup;
    STAssertNotNil(anoucement, @"anouncementGroup is nil");
    STAssertTrue([anoucement.Name isEqualToString:@"Announcements"], @"anoucement group name is %@", anoucement.Name);
    STAssertTrue([r.FollowedNormalGroups count] > 2, @"followed groups count is %@", [r.FollowedNormalGroups count]);
}

// Too slow to execute, wait for Entry JSON to FIT
- (void)testGetMyFeedEntries {
    QXAuthUserServiceGetMyFeedEntriesResults *r = [_felixAuthUserService GetMyFeedEntries:@"" before:@"" limit:@20 withComments:false];
    STAssertTrue([r.Entries count] > 2, @"my feed entries count is %@", [r.Entries count]);
}

- (void)testGetEntry {
    QXAuthUserServiceGetEntryResults *r = [_felixAuthUserService GetEntry:@"515be30f3c5816634500593c" groupId:@"4fd78138558fbe76ff000028" updateAtUnixNanoForVersion:@"" hightlightKeywords:@""];
    STAssertEqualObjects(r.Entry.HtmlTitle, @"Monitoring Qortex – Questions", @"entry title is: %@", r.Entry);
}

- (void)testGetGroupEntries {
    QXAuthUserServiceGetGroupEntriesResults *r = [_felixAuthUserService GetGroupEntries:@"4fd78138558fbe76ff000028" entryType:@"" before:@"" limit:@20 withComments:NO];
    STAssertTrue([r.Entries count] > 2, @"group entries count is %@", [r.Entries count]);

}

- (void)testGetNewFeedEntries {
    QXAuthUserServiceGetMyFeedEntriesResults *lastEntriesResults = [_felixAuthUserService GetMyFeedEntries:@"" before:@"" limit:@1 withComments:NO];

    QXAuthUserServiceCreateEntryResults *newCreatedResult = [self createEntry];


    STAssertTrue(newCreatedResult.Err == nil, @"create entry error %@", newCreatedResult.Err);
    QXEntry *lastEntry = lastEntriesResults.Entries[0];
    NSString *nano = [NSString stringWithFormat:@"%.0f000000", [lastEntry.CreatedAt timeIntervalSince1970] * 1000 - 20000000];
    QXAuthUserServiceGetNewFeedEntriesResults *r2 = [_felixAuthUserService GetNewFeedEntries:@""
                                                                          fromTimeUnixNano:nano
                                                                                     limit:@2];
    QXEntry *newCreatedEntry = r2.Entries[0];
    STAssertEqualObjects(newCreatedEntry.Id, newCreatedResult.Entry.Id, @"new created entry wrong: %@", newCreatedEntry);

}

- (QXAuthUserServiceCreateEntryResults *)createEntry {
    QXAuthUserServiceGetNewEntryResults *newEntry = [_aaronAuthUserService GetNewEntry:@"4fd78138558fbe76ff000028"];
    QXEntryInput *input = [QXEntryInput alloc];


    NSString *title = [NSString stringWithFormat:@"New Entry %@", [NSDate date]];
    [input setTitle:title];
    [input setId:newEntry.Entry.Id];
    [input setGroupId:newEntry.Entry.GroupId];

    QXAuthUserServiceCreateEntryResults *newCreatedResult = [_aaronAuthUserService CreateEntry:input];
    return newCreatedResult;
}

- (void)testDeleteEntry {
    QXAuthUserServiceCreateEntryResults *newCreatedResult = [self createEntry];
    QXAuthUserServiceDeleteEntryResults *r = [_aaronAuthUserService DeleteEntry:newCreatedResult.Entry.Id groupId:newCreatedResult.Entry.Id dType:@"all"];
    STAssertTrue(r.Err == nil, @"error is %@", r.Err);
    QXAuthUserServiceGetEntryResults *findR = [_aaronAuthUserService GetEntry:newCreatedResult.Entry.Id groupId:newCreatedResult.Entry.GroupId updateAtUnixNanoForVersion:@"" hightlightKeywords:@""];
    STAssertTrue(findR.Entry == nil, @"delete failed entry is %@", findR.Entry);
}

- (void)testCreateEntryReturnError {
    QXEntryInput *input = [QXEntryInput alloc];
    [input setTitle:@"Hello"];
    QXAuthUserServiceCreateEntryResults *r = [_aaronAuthUserService CreateEntry:input];
    STAssertTrue(r.Err != nil, @"error is nil");
    STAssertEqualObjects([[r.Err.userInfo valueForKey:@"Errors"][0] valueForKey:@"Message"], @"Entry Id can't be blank", @"err is %@", r.Err);
}

- (void)testCreateBroadcast {
    
    QXAuthUserServiceGetNewEntryResults *newEntry = [_aaronAuthUserService GetNewEntry:@"4fd78138558fbe76ff000028"];
    QXBroadcastInput *input = [QXBroadcastInput alloc];
    [input setTitle: @"Hello"];
    [input setId: newEntry.Entry.Id];
    [input setContent: @"Hello everyone"];
    
    
}

@end
