//
// Copyright (c) Badoo Trading Limited, 2010-present. All rights reserved.
//

#import "ViewController.h"
#import <BMASpinningLabel/BMASpinningLabel.h>

@interface ViewController ()

@property (nonatomic) NSArray<NSString *> *tableViewItems;
@property (nonatomic) BMASpinningLabel *titleLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 300;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableViewItems = @[
                            @"Section 1",
                            @"Section Two",
                            @"Third Section",
                            @"Long Section Name",
                            @"Very Very Long Section Name",
                            @"Section 6",
                            @"7th Section",
                            @"Last Section"
                            ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BMASpinningLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[BMASpinningLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    }
    return _titleLabel;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.tableViewItems[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateNavigationBarTitle];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    [self updateNavigationBarTitle];
}

#pragma mark -

- (void)updateNavigationBarTitle {
    NSArray<NSIndexPath *> *indexPathsForVisibleRows = [self.tableView indexPathsForVisibleRows];
    NSInteger indexOfFirstVisibleItem = [indexPathsForVisibleRows firstObject].row;
    for (NSIndexPath *indexPath in indexPathsForVisibleRows) {
        if (indexPath.row < indexOfFirstVisibleItem) {
            indexOfFirstVisibleItem = indexPath.row;
        }
    }
    NSString *title = indexOfFirstVisibleItem < self.tableViewItems.count ? self.tableViewItems[indexOfFirstVisibleItem] : nil;
    [self updateNavigationBarTitleWithText:title];
}

- (void)updateNavigationBarTitleWithText:(NSString *)title {
    if ([self.titleLabel.title isEqualToString:title]) {
        return;
    }
    NSString *oldTitle = self.titleLabel.title;
    NSInteger oldItemIndex = [self.tableViewItems indexOfObjectPassingTest:^BOOL(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj isEqualToString:oldTitle];
    }];
    NSInteger newItemIndex = [self.tableViewItems indexOfObjectPassingTest:^BOOL(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj isEqualToString:title];
    }];
    BMASpinDirection spinDirection = BMASpinDirectionUpward;
    BMASpinSettings spinSettings = (oldTitle.length > 0 ? BMASpinSettingsAnimated | BMASpinSettingsWaitForLayout : BMASpinSettingsNone);
    if (oldItemIndex != NSNotFound && newItemIndex != NSNotFound) {
        spinDirection = (oldItemIndex < newItemIndex ? BMASpinDirectionUpward : BMASpinDirectionDownward);
    } else if (newItemIndex != NSNotFound || oldItemIndex != NSNotFound) {
        spinDirection = (newItemIndex != NSNotFound ? BMASpinDirectionUpward : BMASpinDirectionDownward);
    } else {
        spinSettings = BMASpinSettingsNone;
    }
    NSAttributedString *attributedTitle = [[self class] attributedNavigationBarTitleForText:title];
    [self.titleLabel setAttributedTitle:attributedTitle spinDirection:spinDirection spinSettings:spinSettings];
    self.navigationItem.titleView = nil;  // force re-layout
    self.navigationItem.titleView = self.titleLabel;
}

+ (NSAttributedString *)attributedNavigationBarTitleForText:(NSString *)text {
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:16] };
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    return attributedText;
}

@end
