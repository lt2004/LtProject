//
//  UserHomePageSearchViewController.m
//  vs
//
//  Created by Xie Shu on 2017/10/30.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "UserHomePageSearchViewController.h"
#import "HomeSearchHeaderView.h"
#import "HomePageSearchServiceCell.h"

@interface UserHomePageSearchViewController () {
    HomeSearchHeaderView *_homeSearchHeaderView;
    BOOL _isSearchFlag; // 是否处于搜索状态
    HomePageSearchResponseModel *_homePageSearchResponseModel;
    DoSearchRequestModel *_requestModel;
}

@end

@implementation UserHomePageSearchViewController
@synthesize searchTableView = _searchTableView;
@synthesize userId = _userId;
@synthesize delegate = _delegate;
@synthesize userTagsResponseModel = _userTagsResponseModel;

- (void)awakeFromNib {
    [super awakeFromNib];
    _isOwnSearch = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        _searchTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if (kDevice_Is_iPhoneX) {
        _topLayoutConstraint.constant = 20.0f;
    } else {
        _topLayoutConstraint.constant = 0.0f;
    }
    _searchTableView.rowHeight = UITableViewAutomaticDimension;
    _searchTableView.estimatedRowHeight = 50.0f;
    _searchTableView.backgroundColor = [UIColor whiteColor];
    _searchTableView.separatorColor = kTableviewCellColor;
    _searchTableView.showsVerticalScrollIndicator = NO;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 70)];
    _searchTableView.tableHeaderView = headerView;
    
    [_searchTableView registerNib:[UINib nibWithNibName:@"SearchTagsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SearchTagsTableViewCell"];
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeSearchHeaderView" owner:self options:nil];
    _homeSearchHeaderView = [nib objectAtIndex:0];
    [_homeSearchHeaderView.cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _homeSearchHeaderView.cityTextField.returnKeyType = UIReturnKeyDone;
    [_homeSearchHeaderView.cityTextField addTarget:self action:@selector(textFieldDidChang:) forControlEvents:(UIControlEventEditingChanged)];
    _homeSearchHeaderView.cityTextField.delegate = self;
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"user_search_tag_delete"] forState:UIControlStateNormal];
    cancelButton.frame = CGRectMake(0, 0, 30, 30);
    _homeSearchHeaderView.cityTextField.rightView = cancelButton;
    [cancelButton addTarget:self action:@selector(searchCancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _homeSearchHeaderView.cityTextField.rightViewMode = UITextFieldViewModeAlways;
    [headerView addSubview:_homeSearchHeaderView];
    [_homeSearchHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(headerView);
        make.top.equalTo(headerView).with.offset(20);
    }];
    _homeSearchHeaderView.leftLayoutConstraint.constant = -1;
    _homeSearchHeaderView.cityButton.hidden = YES;
    _homeSearchHeaderView.selelctFlagImageView.hidden = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isSearchFlag) {
        return 1;
    } else {
        if (_userTagsResponseModel) {
            if (_userTagsResponseModel.hide_tags.count) {
                return 2;
            } else {
                return 1;
            }
            
        } else {
            return 0;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearchFlag) {
        return _homePageSearchResponseModel.postArray.count;
    } else {
        if (_userTagsResponseModel) {
            return 1;
        } else {
            return 0;
        }
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearchFlag) {
        static NSString *cellName = @"HomePageSearchServiceCellName";
        HomePageSearchServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[HomePageSearchServiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        SearchIdentResponseModel *responseModel = _homePageSearchResponseModel.postArray[indexPath.row];
        
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:responseModel.prc_url] placeholderImage:nil];
        cell.nameLabel.text = responseModel.name;
        cell.descLabel.text = responseModel.desc;
        return cell;
    } else {
        static NSString *cellName = @"UserSearchTagsCellName";
        UserSearchTagsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[UserSearchTagsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        if (indexPath.section == 0) {
            cell.isEdit = _isEditTag;
            cell.isMayAddTag = NO;
        } else {
            cell.isEdit = NO;
            cell.isMayAddTag = YES;
        }
        
        if (indexPath.section == 0) {
            [cell insertDataToCell:_userTagsResponseModel.show_tags];
        } else {
            [cell insertDataToCell:_userTagsResponseModel.hide_tags];
        }
        __weak typeof(self) weakSelf = self;
        
        cell.deleteUserTagCallabck = ^(NSString *tagString) {
            if (weakSelf.isEditTag) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF != %@", tagString];
                NSArray *filterArray = [weakSelf.userTagsResponseModel.show_tags filteredArrayUsingPredicate:predicate];
                weakSelf.userTagsResponseModel.show_tags = [[NSMutableArray alloc] initWithArray:filterArray];
                [weakSelf.userTagsResponseModel.hide_tags addObject:tagString];
                [weakSelf.searchTableView reloadData];
            } else {
                [weakSelf.delegate userHomeSearchByKeyWord:tagString];
                [weakSelf cancelButtonClick];
            }
            
        };
        
        cell.addUserTagCallabck = ^(NSString *tagString) {
            [weakSelf.userTagsResponseModel.hide_tags removeObject:tagString];
            [weakSelf.userTagsResponseModel.show_tags addObject:tagString];
            [weakSelf.searchTableView reloadData];
        };
        
        return cell;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    if (_isSearchFlag) {
        NSString *titleString = @"相关内容";
        UIView *headerFlagView = [[UIView alloc] init];
        headerFlagView.backgroundColor = HEX_RGB(0xEDF1F4);
        [headerView addSubview:headerFlagView];
        [headerFlagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView);
            make.left.right.equalTo(headerView);
            make.height.mas_equalTo(5);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = titleString;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = RGBCOLOR(74, 74, 74);
        [headerView addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerView).with.offset(15);
            make.centerY.equalTo(headerView).with.offset(5);
            make.height.mas_equalTo(30);
        }];
        
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setTitle:@"更多" forState:UIControlStateNormal];
        [moreButton setTitleColor:titleLabel.textColor forState:UIControlStateNormal];
        [headerView addSubview:moreButton];
        [moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
        moreButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(headerView).with.offset(-15);
            make.bottom.equalTo(titleLabel);
            make.size.mas_equalTo(CGSizeMake(50, 30));
        }];
    } else {
        UIView *headerFlagView = [[UIView alloc] init];
        headerFlagView.backgroundColor = RGBCOLOR(231, 231, 231);
        [headerView addSubview:headerFlagView];
        [headerFlagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView);
            make.left.right.equalTo(headerView);
            make.height.mas_equalTo(0.5);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        if (section == 0) {
            titleLabel.text = @"标签";
        } else {
            titleLabel.text = @"点击添加更多栏目";
        }
        
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = RGBCOLOR(74, 74, 74);
        [headerView addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerView).with.offset(15);
            make.centerY.equalTo(headerView);
            make.height.mas_equalTo(35);
        }];
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        /*
        if (section == 0) {
            moreButton.hidden = NO;
        } else {
            moreButton.hidden = YES;
        }
         */
        moreButton.hidden = YES;
        if (_isEditTag) {
            [moreButton setTitle:@"完成" forState:UIControlStateNormal];
        } else {
            [moreButton setTitle:@"整理" forState:UIControlStateNormal];
        }
        
        [moreButton setTitleColor:titleLabel.textColor forState:UIControlStateNormal];
        moreButton.layer.borderWidth = 0.5;
        moreButton.layer.borderColor = HEX_RGB(0x8FDA3C).CGColor;
        [moreButton addTarget:self action:@selector(orderByDeleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:moreButton];
        moreButton.layer.cornerRadius = 15;
        moreButton.layer.masksToBounds = YES;
        moreButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(headerView).with.offset(-15);
            make.centerY.equalTo(titleLabel);
            make.size.mas_equalTo(CGSizeMake(60, 30));
        }];
        
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //    if (_isSearchFlag) {
    //        return 0.01f;
    //    } else {
    return 40.0f;
    //    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearchFlag) {
        return 60.0f;
    } else {
        if (indexPath.section == 0) {
            NSInteger flag = _userTagsResponseModel.show_tags.count%4 ? _userTagsResponseModel.show_tags.count/4+1 : _userTagsResponseModel.show_tags.count/4;
            return flag*40 + 11;
        } else {
            NSInteger flag = _userTagsResponseModel.hide_tags.count%4 ? _userTagsResponseModel.hide_tags.count/4+1 : _userTagsResponseModel.hide_tags.count/4;
            return flag*40 + 11;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isSearchFlag) {
        SearchIdentResponseModel *postModel = _homePageSearchResponseModel.postArray[indexPath.row];
        if ([postModel.post_type isEqualToString:@"photo"] || [postModel.post_type isEqualToString:@"multimedia"]) {
            PostDetailPhotoViewController *postDetailPhotoVC = [[UIStoryboard storyboardWithName:@"PostDetailPhoto" bundle:nil] instantiateViewControllerWithIdentifier:@"PostDetailPhotoViewController"];
            postDetailPhotoVC.hidesBottomBarWhenPushed = true;
            postDetailPhotoVC.postDetailId = postModel.post_id;
            
            XTCBaseNavigationController *nav = [[XTCBaseNavigationController alloc] initWithRootViewController:postDetailPhotoVC];
            [self presentViewController:nav animated:YES completion:^{
                
            }];
            //            [self.navigationController pushViewController:postDetailPhotoVC animated:YES];
        } else if ([postModel.post_type isEqualToString:@"video"]) {
            PostDetailPhotoViewController *postDetailVideoVC = [[UIStoryboard storyboardWithName:@"PostDetailPhoto" bundle:nil] instantiateViewControllerWithIdentifier:@"PostDetailPhotoViewController"];
            postDetailVideoVC.hidesBottomBarWhenPushed = true;
            postDetailVideoVC.postDetailId = postModel.post_id;
            //            [self.navigationController pushViewController:postDetailVideoVC animated:YES];
            XTCBaseNavigationController *nav = [[XTCBaseNavigationController alloc] initWithRootViewController:postDetailVideoVC];
            [self presentViewController:nav animated:YES completion:^{
                
            }];
        } else if ([postModel.post_type isEqualToString:@"mix"]) {
            
            ProDetailShowViewController *postDetailVideoVC = [[UIStoryboard storyboardWithName:@"ProDetailShow" bundle:nil] instantiateViewControllerWithIdentifier:@"ProDetailShowViewController"];
            postDetailVideoVC.hidesBottomBarWhenPushed = true;
            postDetailVideoVC.postId = postModel.post_id;
            XTCBaseNavigationController *nav = [[XTCBaseNavigationController alloc] initWithRootViewController:postDetailVideoVC];
            [self presentViewController:nav animated:YES completion:^{
                
            }];
        } else {
            // VR
            VRDetailViewController *postDetailVideoVC = [[UIStoryboard storyboardWithName:@"detail" bundle:nil] instantiateViewControllerWithIdentifier:@"VRDetailViewController"];
            postDetailVideoVC.hidesBottomBarWhenPushed = true;
            postDetailVideoVC.postId = postModel.post_id;
            //            [self.navigationController pushViewController:postDetailVideoVC animated:YES];
            XTCBaseNavigationController *nav = [[XTCBaseNavigationController alloc] initWithRootViewController:postDetailVideoVC];
            [self presentViewController:nav animated:YES completion:^{
                
            }];
        }
    } else {
        
    }
}

- (void)textFieldDidChang:(UITextField *)textField {
    if (textField.text.length) {
        _isSearchFlag = YES;
    } else {
        
    }
    if (_isSearchFlag) {
        if (textField.markedTextRange == nil) {
            _requestModel = [[DoSearchRequestModel alloc] init];
            _requestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
            _requestModel.token = [GlobalData sharedInstance].userModel.token;
            _requestModel.key = textField.text;
            [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequesDoSearchEnum byRequestDict:_requestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
                if (errorModel.errorEnum == ResponseSuccessEnum) {
                    self->_homePageSearchResponseModel = object;
                    [self->_searchTableView reloadData];
                } else {
                    
                }
            }];
        } else {
            
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.text && textField.text.length) {
        
    } else {
        [self searchCancelButtonClick];
    }
    return YES;
}

- (void)searchCancelButtonClick {
    _isSearchFlag = NO;
    _homeSearchHeaderView.cityTextField.text = @"";
    [_homeSearchHeaderView.cityTextField resignFirstResponder];
    [_searchTableView reloadData];
}

#pragma mark - 取消按钮被点击
- (void)cancelButtonClick {
    CATransition *animation = CATransition.animation;
    animation.duration = 0.7;
    animation.type = kCATransitionFade;
    animation.subtype = kCAAlignmentRight;
    [self.view.window.layer addAnimation:animation forKey:Nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)orderByDeleteButtonClick:(UIButton *)button {
    _isEditTag = !_isEditTag;
    [_searchTableView reloadData];
}

- (void)moreButtonClick {
    if (_homeSearchHeaderView.cityTextField.text && _homeSearchHeaderView.cityTextField.text.length) {
        [_delegate userHomeSearchPostByKeyWord:_homeSearchHeaderView.cityTextField.text];
    } else {
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    DDLogInfo(@"个人搜索页页面释放");
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
