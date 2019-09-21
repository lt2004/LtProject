//
//  XTCRecommendViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/2.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCRecommendViewController.h"

@interface XTCRecommendViewController () {
    
}

@property (strong, nonatomic) XTCInviteResponseModel *inviteResponseModel;
@property (strong, nonatomic) UIImage *shareImage;

@end

@implementation XTCRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = XTCLocalizedString(@"Setting_Invite_Friends", nil);
    _shareButton.layer.cornerRadius = 18;
    _shareButton.layer.masksToBounds = YES;
    
    __weak typeof(self) weakself = self;
    XTCRequestModel *requestModel = [[XTCRequestModel alloc] init];
    [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestInviteEnum byRequestDict:requestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
        if (errorModel.errorEnum == ResponseSuccessEnum) {
            weakself.inviteResponseModel = object;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.recommendImageView sd_setImageWithURL:[NSURL URLWithString:weakself.inviteResponseModel.qrcode] placeholderImage:nil options:SDWebImageRetryFailed];
                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:weakself.inviteResponseModel.qrcode] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (error == nil) {
                        weakself.shareImage = image;
                    } else {
                        
                    }
                }];
                /*
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:weakself.inviteResponseModel.qrcode] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if (error == nil) {
                        weakself.shareImage = image;
                    } else {
                        
                    }
                }];
                 */
            });
        } else {
            
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (IBAction)shareButtonClick:(id)sender {
    if (_shareImage == nil) {
        _shareImage = [UIImage imageNamed:@"invite_image"];
    }
    UIImage *bigImage = [_shareImage resizedImageToSize:CGSizeMake(300, 300)];
    NSString *url;
    if (_inviteResponseModel.link == nil || _inviteResponseModel.link.length == 0) {
        url = @"http://show.viewspeaker.com/download";
    } else {

    }
    [[XTCShareHelper sharedXTCShareHelper] shreDataByTitle:@"小棠菜相册" byDesc:@"" byThumbnailImage:bigImage byMedia:_inviteResponseModel.link byVC:self byiPadView:self.shareButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
