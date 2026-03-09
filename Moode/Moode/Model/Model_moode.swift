import Foundation
import UIKit

// MARK: 数据模型定义

// MARK: - 情绪类型枚举

/// 情绪类型枚举
/// 功能：定义8种核心情绪，每种情绪携带展示所需的 emoji、英文名称和专属渐变色对
/// 设计：通过枚举的计算属性统一管理情绪视觉元素，便于卡片、标签等组件直接使用
enum MoodType_Moode: String, Codable, CaseIterable {
    case joy_moode       = "joy"
    case calm_moode      = "calm"
    case sad_moode       = "sad"
    case excited_moode   = "excited"
    case anxious_moode   = "anxious"
    case grateful_moode  = "grateful"
    case angry_moode     = "angry"
    case surprised_moode = "surprised"
    
    /// 情绪对应的 Emoji 符号
    var emoji_Moode: String {
        switch self {
        case .joy_moode:       return "😊"
        case .calm_moode:      return "😌"
        case .sad_moode:       return "😢"
        case .excited_moode:   return "🤩"
        case .anxious_moode:   return "😰"
        case .grateful_moode:  return "🙏"
        case .angry_moode:     return "😤"
        case .surprised_moode: return "😲"
        }
    }
    
    /// 情绪英文展示名
    var displayName_Moode: String {
        switch self {
        case .joy_moode:       return "Joy"
        case .calm_moode:      return "Calm"
        case .sad_moode:       return "Sad"
        case .excited_moode:   return "Excited"
        case .anxious_moode:   return "Anxious"
        case .grateful_moode:  return "Grateful"
        case .angry_moode:     return "Angry"
        case .surprised_moode: return "Surprised"
        }
    }
    
    /// 情绪渐变起始色
    var gradientStart_Moode: UIColor {
        switch self {
        case .joy_moode:       return UIColor(hexstring_Moode: "#FFD93D")
        case .calm_moode:      return UIColor(hexstring_Moode: "#6BCB77")
        case .sad_moode:       return UIColor(hexstring_Moode: "#74B9FF")
        case .excited_moode:   return UIColor(hexstring_Moode: "#FF6B6B")
        case .anxious_moode:   return UIColor(hexstring_Moode: "#C77DFF")
        case .grateful_moode:  return UIColor(hexstring_Moode: "#FBB6CE")
        case .angry_moode:     return UIColor(hexstring_Moode: "#FF4D6D")
        case .surprised_moode: return UIColor(hexstring_Moode: "#FFB347")
        }
    }
    
    /// 情绪渐变结束色
    var gradientEnd_Moode: UIColor {
        switch self {
        case .joy_moode:       return UIColor(hexstring_Moode: "#FF9F43")
        case .calm_moode:      return UIColor(hexstring_Moode: "#4D96FF")
        case .sad_moode:       return UIColor(hexstring_Moode: "#A29BFE")
        case .excited_moode:   return UIColor(hexstring_Moode: "#FEC89A")
        case .anxious_moode:   return UIColor(hexstring_Moode: "#9C89FF")
        case .grateful_moode:  return UIColor(hexstring_Moode: "#B794F6")
        case .angry_moode:     return UIColor(hexstring_Moode: "#FF6B6B")
        case .surprised_moode: return UIColor(hexstring_Moode: "#FFCC02")
        }
    }
    
    /// 创建情绪专属渐变图层
    /// 参数：
    /// - frame_Moode: 渐变图层尺寸
    /// 返回值：配置好的 CAGradientLayer
    func createGradientLayer_Moode(frame_Moode: CGRect) -> CAGradientLayer {
        let layer_Moode = CAGradientLayer()
        layer_Moode.frame = frame_Moode
        layer_Moode.colors = [gradientStart_Moode.cgColor, gradientEnd_Moode.cgColor]
        layer_Moode.startPoint = CGPoint(x: 0, y: 0)
        layer_Moode.endPoint = CGPoint(x: 1, y: 1)
        return layer_Moode
    }
}

/// 用户数据模型
class PrewUserModel_Moode: NSObject, Codable {
    
    /// 用户ID
    var userId_Moode: Int?
    
    /// 用户名字
    var userName_Moode: String?
    
    /// 用户简介
    var userIntroduce_Moode: String?
    
    /// 用户头像
    var userHead_Moode: String?
    
    /// 用户媒体
    var userMedia_Moode: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Moode: [TitleModel_Moode] = []

    /// 用户关注数
    var userFollow_Moode: Int?

    /// 用户粉丝数
    var userFans_Moode: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Moode: Int? = nil,
         userName_Moode: String? = nil,
         userIntroduce_Moode: String? = nil,
         userHead_Moode: String? = nil,
         userMedia_Moode: [String]? = nil,
         userLike_Moode: [TitleModel_Moode] = [],
         userFollow_Moode: Int? = nil,
         userFans_Moode: Int? = nil) {
        self.userId_Moode = userId_Moode
        self.userName_Moode = userName_Moode
        self.userIntroduce_Moode = userIntroduce_Moode
        self.userHead_Moode = userHead_Moode
        self.userMedia_Moode = userMedia_Moode
        self.userLike_Moode = userLike_Moode
        self.userFollow_Moode = userFollow_Moode
        self.userFans_Moode = userFans_Moode
        super.init()
    }
}

// MARK: - 帖子类型枚举

/// 帖子类型枚举
/// 功能：区分普通帖子（无情绪标签）与情绪帖子（携带 MoodType 用于首页情绪流展示）
/// 设计：普通帖子由用户发布页发布；情绪帖子为预制数据，展示在首页情绪动态区
enum PostType_Moode: String, Codable {
    /// 普通帖子，无情绪标签
    case normal_moode = "normal"
    /// 情绪帖子，携带 moodType_Moode，展示在首页情绪流
    case mood_moode   = "mood"
}

/// 帖子数据模型
class TitleModel_Moode: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Moode: Int
    
    /// 拥有者ID
    var titleUserId_Moode: Int
    
    /// 拥有者昵称
    var titleUserName_Moode: String
    
    /// 帖子媒体
    var titleMeidas_Moode: [String]
    
    /// 帖子标题
    var title_Moode: String
    
    /// 帖子内容
    var titleContent_Moode: String
    
    /// 帖子评论列表
    var reviews_Moode: [Comment_Moode]
    
    /// 喜欢个数
    var likes_Moode: Int
    
    /// 帖子类型（普通 / 情绪），默认普通
    var postType_Moode: PostType_Moode
    
    /// 情绪类型，仅情绪帖子有效，默认为平静
    var moodType_Moode: MoodType_Moode
    
    /// 初始化帖子模型
    /// - Parameters:
    ///   - titleId_Moode: 帖子唯一 ID
    ///   - titleUserId_Moode: 发布者 ID
    ///   - titleUserName_Moode: 发布者昵称
    ///   - titleMeidas_Moode: 媒体路径列表
    ///   - title_Moode: 帖子标题
    ///   - titleContent_Moode: 帖子正文
    ///   - reviews_Moode: 评论列表
    ///   - likes_Moode: 点赞数
    ///   - postType_Moode: 帖子类型，默认 .normal_moode
    ///   - moodType_Moode: 情绪类型，情绪帖子必传，默认 .calm_moode
    init(titleId_Moode: Int,
         titleUserId_Moode: Int,
         titleUserName_Moode: String,
         titleMeidas_Moode: [String],
         title_Moode: String,
         titleContent_Moode: String,
         reviews_Moode: [Comment_Moode],
         likes_Moode: Int,
         postType_Moode: PostType_Moode = .normal_moode,
         moodType_Moode: MoodType_Moode = .calm_moode) {
        self.titleId_Moode = titleId_Moode
        self.titleUserId_Moode = titleUserId_Moode
        self.titleUserName_Moode = titleUserName_Moode
        self.titleMeidas_Moode = titleMeidas_Moode
        self.title_Moode = title_Moode
        self.titleContent_Moode = titleContent_Moode
        self.reviews_Moode = reviews_Moode
        self.likes_Moode = likes_Moode
        self.postType_Moode = postType_Moode
        self.moodType_Moode = moodType_Moode
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Moode: NSObject, Codable {
    
    /// 用户ID
    var userId_Moode: Int?
    
    /// 用户密码
    var userPwd_Moode: String?
    
    /// 用户名称
    var userName_Moode: String?
    
    /// 用户头像
    var userHead_Moode: String?

    /// 用户简介
    var userIntroduce_Moode: String?
    
    /// 用户发布帖子列表
    var userPosts_Moode: [TitleModel_Moode]
    
    /// 用户喜欢帖子列表
    var userLike_Moode: [TitleModel_Moode]

    /// 用户关注列表
    var userFollow_Moode: [PrewUserModel_Moode]
    
    /// 初始化
    init(userId_Moode: Int? = nil,
         userPwd_Moode: String? = nil,
         userName_Moode: String? = nil,
         userHead_Moode: String? = nil,
         userIntroduce_Moode: String? = nil,
         userPosts_Moode: [TitleModel_Moode],
         userLike_Moode: [TitleModel_Moode],
         userFollow_Moode: [PrewUserModel_Moode]) {
        self.userId_Moode = userId_Moode
        self.userPwd_Moode = userPwd_Moode
        self.userName_Moode = userName_Moode
        self.userHead_Moode = userHead_Moode
        self.userIntroduce_Moode = userIntroduce_Moode
        self.userPosts_Moode = userPosts_Moode
        self.userLike_Moode = userLike_Moode
        self.userFollow_Moode = userFollow_Moode
    }
}

/// 消息数据模型
class MessageModel_Moode: Codable {
    
    /// 消息ID
    var messageId_Moode: Int?
    
    /// 消息内容
    var content_Moode: String?
    
    /// 用户头像
    var userHead_Moode: String?
    
    /// 是否是我发送的
    var isMine_Moode: Bool?
    
    /// 消息时间
    var time_Moode: String?
    
    /// 初始化
    init(messageId_moode: Int? = nil,
         content_moode: String? = nil,
         userHead_moode: String? = nil,
         isMine_moode: Bool? = nil,
         time_moode: String? = nil) {
        self.messageId_Moode = messageId_moode
        self.content_Moode = content_moode
        self.userHead_Moode = userHead_moode
        self.isMine_Moode = isMine_moode
        self.time_Moode = time_moode
    }
}

/// 评论模型
class Comment_Moode: NSObject, Codable {
    
    /// 评论ID
    var commentId_Moode: Int
    
    /// 评论用户uid
    var commentUserId_Moode: Int
    
    /// 评论用户昵称
    var commentUserName_Moode: String
    
    /// 评论内容
    var commentContent_Moode: String
    
    /// 初始化
    init(commentId_Moode: Int,
         commentUserId_Moode: Int,
         commentUserName_Moode: String,
         commentContent_Moode: String) {
        self.commentId_Moode = commentId_Moode
        self.commentUserId_Moode = commentUserId_Moode
        self.commentUserName_Moode = commentUserName_Moode
        self.commentContent_Moode = commentContent_Moode
    }
}

/// 情绪挑战模型
/// 功能：描述一个官方或社区用户发起的情绪主题挑战，携带极简社区记录用于展示
/// 设计：值类型结构体，不可变，仅作展示数据使用
struct MoodChallenge_Moode {

    /// 挑战唯一 ID
    let challengeId_Moode: Int

    /// 挑战英文标题（UI 展示）
    let title_Moode: String

    /// 挑战代表性 Emoji
    let emoji_Moode: String

    /// 关联情绪类型（决定卡片渐变色）
    let moodType_Moode: MoodType_Moode

    /// 是否为官方发起（true=官方，false=社区用户发起）
    let isOfficial_Moode: Bool

    /// 1~2 条社区极简记录（英文，作为挑战卡片内容展示）
    let records_Moode: [String]

    /// 参与人数
    let participantCount_Moode: Int
}

/// 商店模型
class StoreModel_Moode: NSObject {
    
    /// ID编号
    var id_Moode: Int?
    
    /// 商品ID
    var goodsId_Moode: String?
    
    /// 商品名字
    var goodsName_Moode: String?
    
    /// 商品价格
    var goodsPrice_Moode: String?
    
    /// 是否顶部商品
    var goodIsTop_Moode: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Moode: Bool?
    
    init(id_Moode: Int? = nil,
         goodsId_Moode: String? = nil,
         goodsName_Moode: String? = nil,
         goodsPrice_Moode: String? = nil,
         goodIsTop_Moode: Bool? = false,
         goodIsLimit_Moode: Bool? = false) {
        self.id_Moode = id_Moode
        self.goodsId_Moode = goodsId_Moode
        self.goodsName_Moode = goodsName_Moode
        self.goodsPrice_Moode = goodsPrice_Moode
        self.goodIsTop_Moode = goodIsTop_Moode
        self.goodIsSpecial_Moode = goodIsLimit_Moode
        super.init()
    }
}
