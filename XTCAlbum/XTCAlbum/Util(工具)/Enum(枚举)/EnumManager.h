//
//  EnumManager.h
//  ViewSpeaker
//
//  Created by Mac on 2019/3/21.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

// 首页tabbar
typedef NS_ENUM(NSInteger, SelectTabType) {
    SelectHotRecommendTabType = 101, // 首页
    SelectBusinessTabType, // 焦点
    SelectDiscoverTabType, // 探索
    SelectChatTabType, // 云聊
};

// 首页自媒体，服务号，官方号
typedef NS_ENUM(NSInteger, MainPageBusinessType) {
    MainPageSlefMediaBusinessType = 101,
    MainPageServiceBusinessType,
    MainPageOfficalBusinessType,
     MainPageOfficalAttentType,
};

// 系统语言
typedef NS_ENUM(NSInteger, SystemLanguageType) {
    SystemLanguageChinaType,
    SystemLanguageEnglishType,
    SystemLanguageJapanType,
};

// 商业认证上传类型
typedef NS_ENUM(NSInteger, BusinessUploadEnum) {
    BusinessLicenseUploadEnum, // 营业执照
    BusinessEnsureUploadEnum, // 认证公函
    BusinessCardFrontUploadEnum, // 身份证正面
    BusinessCardBackUploadEnum, // 身份证背面
    BusinessCardHandUploadEnum // 手持身份证
};

typedef NS_ENUM(NSInteger, AttentFanEnum) {
    AttentEnum, // 关注
    FanEnum, // 粉丝
};

// 商业认证资料填写
typedef NS_ENUM(NSInteger, BusinessWriterType) {
    BusinessWriterNameType = 101, // 企业全称
    BusinessWriterCreditCodeType = 102, // 信用代码
    BusinessWriterAccountBankNameType, // 开户银行
    BusinessWriterBankNumberType, // 对公银行账号
    BusinessWriterContactNameType, // 联系人名称
    BusinessWriterContactIDType, // 联系人身份证号码
    BusinessWriterContactTelphoneType, // 联系人电话号码
    BusinessWriterContactHomePhoneType, // 联系人座机号码
    BusinessWriterContactEmailType, // 联系人电子邮箱
    BusinessWriterContactWebType, // 官方一级域名
    BusinessWriterAddressType, // 官方一级域名
};

typedef NS_ENUM(NSInteger, BusinessAuthPayType) {
    BusinessAuthPayFreeType, // 尝鲜用户
    BusinessAuthPayServiceType, // 官方号服务号
    BusinessAuthPayVipType // VIP
};

typedef NS_ENUM(NSInteger, DetailReplayEnum) {
    PostDetailReplayEnum,
    PersonalDetailReplayEnum
};

typedef NS_ENUM(NSInteger, StreamEnum) {
    StreamMoreInteractiveEnum,
    StreamRelatedPostEnum,
};

typedef NS_ENUM(NSUInteger, PostAnnotationType) {
    PostAnnotationTypeVoice,
    PostAnnotationTypeTravle,
    PostAnnotationTypeFood,
    PostAnnotationTypeCity,
    PostAnnotationTypeCountry,
};

typedef NS_ENUM(NSInteger, DiscoverMapShowType) {
    DiscoverMapShowDiscoverType, // 探索
    DiscoverMapShowServiceType, // 服务
    DiscoverMapShowFootMarkType, // 足迹
    //    DiscoverMapShowStageType // 舞台
};

typedef NS_ENUM(NSInteger, UserShowType) {
    UserShowCountryType, // 展示国家
    UserShowCityType, // 展示省
    UserShowAllType, // 展示帖子
};

typedef NS_ENUM(NSInteger, AdvertType) {
    AdvertOtherType,
    AdvertMainPageType
};

typedef NS_ENUM(NSInteger, HotelDetailShowType) {
    HotelDetailShowPhotoType, // 图文
    HotelDetailShowServiceType, // 设施服务
    HotelDetailShowNoticeType, // 预定须知
};

typedef NS_ENUM(NSInteger, HotelSelectType) {
    HotelSelectChinaType = 101,
    HotelSelectOverseaType = 102
};

typedef NS_ENUM(NSInteger, HotelSelectTagType) {
    HotelSelectTagFacilityType, // 设施
    HotelSelectTagServiceType, // 服务
    HotelSelectTagRoomFacilityType, // 房型设施
    HotelSelectTagActiveFacilityType, // 活动设施
    HotelSelectTagRoomServiceType // 房型服务
};

typedef NS_ENUM(NSInteger, HotelRoomSelectType) {
    HotelRoomSelectBedType,
    HotelRoomSelectInternetType,
    HotelRoomSelectWindowType,
};

typedef NS_ENUM(NSInteger, HotelQueryType) {
    HotelQueryNoneType,
    HotelQueryRecommendType, // 推荐
    HotelQueryLocationType, // 位置
    HotelQueryPriceStarType, // 价格星级
    HotelQueryFiltrateType, // 筛选
};

typedef NS_ENUM(NSInteger, SearchType) {
    SearchNotType, // 不搜索
    SearchReplaceType, // 前面标签一样替换
    SearchAddType, // 增加的最后一个标签搜索
};

typedef NS_ENUM(NSInteger, PublishSourceFileTypeEnum) {
    PublishSourceFilePhotoTypeEnum,
    PublishSourceFileVideoTypeEnum,
};

typedef NS_ENUM(NSInteger, PublishTypeEnum) {
    PublishPhotoTypeEnum,
    PublishVRTypeEnum,
    PublishVideoTypeEnum,
    PublishProTypeEnum,
    PublishPhotoVideoTypeEnum,
};

typedef NS_ENUM(NSInteger, PublishNormalDraftType) {
    PublishNormalDraftSaveType,
    PublishNormalDraftEditType,
    PublishNormalDraftExitType
};

typedef NS_ENUM(NSInteger, NewPublishTagType) {
    NewPublishTagSelectType,
    NewPublishTagSystemType,
    NewPublishTagHistoryType
};

typedef NS_ENUM(NSInteger, PublishContentEnum) {
    PublishContentNormalEnum, // 普通发布
    PublishContentInteractiveEnum, // 互动发布
    PublishContentSpotEnum, // 地图扎点发布
    PublishRoadBookEnum, // 路书发布
};

typedef NS_ENUM(NSInteger, SelectLocaltionSatus) {
    SelectLocaltionLoadingSatus,
    SelectLocaltionSuccessSatus,
    SelectLocaltionFailedSatus
};

typedef NS_ENUM(NSInteger, AirTicketSelectType) {
    AirTicketSelectSingleType = 101,
    AirTicketSelectGoBackType = 102,
    AirTicketSelectMoreType = 103,
};

typedef NS_ENUM(NSInteger, MessageType) {
    MessageUpType,
    MessageCommentType,
    MessageAttentType
};

typedef NS_ENUM(NSUInteger, SendMessageType) {
    SendSystemMessageType,
    SendChatMessageType,
};

/**发布部分*/
typedef NS_ENUM(NSInteger, SelectPublishTypeEnum) {
    SelectPublishTypePhotoEnum, // 相片
    SelectPublishTypeVideoEnum, // 视频
    SelectPublishType720VREnum, // VR
    SelectPublishTypeTravelCameraEnum, // 旅行相机
    SelectPublishTypeProEnum, // Pro
    SelectPublishTypeDraftEnum, // 草稿
    SelectPublishTypeNotSureEnum,
};

typedef NS_ENUM(NSInteger, SelectSoureMethod) {
    SelectAllSoureMethod = 101, // 全部
    SelectAblumSoureMethod, // 相簿
    SelectMapSoureMethod, // 地图
};



@interface EnumManager : NSObject

@end
