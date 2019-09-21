//
//  
//    ___  _____   ______  __ _   _________ 
//   / _ \/ __/ | / / __ \/ /| | / / __/ _ \
//  / , _/ _/ | |/ / /_/ / /_| |/ / _// , _/
// /_/|_/___/ |___/\____/____/___/___/_/|_| 
//
//  Created by Bart Claessens. bart (at) revolver . be
//

#import "REVClusterAnnotationView.h"


@implementation REVClusterAnnotationView

@synthesize coordinate;

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if ( self )
    {
        _showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _showImageView.layer.cornerRadius = 5;
        _showImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _showImageView.layer.borderWidth = 2;
        _showImageView.layer.masksToBounds = YES;
        _showImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_showImageView];
        
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.layer.cornerRadius = 13;
        _countLabel.layer.masksToBounds = YES;
        _countLabel.backgroundColor = HEX_RGB(0x38880D);
        _countLabel.adjustsFontSizeToFitWidth = YES;
        [_countLabel sizeToFit];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_countLabel];
        [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.showImageView.mas_right);
            make.centerY.equalTo(self.showImageView.mas_top);
            make.size.mas_equalTo(CGSizeMake(26, 26));
        }];
    }
    return self;
}

- (void)setSourceAsset:(PHAsset *)sourceAsset {
    self.showImageView.image = nil;
    [[TZImageManager manager] getPhotoWithAsset:sourceAsset photoWidth:100 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (isDegraded) {
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.showImageView.image = photo;
            });
        }
    }];
    
}


- (void)dealloc {
    
}

@end
