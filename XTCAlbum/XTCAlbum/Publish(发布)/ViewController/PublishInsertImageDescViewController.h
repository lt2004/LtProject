//
//  PublishInsertImageDescViewController.h
//  vs
//
//  Created by Xie Shu on 2017/8/29.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "XTCBaseViewController.h"

typedef void (^ImageDescCallback)(NSString *imageDesc);

@interface PublishInsertImageDescViewController : XTCBaseViewController<UITextViewDelegate>

@property (nonatomic, strong) ImageDescCallback imageDescCallback;
@property (weak, nonatomic) IBOutlet UITextView *imageDescTextView;
@property (nonatomic, strong) NSString *imageDesc;
@property (weak, nonatomic) IBOutlet UILabel *haveInputLabel;

@end
