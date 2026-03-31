import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Sprig: NSObject, Codable {
    
    /// 用户ID
    var userId_Sprig: Int?
    
    /// 用户名字
    var userName_Sprig: String?
    
    /// 用户简介
    var userIntroduce_Sprig: String?
    
    /// 用户头像
    var userHead_Sprig: String?
    
    /// 用户媒体
    var userMedia_Sprig: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Sprig: [TitleModel_Sprig] = []

    /// 用户关注数
    var userFollow_Sprig: Int?

    /// 用户粉丝数
    var userFans_Sprig: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Sprig: Int? = nil,
         userName_Sprig: String? = nil,
         userIntroduce_Sprig: String? = nil,
         userHead_Sprig: String? = nil,
         userMedia_Sprig: [String]? = nil,
         userLike_Sprig: [TitleModel_Sprig] = [],
         userFollow_Sprig: Int? = nil,
         userFans_Sprig: Int? = nil) {
        self.userId_Sprig = userId_Sprig
        self.userName_Sprig = userName_Sprig
        self.userIntroduce_Sprig = userIntroduce_Sprig
        self.userHead_Sprig = userHead_Sprig
        self.userMedia_Sprig = userMedia_Sprig
        self.userLike_Sprig = userLike_Sprig
        self.userFollow_Sprig = userFollow_Sprig
        self.userFans_Sprig = userFans_Sprig
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Sprig: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Sprig: Int
    
    /// 拥有者ID
    var titleUserId_Sprig: Int
    
    /// 拥有者昵称
    var titleUserName_Sprig: String
    
    /// 帖子媒体
    var titleMeidas_Sprig: [String]
    
    /// 帖子标题
    var title_Sprig: String
    
    /// 帖子内容
    var titleContent_Sprig: String
    
    /// 帖子评论列表
    var reviews_Sprig: [Comment_Sprig]
    
    /// 喜欢个数
    var likes_Sprig: Int
    
    /// 帖子标签（花卉分类标签，如 Spring / Indoor 等）
    var titleTags_Sprig: [String]
    
    init(titleId_Sprig: Int,
         titleUserId_Sprig: Int,
         titleUserName_Sprig: String,
         titleMeidas_Sprig: [String],
         title_Sprig: String,
         titleContent_Sprig: String,
         reviews_Sprig: [Comment_Sprig],
         likes_Sprig: Int,
         titleTags_Sprig: [String] = []) {
        self.titleId_Sprig = titleId_Sprig
        self.titleUserId_Sprig = titleUserId_Sprig
        self.titleUserName_Sprig = titleUserName_Sprig
        self.titleMeidas_Sprig = titleMeidas_Sprig
        self.title_Sprig = title_Sprig
        self.titleContent_Sprig = titleContent_Sprig
        self.reviews_Sprig = reviews_Sprig
        self.likes_Sprig = likes_Sprig
        self.titleTags_Sprig = titleTags_Sprig
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Sprig: NSObject, Codable {
    
    /// 用户ID
    var userId_Sprig: Int?
    
    /// 用户密码
    var userPwd_Sprig: String?
    
    /// 用户名称
    var userName_Sprig: String?
    
    /// 用户头像
    var userHead_Sprig: String?
    
    /// 用户简介
    var userIntroduce_Sprig: String?

    /// 粉丝数（关注我的人数，本地缓存值）
    var userFansCount_Sprig: Int = 0
    
    /// 用户发布帖子列表
    var userPosts_Sprig: [TitleModel_Sprig]
    
    /// 用户喜欢帖子列表
    var userLike_Sprig: [TitleModel_Sprig]

    /// 用户关注列表
    var userFollow_Sprig: [PrewUserModel_Sprig]
    
    /// 初始化
    init(userId_Sprig: Int? = nil,
         userPwd_Sprig: String? = nil,
         userName_Sprig: String? = nil,
         userHead_Sprig: String? = nil,
         userIntroduce_Sprig: String? = nil,
         userPosts_Sprig: [TitleModel_Sprig],
         userLike_Sprig: [TitleModel_Sprig],
         userFollow_Sprig: [PrewUserModel_Sprig]) {
        self.userId_Sprig = userId_Sprig
        self.userPwd_Sprig = userPwd_Sprig
        self.userName_Sprig = userName_Sprig
        self.userHead_Sprig = userHead_Sprig
        self.userIntroduce_Sprig = userIntroduce_Sprig
        self.userPosts_Sprig = userPosts_Sprig
        self.userLike_Sprig = userLike_Sprig
        self.userFollow_Sprig = userFollow_Sprig
    }
}

/// 消息数据模型
class MessageModel_Sprig: Codable {
    
    /// 消息ID
    var messageId_Sprig: Int?
    
    /// 消息内容
    var content_Sprig: String?
    
    /// 用户头像
    var userHead_Sprig: String?
    
    /// 是否是我发送的
    var isMine_Sprig: Bool?
    
    /// 消息时间
    var time_Sprig: String?
    
    /// 初始化
    init(messageId_sprig: Int? = nil,
         content_sprig: String? = nil,
         userHead_sprig: String? = nil,
         isMine_sprig: Bool? = nil,
         time_sprig: String? = nil) {
        self.messageId_Sprig = messageId_sprig
        self.content_Sprig = content_sprig
        self.userHead_Sprig = userHead_sprig
        self.isMine_Sprig = isMine_sprig
        self.time_Sprig = time_sprig
    }
}

/// 评论模型
class Comment_Sprig: NSObject, Codable {
    
    /// 评论ID
    var commentId_Sprig: Int
    
    /// 评论用户uid
    var commentUserId_Sprig: Int
    
    /// 评论用户昵称
    var commentUserName_Sprig: String
    
    /// 评论内容
    var commentContent_Sprig: String
    
    /// 初始化
    init(commentId_Sprig: Int,
         commentUserId_Sprig: Int,
         commentUserName_Sprig: String,
         commentContent_Sprig: String) {
        self.commentId_Sprig = commentId_Sprig
        self.commentUserId_Sprig = commentUserId_Sprig
        self.commentUserName_Sprig = commentUserName_Sprig
        self.commentContent_Sprig = commentContent_Sprig
    }
}

/// 花期关键节点枚举
/// 功能：标记鲜花成长的四个里程碑阶段
enum FlowerMilestone_Sprig: Int, CaseIterable {
    /// 初绽 - 花苞初开
    case firstBloom = 0
    /// 盛放 - 全盛花期
    case fullBloom = 1
    /// 半谢 - 花期渐退
    case fadingBloom = 2
    /// 封存 - 记录收藏
    case preserved = 3

    /// 节点中文名
    var title_Sprig: String {
        switch self {
        case .firstBloom:  return "初绽"
        case .fullBloom:   return "盛放"
        case .fadingBloom: return "半谢"
        case .preserved:   return "封存"
        }
    }

    /// 节点英文副标题
    var subtitle_Sprig: String {
        switch self {
        case .firstBloom:  return "First Bloom"
        case .fullBloom:   return "Full Bloom"
        case .fadingBloom: return "Fading"
        case .preserved:   return "Preserved"
        }
    }

    /// SF Symbol 图标
    var icon_Sprig: String {
        switch self {
        case .firstBloom:  return "sparkle"
        case .fullBloom:   return "sun.max.fill"
        case .fadingBloom: return "leaf.fill"
        case .preserved:   return "archivebox.fill"
        }
    }

    /// 主题色十六进制
    var hexColor_Sprig: String {
        switch self {
        case .firstBloom:  return "#F687B3"
        case .fullBloom:   return "#F6AD55"
        case .fadingBloom: return "#9F7AEA"
        case .preserved:   return "#48BB78"
        }
    }
}

/// 花卉状态记录（养花轨迹单条记录）
/// 功能：记录某一天的鲜花状态，标注节点并附带养护心得
class FlowerStatusRecord_Sprig: NSObject {

    /// 记录ID
    var recordId_Sprig: Int

    /// 花期节点
    var milestone_Sprig: FlowerMilestone_Sprig

    /// 养护心得/备注
    var notes_Sprig: String

    /// 创建时间
    var createdAt_Sprig: Date

    /// 初始化
    init(recordId_Sprig: Int,
         milestone_Sprig: FlowerMilestone_Sprig,
         notes_Sprig: String) {
        self.recordId_Sprig = recordId_Sprig
        self.milestone_Sprig = milestone_Sprig
        self.notes_Sprig = notes_Sprig
        self.createdAt_Sprig = Date()
        super.init()
    }
}

/// 鲜花时光胶囊
/// 功能：封存鲜花照片和养护心得，设置未来解锁时间
class FlowerCapsule_Sprig: NSObject {

    /// 胶囊ID
    var capsuleId_Sprig: Int

    /// 养护心得
    var notes_Sprig: String

    /// 解锁年数（1 或 3）
    var unlockYears_Sprig: Int

    /// 创建日期
    var createDate_Sprig: Date

    /// 解锁日期
    var unlockDate_Sprig: Date

    /// 是否已到达解锁时间
    var isUnlocked_Sprig: Bool {
        return Date() >= unlockDate_Sprig
    }

    /// 距解锁剩余天数（未解锁时）
    var daysToUnlock_Sprig: Int {
        let diff_sprig = Calendar.current.dateComponents([.day], from: Date(), to: unlockDate_Sprig)
        return max(0, diff_sprig.day ?? 0)
    }

    /// 初始化
    init(capsuleId_Sprig: Int, notes_Sprig: String, unlockYears_Sprig: Int) {
        self.capsuleId_Sprig = capsuleId_Sprig
        self.notes_Sprig = notes_Sprig
        self.unlockYears_Sprig = unlockYears_Sprig
        self.createDate_Sprig = Date()
        var comps_sprig = DateComponents()
        comps_sprig.year = unlockYears_Sprig
        self.unlockDate_Sprig = Calendar.current.date(byAdding: comps_sprig, to: Date()) ?? Date()
        super.init()
    }
}

/// 花卉百科模型
/// 功能：描述一种花卉的基本特征、花期、养护要点等信息
class FlowerModel_Sprig: NSObject {
    
    /// 花卉ID
    var flowerId_Sprig: Int
    
    /// 花卉英文名
    var flowerName_Sprig: String
    
    /// 花卉中文名
    var flowerCnName_Sprig: String
    
    /// 花卉 emoji 符号
    var flowerEmoji_Sprig: String
    
    /// SF Symbol 图标名
    var flowerIcon_Sprig: String
    
    /// 主题色（十六进制）
    var flowerHexColor_Sprig: String
    
    /// 花期月份列表（1-12）
    var bloomMonths_Sprig: [Int]
    
    /// 养护难度（1=简单 2=中等 3=困难）
    var careLevel_Sprig: Int
    
    /// 浇水间隔天数
    var waterDays_Sprig: Int
    
    /// 养护要点简介
    var tipText_Sprig: String
    
    /// 适合场景（Indoor / Outdoor / Both）
    var placement_Sprig: String
    
    /// 初始化
    init(flowerId_Sprig: Int,
         flowerName_Sprig: String,
         flowerCnName_Sprig: String,
         flowerEmoji_Sprig: String,
         flowerIcon_Sprig: String,
         flowerHexColor_Sprig: String,
         bloomMonths_Sprig: [Int],
         careLevel_Sprig: Int,
         waterDays_Sprig: Int,
         tipText_Sprig: String,
         placement_Sprig: String) {
        self.flowerId_Sprig = flowerId_Sprig
        self.flowerName_Sprig = flowerName_Sprig
        self.flowerCnName_Sprig = flowerCnName_Sprig
        self.flowerEmoji_Sprig = flowerEmoji_Sprig
        self.flowerIcon_Sprig = flowerIcon_Sprig
        self.flowerHexColor_Sprig = flowerHexColor_Sprig
        self.bloomMonths_Sprig = bloomMonths_Sprig
        self.careLevel_Sprig = careLevel_Sprig
        self.waterDays_Sprig = waterDays_Sprig
        self.tipText_Sprig = tipText_Sprig
        self.placement_Sprig = placement_Sprig
        super.init()
    }
}

/// 花期筛选标签模型
/// 功能：用于发现页的标签筛选，每个标签对应一组关键词
class FlowerTagModel_Sprig: NSObject {
    
    /// 标签ID
    var tagId_Sprig: Int
    
    /// 标签名称（英文显示）
    var tagName_Sprig: String
    
    /// 标签图标（SF Symbol）
    var tagIcon_Sprig: String
    
    /// 标签颜色（十六进制）
    var tagHexColor_Sprig: String
    
    /// 关联关键词（用于帖子筛选匹配）
    var relatedKeywords_Sprig: [String]
    
    /// 初始化
    init(tagId_Sprig: Int,
         tagName_Sprig: String,
         tagIcon_Sprig: String,
         tagHexColor_Sprig: String,
         relatedKeywords_Sprig: [String]) {
        self.tagId_Sprig = tagId_Sprig
        self.tagName_Sprig = tagName_Sprig
        self.tagIcon_Sprig = tagIcon_Sprig
        self.tagHexColor_Sprig = tagHexColor_Sprig
        self.relatedKeywords_Sprig = relatedKeywords_Sprig
        super.init()
    }
}

/// 商店模型
class StoreModel_Sprig: NSObject {
    
    /// ID编号
    var id_Sprig: Int?
    
    /// 商品ID
    var goodsId_Sprig: String?
    
    /// 商品名字
    var goodsName_Sprig: String?
    
    /// 商品价格
    var goodsPrice_Sprig: String?
    
    /// 是否顶部商品
    var goodIsTop_Sprig: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Sprig: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Sprig: Bool?
    
    init(id_Sprig: Int? = nil,
         goodsId_Sprig: String? = nil,
         goodsName_Sprig: String? = nil,
         goodsPrice_Sprig: String? = nil,
         goodIsTop_Sprig: Bool? = false,
         goodIsLimit_Sprig: Bool? = false,
         goodIsVIP_Sprig: Bool? = false) {
        self.id_Sprig = id_Sprig
        self.goodsId_Sprig = goodsId_Sprig
        self.goodsName_Sprig = goodsName_Sprig
        self.goodsPrice_Sprig = goodsPrice_Sprig
        self.goodIsTop_Sprig = goodIsTop_Sprig
        self.goodIsSpecial_Sprig = goodIsLimit_Sprig
        self.goodIsVIP_Sprig = goodIsVIP_Sprig
        super.init()
    }
}
