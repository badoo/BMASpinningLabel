//
// Copyright (c) Badoo Trading Limited, 2010-present. All rights reserved.
//

#import "BMASpinningLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BMASpinningLabelChange : NSObject

@property (nonatomic, copy, nullable) NSAttributedString *attributedTitle;
@property (nonatomic) BOOL spinUp;
@property (nonatomic) BOOL animated;
@property (nonatomic) BOOL waitingLayout;

- (instancetype)initWithAttributedTitle:(nullable NSAttributedString *)title
                                 spinUp:(BOOL)spinUp
                               animated:(BOOL)animated
                          waitingLayout:(BOOL)waitingLayout;

@end

@interface BMASpinningLabel ()

@property (nonatomic) UILabel *disappearingLabel;
@property (nonatomic) UILabel *appearingLabel;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic, nullable) BMASpinningLabelChange *nextChange;
@property (nonatomic, readwrite, getter=isAnimating) BOOL animating;

@end

NS_ASSUME_NONNULL_END

@implementation BMASpinningLabelChange

- (instancetype)initWithAttributedTitle:(NSAttributedString *)title spinUp:(BOOL)spinUp animated:(BOOL)animated waitingLayout:(BOOL)waitingLayout {
    self = [super init];
    if (self) {
        _attributedTitle = [title copy];
        _spinUp = spinUp;
        _animated = animated;
        _waitingLayout = waitingLayout;
    }
    return self;
}

@end

@implementation BMASpinningLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    if (_titleLabel != nil) {
        return;
    }
    _titleLabel = [[UILabel alloc] init];
    _disappearingLabel = [[UILabel alloc] init];
    _appearingLabel = [[UILabel alloc] init];

    [self addSubview:_titleLabel];
    [self addSubview:_disappearingLabel];
    [self addSubview:_appearingLabel];

    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
}

#pragma mark - Overrides

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize contentSize = [self intrinsicContentSize];
    return CGSizeMake(MIN(size.width, contentSize.width), MIN(size.height, contentSize.height));
}

- (CGSize)intrinsicContentSize {
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = self.titleLabel.attributedText.size.width;
    if (self.nextChange) {
        width = MAX(width, self.nextChange.attributedTitle.size.width);
    }
    return CGSizeMake(width, height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSAttributedString *title = self.titleLabel.attributedText;
    CGFloat totalWidth = CGRectGetWidth(self.bounds);
    CGFloat totalHeight = CGRectGetHeight(self.bounds);
    CGSize titleSize = CGSizeMake(MIN(title.size.width, totalWidth), MIN(title.size.height, totalHeight));
    self.titleLabel.frame = CGRectMake((totalWidth - titleSize.width) / 2,
                                       (totalHeight - titleSize.height) / 2,
                                       titleSize.width,
                                       titleSize.height);

    if (self.nextChange && self.nextChange.waitingLayout) {
        [self applyNextChangeIfNeeded];
    }
}

#pragma mark - Public API

- (NSString *)title {
    return self.nextChange ? self.nextChange.attributedTitle.string : self.titleLabel.text;
}

- (void)setTitle:(NSString *)title {
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title];
    [self setAttributedTitle:attributedTitle];
}

- (NSAttributedString *)attributedTitle {
    return self.nextChange ? self.nextChange.attributedTitle : self.titleLabel.attributedText;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    [self setAttributedTitle:attributedTitle spinDirection:BMASpinDirectionDownward spinSettings:BMASpinSettingsNone];
}

- (void)setAttributedTitle:(NSAttributedString *)newTitle spinDirection:(BMASpinDirection)spinDirection spinSettings:(BMASpinSettings)spinSettings {
    BOOL spinUp = spinDirection == BMASpinDirectionUpward;
    BOOL animated = (spinSettings & BMASpinSettingsAnimated) > 0;
    BOOL waitForLayout = (spinSettings & BMASpinSettingsWaitForLayout) > 0;
    if (animated && waitForLayout) {
        self.nextChange = [[BMASpinningLabelChange alloc] initWithAttributedTitle:newTitle spinUp:spinUp animated:animated waitingLayout:YES];
        [self setNeedsLayout];
    } else {
        [self setAttributedTitle:newTitle spinUp:spinUp animated:animated];
    }
}

#pragma mark - Private

- (void)setAttributedTitle:(NSAttributedString *)newTitle spinUp:(BOOL)spinUp animated:(BOOL)animated {
    if ([self.titleLabel.attributedText isEqualToAttributedString:newTitle]) {
        self.nextChange = nil;
        return;
    }

    if (self.isAnimating) {
        self.nextChange = [[BMASpinningLabelChange alloc] initWithAttributedTitle:newTitle spinUp:spinUp animated:animated waitingLayout:NO];
        return;
    }

    NSAttributedString *oldTitle = self.titleLabel.attributedText;
    self.titleLabel.attributedText = newTitle;
    self.animating = YES;

    CGFloat spinDirection = spinUp ? 1 : -1;
    CGFloat totalWidth = CGRectGetWidth(self.bounds);
    CGFloat totalHeight = CGRectGetHeight(self.bounds);
    CGPoint boundsCenter = CGPointMake(totalWidth / 2, totalHeight / 2);

    CGSize oldTitleSize = CGSizeMake(MIN(oldTitle.size.width, totalWidth), MIN(oldTitle.size.height, totalHeight));
    CGSize newTitleSize = CGSizeMake(MIN(newTitle.size.width, totalWidth), MIN(newTitle.size.height, totalHeight));

    CGFloat appearOffset = ceil(spinDirection * 0.8f * newTitleSize.height);
    CATransform3D willAppearTransform = CATransform3DMakeTranslation(0, appearOffset, 0);
    CATransform3D didAppearTransform = CATransform3DIdentity;

    CGFloat disappearPerspective = -0.01f;
    CGFloat disappearRotation = spinDirection * (CGFloat)M_PI_4;
    CGFloat disappearOffset = ceil(-spinDirection * 1.5f * oldTitleSize.height);
    CATransform3D willDisappearTransform = CATransform3DIdentity;
    willDisappearTransform.m34 = disappearPerspective;
    CATransform3D didDisappearTransform = CATransform3DRotate(willDisappearTransform, disappearRotation, 1, 0, 0);
    didDisappearTransform = CATransform3DTranslate(didDisappearTransform, 0, disappearOffset, 0);

    self.titleLabel.hidden = YES;
    self.titleLabel.frame = CGRectMake((totalWidth - newTitleSize.width) / 2,
                                       (totalHeight - newTitleSize.height) / 2,
                                       newTitleSize.width,
                                       newTitleSize.height);

    self.disappearingLabel.hidden = NO;
    self.disappearingLabel.attributedText = oldTitle;
    self.disappearingLabel.layer.anchorPoint = CGPointMake(0.5f, spinUp ? 1.0f : 0.0f);
    self.disappearingLabel.bounds = CGRectMake(0, 0, oldTitleSize.width, oldTitleSize.height);
    self.disappearingLabel.center = CGPointMake(boundsCenter.x, boundsCenter.y + spinDirection * oldTitleSize.height / 2);
    self.disappearingLabel.layer.transform = willDisappearTransform;
    self.disappearingLabel.alpha = 1.0f;

    self.appearingLabel.hidden = NO;
    self.appearingLabel.attributedText = newTitle;
    self.appearingLabel.bounds = CGRectMake(0, 0, newTitleSize.width, newTitleSize.height);
    self.appearingLabel.center = boundsCenter;
    self.appearingLabel.layer.transform = willAppearTransform;
    self.appearingLabel.alpha = 0.0f;

    __weak typeof(self) wSelf = self;
    [self performWithAnimation:animated duration:[CATransaction animationDuration] animations:^{
        __strong typeof(self) sSelf = wSelf;
        sSelf.appearingLabel.alpha = 1.0f;
        sSelf.appearingLabel.layer.transform = didAppearTransform;
        sSelf.disappearingLabel.alpha = 0.0f;
        sSelf.disappearingLabel.layer.transform = didDisappearTransform;
    } completion:^(BOOL finished) {
        __strong typeof(self) sSelf = wSelf;
        sSelf.titleLabel.hidden = NO;
        sSelf.disappearingLabel.hidden = YES;
        sSelf.appearingLabel.hidden = YES;
        sSelf.animating = NO;
        [sSelf applyNextChangeIfNeeded];
    }];
}

- (void)applyNextChangeIfNeeded {
    if (self.nextChange) {
        BMASpinningLabelChange *nextChange = self.nextChange;
        self.nextChange = nil;
        [self setAttributedTitle:nextChange.attributedTitle spinUp:nextChange.spinUp animated:nextChange.animated];
    }
}

- (void)performWithAnimation:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

@end
