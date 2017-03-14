//
// Copyright (c) Badoo Trading Limited, 2010-present. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BMASpinDirection) {
    BMASpinDirectionDownward,
    BMASpinDirectionUpward
};

typedef NS_OPTIONS(NSUInteger, BMASpinSettings) {
    BMASpinSettingsNone = 0,
    BMASpinSettingsAnimated = 1,
    BMASpinSettingsWaitForLayout = (1 << 1)
};

@interface BMASpinningLabel : UIView

@property (nonatomic, nullable) NSString *title;
@property (nonatomic, nullable) NSAttributedString *attributedTitle;
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;

- (void)setAttributedTitle:(nullable NSAttributedString *)title
             spinDirection:(BMASpinDirection)spinDirection
              spinSettings:(BMASpinSettings)spinSettings;

@end

NS_ASSUME_NONNULL_END
