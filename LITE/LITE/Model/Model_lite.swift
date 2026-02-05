import Foundation

// MARK: - 数据模型定义

/// 预览用户数据模型
class PrewUserModel_lite: NSObject, Codable, Identifiable {
    
    /// 用户唯一标识符，用于 Identifiable 协议
    var id: Int? { userId_lite }
    
    /// 用户ID
    var userId_lite: Int?
    
    /// 用户名字
    var userName_lite: String?
    
    /// 用户简介
    var userIntroduce_lite: String?
    
    /// 用户头像
    var userHead_lite: String?
    
    /// 用户媒体
    var userMedia_lite: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_lite: [TitleModel_lite] = []
    
    /// 用户关注数
    var userFollow_lite: Int?
    
    /// 用户粉丝数
    var userFans_lite: Int?
    
    /// 初始化方法
    override init() {
        super.init()
    }
    
    /// 自定义初始化方法
    init(userId_lite: Int? = nil,
         userName_lite: String? = nil,
         userIntroduce_lite: String? = nil,
         userHead_lite: String? = nil,
         userMedia_lite: [String]? = nil,
         userLike_lite: [TitleModel_lite] = [],
         userFollow_lite: Int? = nil,
         userFans_lite: Int? = nil) {
        self.userId_lite = userId_lite
        self.userName_lite = userName_lite
        self.userIntroduce_lite = userIntroduce_lite
        self.userHead_lite = userHead_lite
        self.userMedia_lite = userMedia_lite
        self.userLike_lite = userLike_lite
        self.userFollow_lite = userFollow_lite
        self.userFans_lite = userFans_lite
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_lite: NSObject, Codable, Identifiable {
    
    /// 帖子唯一标识符，用于 Identifiable 协议
    var id: Int { titleId_lite }
    
    /// 帖子ID
    var titleId_lite: Int
    
    /// 拥有者ID
    var titleUserId_lite: Int
    
    /// 拥有者昵称
    var titleUserName_lite: String
    
    /// 帖子媒体资源数组
    var titleMeidas_lite: [String]
    
    /// 帖子标题
    var title_lite: String
    
    /// 帖子内容
    var titleContent_lite: String
    
    /// 帖子评论列表
    var reviews_lite: [Comment_lite]
    
    /// 喜欢个数
    var likes_lite: Int
    
    /// 初始化方法
    init(titleId_lite: Int,
         titleUserId_lite: Int,
         titleUserName_lite: String,
         titleMeidas_lite: [String],
         title_lite: String,
         titleContent_lite: String,
         reviews_lite: [Comment_lite],
         likes_lite: Int) {
        self.titleId_lite = titleId_lite
        self.titleUserId_lite = titleUserId_lite
        self.titleUserName_lite = titleUserName_lite
        self.titleMeidas_lite = titleMeidas_lite
        self.title_lite = title_lite
        self.titleContent_lite = titleContent_lite
        self.reviews_lite = reviews_lite
        self.likes_lite = likes_lite
        super.init()
    }
}

/// 登录用户数据模型
class LoginUserModel_lite: NSObject, Codable, Identifiable {
    
    /// 用户唯一标识符，用于 Identifiable 协议
    var id: Int? { userId_lite }
    
    /// 用户ID
    var userId_lite: Int?
    
    /// 用户密码
    var userPwd_lite: String?
    
    /// 用户名称
    var userName_lite: String?
    
    /// 用户头像
    var userHead_lite: String?

    /// 用户简介
    var userIntroduce_lite: String?

    /// 用户封面
    var userCover_lite: String?
    
    /// 用户发布帖子列表
    var userPosts_lite: [TitleModel_lite]
    
    /// 用户喜欢帖子列表
    var userLike_lite: [TitleModel_lite]
    
    /// 用户关注列表
    var userFollow_lite: [PrewUserModel_lite]
    
    /// 用户的穿搭时光轴列表
    var userTimeline_lite: [OutfitTimeline_lite]
    
    /// 初始化方法
    /// - Parameters:
    ///   - userId_lite: 用户ID
    ///   - userPwd_lite: 用户密码
    ///   - userName_lite: 用户名称
    ///   - userHead_lite: 用户头像
    ///   - userIntroduce_lite: 用户简介
    ///   - userCover_lite: 用户封面
    ///   - userPosts_lite: 用户发布帖子列表
    ///   - userLike_lite: 用户喜欢帖子列表
    ///   - userFollow_lite: 用户关注列表
    ///   - userTimeline_lite: 用户穿搭时光轴列表
    init(userId_lite: Int? = nil,
         userPwd_lite: String? = nil,
         userName_lite: String? = nil,
         userHead_lite: String? = nil,
         userIntroduce_lite: String? = nil,
         userCover_lite: String? = nil,
         userPosts_lite: [TitleModel_lite],
         userLike_lite: [TitleModel_lite],
         userFollow_lite: [PrewUserModel_lite],
         userTimeline_lite: [OutfitTimeline_lite] = []) {
        self.userId_lite = userId_lite
        self.userPwd_lite = userPwd_lite
        self.userName_lite = userName_lite
        self.userHead_lite = userHead_lite
        self.userIntroduce_lite = userIntroduce_lite
        self.userCover_lite = userCover_lite
        self.userPosts_lite = userPosts_lite
        self.userLike_lite = userLike_lite
        self.userFollow_lite = userFollow_lite
        self.userTimeline_lite = userTimeline_lite
        super.init()
    }
}

/// 消息数据模型
class MessageModel_lite: Codable, Identifiable {
    
    /// 消息唯一标识符，用于 Identifiable 协议
    var id: Int? { messageId_lite }
    
    /// 消息ID
    var messageId_lite: Int?
    
    /// 消息内容
    var content_lite: String?
    
    /// 用户头像
    var userHead_lite: String?
    
    /// 是否是我发送的
    var isMine_lite: Bool?
    
    /// 消息时间
    var time_lite: String?
    
    /// 初始化方法
    init(messageId_lite: Int? = nil,
         content_lite: String? = nil,
         userHead_lite: String? = nil,
         isMine_lite: Bool? = nil,
         time_lite: String? = nil) {
        self.messageId_lite = messageId_lite
        self.content_lite = content_lite
        self.userHead_lite = userHead_lite
        self.isMine_lite = isMine_lite
        self.time_lite = time_lite
    }
}

/// 评论数据模型
class Comment_lite: NSObject, Codable, Identifiable {
    
    /// 评论唯一标识符，用于 Identifiable 协议
    var id: Int { commentId_lite }
    
    /// 评论ID
    var commentId_lite: Int
    
    /// 评论用户ID
    var commentUserId_lite: Int
    
    /// 评论用户昵称
    var commentUserName_lite: String
    
    /// 评论内容
    var commentContent_lite: String
    
    /// 初始化方法
    init(commentId_lite: Int,
         commentUserId_lite: Int,
         commentUserName_lite: String,
         commentContent_lite: String) {
        self.commentId_lite = commentId_lite
        self.commentUserId_lite = commentUserId_lite
        self.commentUserName_lite = commentUserName_lite
        self.commentContent_lite = commentContent_lite
        super.init()
    }
}

// MARK: - 穿搭相关数据模型

/// 单品类型枚举
enum OutfitItemType_lite: String, Codable, CaseIterable {
    case top_lite = "Top"
    case bottom_lite = "Bottom"
    case shoes_lite = "Shoes"
    case accessory_lite = "Accessory"
}

/// 穿搭风格枚举
enum OutfitStyle_lite: String, Codable, CaseIterable {
    case casual_lite = "Casual"
    case formal_lite = "Formal"
    case street_lite = "Street"
    case vintage_lite = "Vintage"
    case sporty_lite = "Sporty"
}

/// 穿搭场景枚举
enum OutfitScene_lite: String, Codable, CaseIterable {
    case daily_lite = "Daily"
    case work_lite = "Work"
    case date_lite = "Date"
    case party_lite = "Party"
    case sport_lite = "Sport"
}

/// 单品数据模型
class OutfitItem_lite: NSObject, Codable, Identifiable {
    
    /// 单品唯一标识符
    var id: Int { itemId_lite }
    
    /// 单品ID
    var itemId_lite: Int
    
    /// 单品名称
    var itemName_lite: String
    
    /// 单品类型
    var itemType_lite: OutfitItemType_lite
    
    /// 单品图片
    var itemImage_lite: String
    
    /// 单品颜色
    var itemColor_lite: String
    
    /// 单品品牌
    var itemBrand_lite: String?
    
    /// 初始化方法
    init(itemId_lite: Int,
         itemName_lite: String,
         itemType_lite: OutfitItemType_lite,
         itemImage_lite: String,
         itemColor_lite: String,
         itemBrand_lite: String? = nil) {
        self.itemId_lite = itemId_lite
        self.itemName_lite = itemName_lite
        self.itemType_lite = itemType_lite
        self.itemImage_lite = itemImage_lite
        self.itemColor_lite = itemColor_lite
        self.itemBrand_lite = itemBrand_lite
        super.init()
    }
}

/// 穿搭组合数据模型
class OutfitCombo_lite: NSObject, Codable, Identifiable {
    
    /// 穿搭组合唯一标识符
    var id: Int { comboId_lite }
    
    /// 穿搭组合ID
    var comboId_lite: Int
    
    /// 穿搭标题
    var comboTitle_lite: String
    
    /// 穿搭描述
    var comboDescription_lite: String
    
    /// 穿搭单品列表（2-3件）
    var items_lite: [OutfitItem_lite]
    
    /// 穿搭风格
    var style_lite: OutfitStyle_lite
    
    /// 穿搭场景
    var scene_lite: OutfitScene_lite
    
    /// 创建日期
    var createDate_lite: Date
    
    /// 是否收藏
    var isFavorited_lite: Bool
    
    /// 是否标记为当日穿搭
    var isDailyOutfit_lite: Bool
    
    /// 点赞数
    var likes_lite: Int
    
    /// 用户ID（用于灵感评论）
    var userId_lite: Int?
    
    /// 初始化方法
    init(comboId_lite: Int,
         comboTitle_lite: String,
         comboDescription_lite: String,
         items_lite: [OutfitItem_lite],
         style_lite: OutfitStyle_lite,
         scene_lite: OutfitScene_lite,
         createDate_lite: Date = Date(),
         isFavorited_lite: Bool = false,
         isDailyOutfit_lite: Bool = false,
         likes_lite: Int = 0,
         userId_lite: Int? = nil) {
        self.comboId_lite = comboId_lite
        self.comboTitle_lite = comboTitle_lite
        self.comboDescription_lite = comboDescription_lite
        self.items_lite = items_lite
        self.style_lite = style_lite
        self.scene_lite = scene_lite
        self.createDate_lite = createDate_lite
        self.isFavorited_lite = isFavorited_lite
        self.isDailyOutfit_lite = isDailyOutfit_lite
        self.likes_lite = likes_lite
        self.userId_lite = userId_lite
        super.init()
    }
}

/// 穿搭时光轴记录
class OutfitTimeline_lite: NSObject, Codable, Identifiable {
    
    /// 时光轴记录唯一标识符
    var id: Int { timelineId_lite }
    
    /// 时光轴记录ID
    var timelineId_lite: Int
    
    /// 用户ID
    var userId_lite: Int
    
    /// 穿搭组合
    var outfit_lite: OutfitCombo_lite
    
    /// 记录日期
    var recordDate_lite: Date
    
    /// 文字备注
    var note_lite: String?
    
    /// 纪念标签（如"第一次约会的穿搭"）
    var memoryTag_lite: String?
    
    /// 初始化方法
    init(timelineId_lite: Int,
         userId_lite: Int,
         outfit_lite: OutfitCombo_lite,
         recordDate_lite: Date = Date(),
         note_lite: String? = nil,
         memoryTag_lite: String? = nil) {
        self.timelineId_lite = timelineId_lite
        self.userId_lite = userId_lite
        self.outfit_lite = outfit_lite
        self.recordDate_lite = recordDate_lite
        self.note_lite = note_lite
        self.memoryTag_lite = memoryTag_lite
        super.init()
    }
}

/// 物多搭轻挑战数据模型（也用于灵感活动）
class OutfitChallenge_lite: NSObject, Codable, Identifiable {
    
    /// 挑战唯一标识符
    var id: Int { challengeId_lite }
    
    /// 挑战ID
    var challengeId_lite: Int
    
    /// 挑战标题
    var challengeTitle_lite: String
    
    /// 挑战描述
    var challengeDescription_lite: String
    
    /// 基础单品
    var baseItem_lite: OutfitItem_lite
    
    /// 创建者用户ID
    var creatorUserId_lite: Int
    
    /// 创建者用户名
    var creatorUserName_lite: String
    
    /// 参与者提交的穿搭组合（灵感评论存储在此）
    var submissions_lite: [OutfitCombo_lite]
    
    /// 创建日期
    var createDate_lite: Date
    
    /// 截止日期
    var endDate_lite: Date
    
    /// 是否为官方挑战
    var isOfficial_lite: Bool
    
    /// 挑战状态（进行中/已结束）
    var isActive_lite: Bool
    
    /// 初始化方法
    /// - Parameters:
    ///   - challengeId_lite: 挑战ID
    ///   - challengeTitle_lite: 挑战标题
    ///   - challengeDescription_lite: 挑战描述
    ///   - baseItem_lite: 基础单品
    ///   - creatorUserId_lite: 创建者用户ID
    ///   - creatorUserName_lite: 创建者用户名
    ///   - submissions_lite: 参与者提交列表
    ///   - createDate_lite: 创建日期
    ///   - endDate_lite: 截止日期
    ///   - isOfficial_lite: 是否为官方
    ///   - isActive_lite: 是否活跃
    init(challengeId_lite: Int,
         challengeTitle_lite: String,
         challengeDescription_lite: String,
         baseItem_lite: OutfitItem_lite,
         creatorUserId_lite: Int,
         creatorUserName_lite: String,
         submissions_lite: [OutfitCombo_lite] = [],
         createDate_lite: Date = Date(),
         endDate_lite: Date,
         isOfficial_lite: Bool = false,
         isActive_lite: Bool = true) {
        self.challengeId_lite = challengeId_lite
        self.challengeTitle_lite = challengeTitle_lite
        self.challengeDescription_lite = challengeDescription_lite
        self.baseItem_lite = baseItem_lite
        self.creatorUserId_lite = creatorUserId_lite
        self.creatorUserName_lite = creatorUserName_lite
        self.submissions_lite = submissions_lite
        self.createDate_lite = createDate_lite
        self.endDate_lite = endDate_lite
        self.isOfficial_lite = isOfficial_lite
        self.isActive_lite = isActive_lite
        super.init()
    }
}

/// 灵感评论数据模型（扩展模型，用于更好地表示灵感评论）
class InspirationComment_lite: NSObject, Codable, Identifiable {
    
    /// 评论唯一标识符
    var id: Int { commentId_lite }
    
    /// 评论ID
    var commentId_lite: Int
    
    /// 挑战ID
    var challengeId_lite: Int
    
    /// 评论用户ID
    var userId_lite: Int
    
    /// 评论用户名
    var userName_lite: String
    
    /// 评论内容
    var content_lite: String
    
    /// 评论时间
    var createDate_lite: Date
    
    /// 点赞数
    var likes_lite: Int
    
    /// 初始化方法
    /// - Parameters:
    ///   - commentId_lite: 评论ID
    ///   - challengeId_lite: 挑战ID
    ///   - userId_lite: 用户ID
    ///   - userName_lite: 用户名
    ///   - content_lite: 评论内容
    ///   - createDate_lite: 创建时间
    ///   - likes_lite: 点赞数
    init(commentId_lite: Int,
         challengeId_lite: Int,
         userId_lite: Int,
         userName_lite: String,
         content_lite: String,
         createDate_lite: Date = Date(),
         likes_lite: Int = 0) {
        self.commentId_lite = commentId_lite
        self.challengeId_lite = challengeId_lite
        self.userId_lite = userId_lite
        self.userName_lite = userName_lite
        self.content_lite = content_lite
        self.createDate_lite = createDate_lite
        self.likes_lite = likes_lite
        super.init()
    }
}

/// 穿搭时光胶囊数据模型
class OutfitCapsule_lite: NSObject, Codable, Identifiable {
    
    /// 时光胶囊唯一标识符
    var id: Int { capsuleId_lite }
    
    /// 时光胶囊ID
    var capsuleId_lite: Int
    
    /// 用户ID
    var userId_lite: Int
    
    /// 穿搭组合
    var outfit_lite: OutfitCombo_lite
    
    /// 封存时的心得
    var thoughtNote_lite: String
    
    /// 封存日期
    var sealDate_lite: Date
    
    /// 解锁日期
    var unlockDate_lite: Date
    
    /// 是否已解锁
    var isUnlocked_lite: Bool
    
    /// 解锁时的对比心得
    var unlockNote_lite: String?
    
    /// 初始化方法
    init(capsuleId_lite: Int,
         userId_lite: Int,
         outfit_lite: OutfitCombo_lite,
         thoughtNote_lite: String,
         sealDate_lite: Date = Date(),
         unlockDate_lite: Date,
         isUnlocked_lite: Bool = false,
         unlockNote_lite: String? = nil) {
        self.capsuleId_lite = capsuleId_lite
        self.userId_lite = userId_lite
        self.outfit_lite = outfit_lite
        self.thoughtNote_lite = thoughtNote_lite
        self.sealDate_lite = sealDate_lite
        self.unlockDate_lite = unlockDate_lite
        self.isUnlocked_lite = isUnlocked_lite
        self.unlockNote_lite = unlockNote_lite
        super.init()
    }
}
