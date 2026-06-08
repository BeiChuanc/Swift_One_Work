import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Vestir: NSObject, Codable {
    
    /// 用户ID
    var userId_Vestir: Int?
    
    /// 用户名字
    var userName_Vestir: String?
    
    /// 用户简介
    var userIntroduce_Vestir: String?
    
    /// 用户头像
    var userHead_Vestir: String?
    
    /// 用户媒体
    var userMedia_Vestir: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Vestir: [TitleModel_Vestir] = []

    /// 用户关注数
    var userFollow_Vestir: Int?

    /// 用户粉丝数
    var userFans_Vestir: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Vestir: Int? = nil,
         userName_Vestir: String? = nil,
         userIntroduce_Vestir: String? = nil,
         userHead_Vestir: String? = nil,
         userMedia_Vestir: [String]? = nil,
         userLike_Vestir: [TitleModel_Vestir] = [],
         userFollow_Vestir: Int? = nil,
         userFans_Vestir: Int? = nil) {
        self.userId_Vestir = userId_Vestir
        self.userName_Vestir = userName_Vestir
        self.userIntroduce_Vestir = userIntroduce_Vestir
        self.userHead_Vestir = userHead_Vestir
        self.userMedia_Vestir = userMedia_Vestir
        self.userLike_Vestir = userLike_Vestir
        self.userFollow_Vestir = userFollow_Vestir
        self.userFans_Vestir = userFans_Vestir
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Vestir: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Vestir: Int
    
    /// 拥有者ID
    var titleUserId_Vestir: Int
    
    /// 拥有者昵称
    var titleUserName_Vestir: String
    
    /// 帖子媒体
    var titleMeidas_Vestir: [String]
    
    /// 帖子标题
    var title_Vestir: String
    
    /// 帖子内容
    var titleContent_Vestir: String
    
    /// 帖子评论列表
    var reviews_Vestir: [Comment_Vestir]
    
    /// 喜欢个数
    var likes_Vestir: Int
    
    init(titleId_Vestir: Int,
         titleUserId_Vestir: Int,
         titleUserName_Vestir: String,
         titleMeidas_Vestir: [String],
         title_Vestir: String,
         titleContent_Vestir: String,
         reviews_Vestir: [Comment_Vestir],
         likes_Vestir: Int) {
        self.titleId_Vestir = titleId_Vestir
        self.titleUserId_Vestir = titleUserId_Vestir
        self.titleUserName_Vestir = titleUserName_Vestir
        self.titleMeidas_Vestir = titleMeidas_Vestir
        self.title_Vestir = title_Vestir
        self.titleContent_Vestir = titleContent_Vestir
        self.reviews_Vestir = reviews_Vestir
        self.likes_Vestir = likes_Vestir
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Vestir: NSObject, Codable {
    
    /// 用户ID
    var userId_Vestir: Int?
    
    /// 用户密码
    var userPwd_Vestir: String?
    
    /// 用户名称
    var userName_Vestir: String?
    
    /// 用户头像
    var userHead_Vestir: String?
    
    /// 用户发布帖子列表
    var userPosts_Vestir: [TitleModel_Vestir]
    
    /// 用户喜欢帖子列表
    var userLike_Vestir: [TitleModel_Vestir]

    /// 用户关注列表
    var userFollow_Vestir: [PrewUserModel_Vestir]

    /// 用户个人简介
    var userIntroduce_Vestir: String?
    
    /// 初始化
    init(userId_Vestir: Int? = nil,
         userPwd_Vestir: String? = nil,
         userName_Vestir: String? = nil,
         userHead_Vestir: String? = nil,
         userPosts_Vestir: [TitleModel_Vestir],
         userLike_Vestir: [TitleModel_Vestir],
         userFollow_Vestir: [PrewUserModel_Vestir],
         userIntroduce_Vestir: String? = nil) {
        self.userId_Vestir = userId_Vestir
        self.userPwd_Vestir = userPwd_Vestir
        self.userName_Vestir = userName_Vestir
        self.userHead_Vestir = userHead_Vestir
        self.userPosts_Vestir = userPosts_Vestir
        self.userLike_Vestir = userLike_Vestir
        self.userFollow_Vestir = userFollow_Vestir
        self.userIntroduce_Vestir = userIntroduce_Vestir
    }
}

/// 消息数据模型
class MessageModel_Vestir: Codable {
    
    /// 消息ID
    var messageId_Vestir: Int?
    
    /// 消息内容
    var content_Vestir: String?
    
    /// 用户头像
    var userHead_Vestir: String?
    
    /// 是否是我发送的
    var isMine_Vestir: Bool?
    
    /// 消息时间
    var time_Vestir: String?
    
    /// 初始化
    init(messageId_vestir: Int? = nil,
         content_vestir: String? = nil,
         userHead_vestir: String? = nil,
         isMine_vestir: Bool? = nil,
         time_vestir: String? = nil) {
        self.messageId_Vestir = messageId_vestir
        self.content_Vestir = content_vestir
        self.userHead_Vestir = userHead_vestir
        self.isMine_Vestir = isMine_vestir
        self.time_Vestir = time_vestir
    }
}

/// 评论模型
class Comment_Vestir: NSObject, Codable {
    
    /// 评论ID
    var commentId_Vestir: Int
    
    /// 评论用户uid
    var commentUserId_Vestir: Int
    
    /// 评论用户昵称
    var commentUserName_Vestir: String
    
    /// 评论内容
    var commentContent_Vestir: String
    
    /// 初始化
    init(commentId_Vestir: Int,
         commentUserId_Vestir: Int,
         commentUserName_Vestir: String,
         commentContent_Vestir: String) {
        self.commentId_Vestir = commentId_Vestir
        self.commentUserId_Vestir = commentUserId_Vestir
        self.commentUserName_Vestir = commentUserName_Vestir
        self.commentContent_Vestir = commentContent_Vestir
    }
}

/// 商店模型
class StoreModel_Vestir: NSObject {
    
    /// ID编号
    var id_Vestir: Int?
    
    /// 商品ID
    var goodsId_Vestir: String?
    
    /// 商品名字
    var goodsName_Vestir: String?
    
    /// 商品价格
    var goodsPrice_Vestir: String?
    
    /// 是否顶部商品
    var goodIsTop_Vestir: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Vestir: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Vestir: Bool?
    
    init(id_Vestir: Int? = nil,
         goodsId_Vestir: String? = nil,
         goodsName_Vestir: String? = nil,
         goodsPrice_Vestir: String? = nil,
         goodIsTop_Vestir: Bool? = false,
         goodIsLimit_Vestir: Bool? = false,
         goodIsVIP_Vestir: Bool? = false) {
        self.id_Vestir = id_Vestir
        self.goodsId_Vestir = goodsId_Vestir
        self.goodsName_Vestir = goodsName_Vestir
        self.goodsPrice_Vestir = goodsPrice_Vestir
        self.goodIsTop_Vestir = goodIsTop_Vestir
        self.goodIsSpecial_Vestir = goodIsLimit_Vestir
        self.goodIsVIP_Vestir = goodIsVIP_Vestir
        super.init()
    }
}

// MARK: - 每日 OOTD 打卡模型

/// 每日穿搭打卡记录
/// 功能：记录用户每天的打卡照片及穿搭标签，支持持久化（Codable）
class DailyCheckIn_Vestir: NSObject, Codable {

    /// 打卡日期（格式 "yyyy-MM-dd"）
    var date_Vestir: String
    /// 穿搭图片本地路径
    var mediaPath_Vestir: String?
    /// 品牌标注
    var brand_Vestir: String?
    /// 色系（classic / warm / cool / mono / earth）
    var colorTheme_Vestir: String?
    /// 版型风格（casual / formal / street / minimal / vintage）
    var outfitStyle_Vestir: String?
    /// 穿搭场景（commuting / casual / date / sports）
    var occasion_Vestir: String?
    /// 气温适配描述
    var temperature_Vestir: String?

    init(date_Vestir: String,
         mediaPath_Vestir: String? = nil,
         brand_Vestir: String? = nil,
         colorTheme_Vestir: String? = nil,
         outfitStyle_Vestir: String? = nil,
         occasion_Vestir: String? = nil,
         temperature_Vestir: String? = nil) {
        self.date_Vestir = date_Vestir
        self.mediaPath_Vestir = mediaPath_Vestir
        self.brand_Vestir = brand_Vestir
        self.colorTheme_Vestir = colorTheme_Vestir
        self.outfitStyle_Vestir = outfitStyle_Vestir
        self.occasion_Vestir = occasion_Vestir
        self.temperature_Vestir = temperature_Vestir
    }
}

// MARK: - 穿搭挑战模型

/// 官方发起的穿搭主题挑战活动
/// 功能：包含挑战说明、参与人数、截止天数和讨论区评论列表
class OutfitChallenge_Vestir: NSObject {

    /// 挑战唯一 ID
    var challengeId_Vestir: Int
    /// 挑战标题
    var title_Vestir: String
    /// 挑战描述说明
    var desc_Vestir: String
    /// 主题标签文字（展示用，如 "Monochrome"）
    var theme_Vestir: String
    /// 封面 SF Symbol 图标名
    var badgeIcon_Vestir: String
    /// 参与人数
    var participantCount_Vestir: Int
    /// 距结束剩余天数
    var daysRemaining_Vestir: Int
    /// 是否热门
    var isHot_Vestir: Bool
    /// 讨论区评论列表
    var discussions_Vestir: [Comment_Vestir]

    init(challengeId_Vestir: Int,
         title_Vestir: String,
         desc_Vestir: String,
         theme_Vestir: String,
         badgeIcon_Vestir: String,
         participantCount_Vestir: Int,
         daysRemaining_Vestir: Int,
         isHot_Vestir: Bool = false,
         discussions_Vestir: [Comment_Vestir] = []) {
        self.challengeId_Vestir = challengeId_Vestir
        self.title_Vestir = title_Vestir
        self.desc_Vestir = desc_Vestir
        self.theme_Vestir = theme_Vestir
        self.badgeIcon_Vestir = badgeIcon_Vestir
        self.participantCount_Vestir = participantCount_Vestir
        self.daysRemaining_Vestir = daysRemaining_Vestir
        self.isHot_Vestir = isHot_Vestir
        self.discussions_Vestir = discussions_Vestir
    }
}
