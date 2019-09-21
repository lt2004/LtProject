//
//  XTCAblumPublishStreamViewController.h
//  vs
//
//  Created by Xie Shu on 2018/6/26.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "XTCBaseViewController.h"
#import "NBZStreamingScrollLayout.h"
#import "XTCPublishSelectSourceCell.h"
#import "PublishPickerShowViewController.h"
#import "XTCPublishPickerViewController.h"

typedef void (^AblumSelectImageCallabck)(NSMutableArray *ablumArray);

@interface XTCAblumPublishStreamViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, NBZStreamingCollectionViewDelegateLayout>

@property (nonatomic, strong) TZAlbumModel *albumModel;
@property (nonatomic, strong) NSMutableArray *selectModelArray;
@property (nonatomic, assign) NSInteger maxImagesCount;
@property (nonatomic, assign) SelectPublishTypeEnum slectPublishTypeEnum;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, strong) AblumSelectImageCallabck ablumSelectImageCallabck;
@property (weak, nonatomic) IBOutlet UIView *naviBgView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *albumStreamCollectionView;

@end
