//
//  PostQRCodeViewController.h
//  vs
//
//  Created by Mac on 2018/12/17.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostCodeSelectCell.h"
#import "PostDetail.h"
#import "QRCodeManager.h"
#import "XTCPermissionManager.h"
#import "XTCShareHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostQRCodeViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) PostDetail *postDetailModel;
@property (nonatomic, assign) BOOL isPrinting; // 是否是印刷

@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *selectCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *postNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *userHeaderButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIView *qrCodeBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeCenterLayOutConstraint;

- (void)loadAboutData;

@end

NS_ASSUME_NONNULL_END
