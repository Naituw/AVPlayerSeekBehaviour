//
//  AVPlayerSeekBehaviourTests.m
//  AVPlayerSeekBehaviourTests
//
//  Created by Wu Tian on 8/11/20.
//  Copyright © 2020 Wu Tian. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerSeekBehaviourTests : XCTestCase

@end

@implementation AVPlayerSeekBehaviourTests

- (void)testSeek
{
    __auto_type player = [self playerReadyForTest];
    
    __auto_type seek1Exp = [self expectationWithDescription:@"First Seek"];
    __auto_type seek2Exp = [self expectationWithDescription:@"Second Seek"];
    __auto_type seek3Exp = [self expectationWithDescription:@"Third Seek"];
    
    const __auto_type seek1Pos =  1;
    const __auto_type seek2Pos = 10;
    const __auto_type seek3Pos = 15;
    
    __auto_type seekCompleteOrder = [NSMutableArray array];
    __auto_type seekCompleteResults = [NSMutableArray array];
    __auto_type __block seekCompletePosition = 0.;
    
    [player.currentItem seekToTime:CMTimeMakeWithSeconds(seek1Pos, 1) completionHandler:^(BOOL finished1) {
        [seekCompleteOrder addObject:@0];
        [seekCompleteResults addObject:@(finished1)];
        [seek1Exp fulfill];
        
        [player.currentItem seekToTime:CMTimeMakeWithSeconds(seek2Pos, 1) completionHandler:^(BOOL finished2) {
            [seekCompleteOrder addObject:@2];
            [seekCompleteResults addObject:@(finished2)];
            seekCompletePosition = CMTimeGetSeconds(player.currentTime);
            [seek2Exp fulfill];
        }];
    }];
    
    [player.currentItem seekToTime:CMTimeMakeWithSeconds(seek3Pos, 1) completionHandler:^(BOOL finished3) {
        [seekCompleteOrder addObject:@1];
        [seekCompleteResults addObject:@(finished3)];
        [seek3Exp fulfill];
    }];
    
    [self waitForExpectations:@[seek1Exp, seek2Exp, seek3Exp] timeout:10];
    
    __auto_type expectedOrder = @[@0, @1, @2];
    __auto_type expectedResults = @[@NO, @NO, @YES];

    XCTAssertEqualObjects(seekCompleteOrder, expectedOrder);
    XCTAssertEqualObjects(seekCompleteResults, expectedResults);
    XCTAssertLessThan(ABS(seekCompletePosition - seek2Pos), 1);
}

- (AVPlayer *)playerReadyForTest
{
    __auto_type path = [[NSBundle bundleForClass:[self class]] pathForResource:@"video" ofType:@"mp4"];
    XCTAssertNotNil(path);

    __auto_type player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
//    __auto_type player = [AVPlayer playerWithURL:[NSURL URLWithString:@"http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear3/prog_index.m3u8"]];
    XCTAssertNotNil(player);
    
    __auto_type playerItem = player.currentItem;
    
    {
        __auto_type expectation = [[XCTKVOExpectation alloc] initWithKeyPath:@"status" object:playerItem expectedValue:@(AVPlayerItemStatusReadyToPlay)];
        
        [self waitForExpectations:@[expectation] timeout:5];
    }
    
    XCTAssertEqual(playerItem.status, AVPlayerItemStatusReadyToPlay);

    return player;
}

@end
