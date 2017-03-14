//
// Copyright (c) Badoo Trading Limited, 2010-present. All rights reserved.
//

@import XCTest;
#import <BMASpinningLabel/BMASpinningLabel.h>

@interface BMASpinningLabelTests : XCTestCase

@property (nonatomic) NSString *title;
@property (nonatomic) NSAttributedString *attributedTitle;
@property (nonatomic) BMASpinningLabel *label;

@end

@implementation BMASpinningLabelTests

- (void)setUp {
    [super setUp];
    self.label = [[BMASpinningLabel alloc] init];
    self.title = @"title";
    self.attributedTitle = [[NSAttributedString alloc] initWithString:self.title];
}

- (void)tearDown {
    self.label = nil;
    self.title = nil;
    self.attributedTitle= nil;
    [super tearDown];
}

- (void)testThat_WhenCreated_ThenTitleIsNil {
    XCTAssertNil(self.label.title);
}

- (void)testThat_GivenLabel_WhenSetTitle_ThenLabelRetunsNewTitleValue {
    // Test
    self.label.title = self.title;
    
    // Verify
    XCTAssertEqualObjects(self.label.title, self.title);
}

- (void)testThat_GivenEmptyLabel_WhenSetTitleWithAnimation_ThenLabelRetunsNewTitleValue {
    // Test
    [self.label setAttributedTitle:self.attributedTitle spinDirection:BMASpinDirectionUpward spinSettings:BMASpinSettingsAnimated];
    
    // Verify
    XCTAssertEqualObjects(self.label.attributedTitle, self.attributedTitle);
}

- (void)testThat_GivenLabelWithTitle_WhenSetTitleWithAnimation_ThenLabelRetunsNewTitleValue {
    // Setup
    [self setupLabelWithInitialTitle:@"initial" runningAnimation:nil pendingAnimation:nil];

    // Test
    [self.label setAttributedTitle:self.attributedTitle spinDirection:BMASpinDirectionUpward spinSettings:BMASpinSettingsAnimated];

    // Verify
    XCTAssertEqualObjects(self.label.attributedTitle, self.attributedTitle);
}

- (void)testThat_GivenLabelWithTitleAndRunningAnimation_WhenSetTitleWithAnimation_ThenLabelRetunsNewTitleValue {
    // Setup
    [self setupLabelWithInitialTitle:@"initial" runningAnimation:@"current" pendingAnimation:nil];
    
    // Test
    [self.label setAttributedTitle:self.attributedTitle spinDirection:BMASpinDirectionUpward spinSettings:BMASpinSettingsAnimated];
    
    // Verify
    XCTAssertEqualObjects(self.label.attributedTitle, self.attributedTitle);
}

- (void)testThat_GivenLabelWithTitleAndRunningAnimation_WhenSetTitleWithoutAnimation_ThenLabelRetunsNewTitleValue {
    // Setup
    [self setupLabelWithInitialTitle:@"initial" runningAnimation:@"current" pendingAnimation:nil];
    
    // Test
    self.label.attributedTitle = self.attributedTitle;

    // Verify
    XCTAssertEqualObjects(self.label.attributedTitle, self.attributedTitle);
}

- (void)testThat_GivenLabelWithTitle_WhenSetTitleWithAnimation_ThenChangePerformedWithAnimation {
    // Setup
    [self setupLabelWithInitialTitle:@"initial" runningAnimation:nil pendingAnimation:nil];
    
    // Test
    [self.label setAttributedTitle:self.attributedTitle spinDirection:BMASpinDirectionUpward spinSettings:BMASpinSettingsAnimated];
    
    // Verify
    XCTAssertTrue(self.label.isAnimating);
}

- (void)testThat_GivenLabelWithTitle_WhenSettitleWithAnimationAndWaitForLayout_ThenAnimationNotStartedImmediately {
    // Setup
    [self setupLabelWithInitialTitle:@"initial" runningAnimation:nil pendingAnimation:nil];
    
    // Test
    [self.label setAttributedTitle:self.attributedTitle spinDirection:BMASpinDirectionUpward spinSettings:BMASpinSettingsAnimated | BMASpinSettingsWaitForLayout];
    
    // Verify
    XCTAssertFalse(self.label.isAnimating);
}

- (void)testThat_GivenLabelWithTitleAndPendingAnimationAfterLayout_WhenUpdateLayout_ThenChangePerformedWithAnimation {
    // Setup
    [self setupLabelWithInitialTitle:@"initial" runningAnimation:nil pendingAnimation:nil];
    [self.label setAttributedTitle:self.attributedTitle spinDirection:BMASpinDirectionUpward spinSettings:BMASpinSettingsAnimated | BMASpinSettingsWaitForLayout];
    
    // Test
    [self.label layoutIfNeeded];
    
    // Verify
    XCTAssertTrue(self.label.isAnimating);
    XCTAssertEqualObjects(self.label.attributedTitle, self.attributedTitle);
}

#pragma mark - Helpers

- (void)setupLabelWithInitialTitle:(NSString *)initialTitle runningAnimation:(NSString *)newTitle pendingAnimation:(NSString *)pendingTitle {
    if (initialTitle) {
        self.label.title = initialTitle;
    }
    if (newTitle) {
        [self.label setAttributedTitle:[[NSAttributedString alloc] initWithString:newTitle] spinDirection:BMASpinDirectionUpward spinSettings:BMASpinSettingsAnimated];
    }
    if (pendingTitle) {
        [self.label setAttributedTitle:[[NSAttributedString alloc] initWithString:pendingTitle] spinDirection:BMASpinDirectionUpward spinSettings:BMASpinSettingsAnimated];
    }
}

@end
