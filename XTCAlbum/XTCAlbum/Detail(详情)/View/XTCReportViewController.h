//
//  XTCReportViewController.h
//  vs
//
//  Created by Xie Shu on 2018/4/12.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import "XTCBaseViewController.h"

typedef void (^ReportChatCallabck)(void);

@interface XTCReportViewController : XTCBaseViewController <UITextViewDelegate>

@property (nonatomic, strong) NSString *reportId;
@property (nonatomic, strong) NSString *disId;

@property (weak, nonatomic) IBOutlet UILabel *defaultLabel;
@property (weak, nonatomic) IBOutlet UITextView *reportTextView;
@property (nonatomic, assign) BOOL isChatReport; // 是否是聊天举报
@property (nonatomic, strong) NSString *cid;
@property (nonatomic, strong) ReportChatCallabck reportChatCallabck;

@end
