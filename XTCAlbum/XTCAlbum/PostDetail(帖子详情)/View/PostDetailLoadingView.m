//
//  PostDetailLoadingView.m
//  vs
//
//  Created by Xie Shu on 2018/3/20.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "PostDetailLoadingView.h"

@interface PostDetailLoadingView() {
    UIView *_headerView;
}

@end

@implementation PostDetailLoadingView
@synthesize loadingTableView = _loadingTableView;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createPostDetailLoadingView];
    }
    return self;
}

- (void)createPostDetailLoadingView {
    _loadingTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _loadingTableView.delegate = self;
    _loadingTableView.dataSource = self;
    _loadingTableView.estimatedRowHeight = 100.0f;
    _loadingTableView.rowHeight = UITableViewAutomaticDimension;
    _loadingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _loadingTableView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_loadingTableView];
    [_loadingTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    _loadingTableView.scrollEnabled = NO;
    _loadingTableView.allowsSelection = NO;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 130)];
    _headerView.backgroundColor = RGBCOLOR(240, 240, 240);
    _loadingTableView.tableHeaderView = _headerView;
    
    [_headerView.layer addAnimation:[self opacityForever_AnimationByOpacity:YES] forKey:@"MapAnimation"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"PostDetailLoadingCellName";
    PostDetailLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[PostDetailLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    
    if (indexPath.section%2) {
        [cell startAnimation:YES];
    } else {
         [cell startAnimation:NO];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.0f;
}

- (CABasicAnimation *)opacityForever_AnimationByOpacity:(BOOL)fromOpacity {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:fromOpacity ? 1.0f : 0.3];
    animation.toValue = [NSNumber numberWithFloat:fromOpacity ? 0.3f : 1.0];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = 0.65;
    animation.repeatCount = MAXFLOAT;
    //    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    return animation;
}

- (void)dealloc {
     [_headerView.layer removeAnimationForKey:@"MapAnimation"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
