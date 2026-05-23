import Foundation
import UIKit

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Hush: NSObject, Codable {
    
    /// 用户ID
    var userId_Hush: Int?
    
    /// 用户名字
    var userName_Hush: String?
    
    /// 用户简介
    var userIntroduce_Hush: String?
    
    /// 用户头像
    var userHead_Hush: String?
    
    /// 用户媒体
    var userMedia_Hush: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Hush: [TitleModel_Hush] = []

    /// 用户关注数
    var userFollow_Hush: Int?

    /// 用户粉丝数
    var userFans_Hush: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Hush: Int? = nil,
         userName_Hush: String? = nil,
         userIntroduce_Hush: String? = nil,
         userHead_Hush: String? = nil,
         userMedia_Hush: [String]? = nil,
         userLike_Hush: [TitleModel_Hush] = [],
         userFollow_Hush: Int? = nil,
         userFans_Hush: Int? = nil) {
        self.userId_Hush = userId_Hush
        self.userName_Hush = userName_Hush
        self.userIntroduce_Hush = userIntroduce_Hush
        self.userHead_Hush = userHead_Hush
        self.userMedia_Hush = userMedia_Hush
        self.userLike_Hush = userLike_Hush
        self.userFollow_Hush = userFollow_Hush
        self.userFans_Hush = userFans_Hush
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Hush: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Hush: Int
    
    /// 拥有者ID
    var titleUserId_Hush: Int
    
    /// 拥有者昵称
    var titleUserName_Hush: String
    
    /// 帖子媒体
    var titleMeidas_Hush: [String]
    
    /// 帖子标题
    var title_Hush: String
    
    /// 帖子内容
    var titleContent_Hush: String
    
    /// 帖子评论列表
    var reviews_Hush: [Comment_Hush]
    
    /// 喜欢个数
    var likes_Hush: Int
    
    init(titleId_Hush: Int,
         titleUserId_Hush: Int,
         titleUserName_Hush: String,
         titleMeidas_Hush: [String],
         title_Hush: String,
         titleContent_Hush: String,
         reviews_Hush: [Comment_Hush],
         likes_Hush: Int) {
        self.titleId_Hush = titleId_Hush
        self.titleUserId_Hush = titleUserId_Hush
        self.titleUserName_Hush = titleUserName_Hush
        self.titleMeidas_Hush = titleMeidas_Hush
        self.title_Hush = title_Hush
        self.titleContent_Hush = titleContent_Hush
        self.reviews_Hush = reviews_Hush
        self.likes_Hush = likes_Hush
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Hush: NSObject, Codable {
    
    /// 用户ID
    var userId_Hush: Int?
    
    /// 用户密码
    var userPwd_Hush: String?
    
    /// 用户名称
    var userName_Hush: String?
    
    /// 用户头像
    var userHead_Hush: String?
    
    /// 用户发布帖子列表
    var userPosts_Hush: [TitleModel_Hush]
    
    /// 用户喜欢帖子列表
    var userLike_Hush: [TitleModel_Hush]

    /// 用户关注列表
    var userFollow_Hush: [PrewUserModel_Hush]
    
    /// 初始化
    init(userId_Hush: Int? = nil,
         userPwd_Hush: String? = nil,
         userName_Hush: String? = nil,
         userHead_Hush: String? = nil,
         userPosts_Hush: [TitleModel_Hush],
         userLike_Hush: [TitleModel_Hush],
         userFollow_Hush: [PrewUserModel_Hush]) {
        self.userId_Hush = userId_Hush
        self.userPwd_Hush = userPwd_Hush
        self.userName_Hush = userName_Hush
        self.userHead_Hush = userHead_Hush
        self.userPosts_Hush = userPosts_Hush
        self.userLike_Hush = userLike_Hush
        self.userFollow_Hush = userFollow_Hush
    }
}

/// 消息数据模型
class MessageModel_Hush: Codable {
    
    /// 消息ID
    var messageId_Hush: Int?
    
    /// 消息内容
    var content_Hush: String?
    
    /// 用户头像
    var userHead_Hush: String?
    
    /// 是否是我发送的
    var isMine_Hush: Bool?
    
    /// 消息时间
    var time_Hush: String?
    
    /// 初始化
    init(messageId_hush: Int? = nil,
         content_hush: String? = nil,
         userHead_hush: String? = nil,
         isMine_hush: Bool? = nil,
         time_hush: String? = nil) {
        self.messageId_Hush = messageId_hush
        self.content_Hush = content_hush
        self.userHead_Hush = userHead_hush
        self.isMine_Hush = isMine_hush
        self.time_Hush = time_hush
    }
}

/// 评论模型
class Comment_Hush: NSObject, Codable {
    
    /// 评论ID
    var commentId_Hush: Int
    
    /// 评论用户uid
    var commentUserId_Hush: Int
    
    /// 评论用户昵称
    var commentUserName_Hush: String
    
    /// 评论内容
    var commentContent_Hush: String
    
    /// 初始化
    init(commentId_Hush: Int,
         commentUserId_Hush: Int,
         commentUserName_Hush: String,
         commentContent_Hush: String) {
        self.commentId_Hush = commentId_Hush
        self.commentUserId_Hush = commentUserId_Hush
        self.commentUserName_Hush = commentUserName_Hush
        self.commentContent_Hush = commentContent_Hush
    }
}

// MARK: - 时间胶囊模型

/// 时间胶囊模型
/// 功能：记录用户埋下的照片+文字胶囊，包含创建时间和解锁时间
/// 设计：保存在内存中，isUnlocked/daysRemaining 为计算属性
class TimeCapsuleModel_Hush: NSObject {

    /// 胶囊唯一 ID
    var capsuleId_Hush: Int

    /// 胶囊标题
    var capsuleTitle_Hush: String

    /// 胶囊文字内容
    var capsuleContent_Hush: String

    /// 胶囊封面图片（内存中保存，非持久化）
    var capsuleImage_Hush: UIImage?

    /// 创建时间
    var createDate_Hush: Date

    /// 指定解锁时间（最短7天，最长10年）
    var openDate_Hush: Date

    /// 是否已解锁
    var isUnlocked_Hush: Bool {
        return Date() >= openDate_Hush
    }

    /// 距解锁剩余天数（已解锁时为0）
    var daysRemaining_Hush: Int {
        guard !isUnlocked_Hush else { return 0 }
        let components_hush = Calendar.current.dateComponents([.day], from: Date(), to: openDate_Hush)
        return max(0, components_hush.day ?? 0)
    }

    /// 初始化
    /// - Parameters:
    ///   - capsuleId_hush: 唯一ID
    ///   - capsuleTitle_hush: 标题
    ///   - capsuleContent_hush: 文字内容
    ///   - capsuleImage_hush: 封面图片
    ///   - createDate_hush: 创建时间
    ///   - openDate_hush: 开启时间
    init(capsuleId_hush: Int,
         capsuleTitle_hush: String,
         capsuleContent_hush: String,
         capsuleImage_hush: UIImage? = nil,
         createDate_hush: Date,
         openDate_hush: Date) {
        self.capsuleId_Hush = capsuleId_hush
        self.capsuleTitle_Hush = capsuleTitle_hush
        self.capsuleContent_Hush = capsuleContent_hush
        self.capsuleImage_Hush = capsuleImage_hush
        self.createDate_Hush = createDate_hush
        self.openDate_Hush = openDate_hush
    }
}

// MARK: - 今日灵感卡模型

/// 今日灵感卡模型
/// 功能：承载每日随机生成的极简拍摄任务
struct InspirationCardModel_Hush {

    /// 卡片唯一 ID（对应灵感卡池索引）
    var cardId_Hush: Int

    /// 拍摄任务描述
    var task_Hush: String

    /// 卡片展示图标（SF Symbol 名）
    var iconName_Hush: String
}

// MARK: - 季节限定挑战模型

/// 季节限定挑战模型
/// 功能：每季推出3个专属主题挑战，用户可评论互动
class SeasonChallengeModel_Hush: NSObject {

    /// 挑战唯一 ID
    var challengeId_Hush: Int

    /// 所属季节（"Spring" / "Summer" / "Autumn" / "Winter"）
    var season_Hush: String

    /// 挑战主题
    var theme_Hush: String

    /// 挑战描述
    var challengeDescription_Hush: String

    /// 卡片主题色（Hex 字符串）
    var coverColorHex_Hush: String

    /// 评论列表（可动态追加）
    var comments_Hush: [Comment_Hush]

    /// 参与人数（模拟数据）
    var participantCount_Hush: Int

    /// 初始化
    init(challengeId_hush: Int,
         season_hush: String,
         theme_hush: String,
         challengeDescription_hush: String,
         coverColorHex_hush: String,
         comments_hush: [Comment_Hush] = [],
         participantCount_hush: Int = 0) {
        self.challengeId_Hush = challengeId_hush
        self.season_Hush = season_hush
        self.theme_Hush = theme_hush
        self.challengeDescription_Hush = challengeDescription_hush
        self.coverColorHex_Hush = coverColorHex_hush
        self.comments_Hush = comments_hush
        self.participantCount_Hush = participantCount_hush
    }
}

// MARK: - 技巧提示卡模型

/// 技巧提示卡模型
/// 功能：正反面翻转卡片，正面简短标题，反面详细技巧内容
struct TipCardModel_Hush {

    /// 提示卡唯一 ID
    var tipId_Hush: Int

    /// 正面标题
    var frontTitle_Hush: String

    /// 正面图标（SF Symbol 名）
    var frontIcon_Hush: String

    /// 背面详细内容
    var backContent_Hush: String
}

/// 商店模型
class StoreModel_Hush: NSObject {
    
    /// ID编号
    var id_Hush: Int?
    
    /// 商品ID
    var goodsId_Hush: String?
    
    /// 商品名字
    var goodsName_Hush: String?
    
    /// 商品价格
    var goodsPrice_Hush: String?
    
    /// 是否顶部商品
    var goodIsTop_Hush: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Hush: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Hush: Bool?
    
    init(id_Hush: Int? = nil,
         goodsId_Hush: String? = nil,
         goodsName_Hush: String? = nil,
         goodsPrice_Hush: String? = nil,
         goodIsTop_Hush: Bool? = false,
         goodIsLimit_Hush: Bool? = false,
         goodIsVIP_Hush: Bool? = false) {
        self.id_Hush = id_Hush
        self.goodsId_Hush = goodsId_Hush
        self.goodsName_Hush = goodsName_Hush
        self.goodsPrice_Hush = goodsPrice_Hush
        self.goodIsTop_Hush = goodIsTop_Hush
        self.goodIsSpecial_Hush = goodIsLimit_Hush
        self.goodIsVIP_Hush = goodIsVIP_Hush
        super.init()
    }
}
