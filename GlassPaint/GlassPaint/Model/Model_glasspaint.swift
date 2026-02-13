import Foundation

// MARK: 数据模型定义

// MARK: - 彩绘相关枚举

/// 彩绘难度等级枚举
/// 功能：定义用户和作品的彩绘水平
enum PaintingLevel_Glasspaint: String, Codable {
    /// 新手
    case beginner_glasspaint = "Beginner"
    /// 进阶
    case intermediate_glasspaint = "Intermediate"
    /// 高级
    case advanced_glasspaint = "Advanced"
}

/// 彩绘风格枚举
/// 功能：定义作品的艺术风格
enum PaintingStyle_Glasspaint: String, Codable {
    /// 简约
    case minimalist_glasspaint = "Minimalist"
    /// 复古
    case retro_glasspaint = "Retro"
    /// 可爱
    case cute_glasspaint = "Cute"
    /// 现代
    case modern_glasspaint = "Modern"
    /// 艺术
    case artistic_glasspaint = "Artistic"
}

/// 玻璃载体类型枚举
/// 功能：定义彩绘作品的玻璃载体类型
enum CarrierType_Glasspaint: String, Codable {
    /// 玻璃杯
    case glassCup_glasspaint = "Glass Cup"
    /// 玻璃片
    case glassPlate_glasspaint = "Glass Plate"
    /// 小摆件
    case ornament_glasspaint = "Ornament"
    /// 花瓶
    case vase_glasspaint = "Vase"
    /// 窗户
    case window_glasspaint = "Window"
}

/// 排行榜分类枚举
/// 功能：定义榜单的分类方式
enum RankingCategory_Glasspaint: String, Codable {
    /// 按场景
    case scene_glasspaint = "Scene"
    /// 按载体
    case carrier_glasspaint = "Carrier"
    /// 按风格
    case style_glasspaint = "Style"
}

/// 用户数据模型
class PrewUserModel_Glasspaint: NSObject, Codable {
    
    /// 用户ID
    var userId_Glasspaint: Int?
    
    /// 用户名字
    var userName_Glasspaint: String?
    
    /// 用户简介
    var userIntroduce_Glasspaint: String?
    
    /// 用户头像
    var userHead_Glasspaint: String?
    
    /// 用户媒体
    var userMedia_Glasspaint: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Glasspaint: [TitleModel_Glasspaint] = []

    /// 用户关注数
    var userFollow_Glasspaint: Int?

    /// 用户粉丝数
    var userFans_Glasspaint: Int?
    
    // MARK: - 彩绘相关属性
    
    /// 用户彩绘水平
    var paintingLevel_Glasspaint: PaintingLevel_Glasspaint?
    
    /// 偏好风格列表
    var preferredStyles_Glasspaint: [PaintingStyle_Glasspaint]?
    
    /// 创作场景偏好
    var preferredScenes_Glasspaint: [String]?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Glasspaint: Int? = nil,
         userName_Glasspaint: String? = nil,
         userIntroduce_Glasspaint: String? = nil,
         userHead_Glasspaint: String? = nil,
         userMedia_Glasspaint: [String]? = nil,
         userLike_Glasspaint: [TitleModel_Glasspaint] = [],
         userFollow_Glasspaint: Int? = nil,
         userFans_Glasspaint: Int? = nil,
         paintingLevel_Glasspaint: PaintingLevel_Glasspaint? = .beginner_glasspaint,
         preferredStyles_Glasspaint: [PaintingStyle_Glasspaint]? = nil,
         preferredScenes_Glasspaint: [String]? = nil) {
        self.userId_Glasspaint = userId_Glasspaint
        self.userName_Glasspaint = userName_Glasspaint
        self.userIntroduce_Glasspaint = userIntroduce_Glasspaint
        self.userHead_Glasspaint = userHead_Glasspaint
        self.userMedia_Glasspaint = userMedia_Glasspaint
        self.userLike_Glasspaint = userLike_Glasspaint
        self.userFollow_Glasspaint = userFollow_Glasspaint
        self.userFans_Glasspaint = userFans_Glasspaint
        self.paintingLevel_Glasspaint = paintingLevel_Glasspaint
        self.preferredStyles_Glasspaint = preferredStyles_Glasspaint
        self.preferredScenes_Glasspaint = preferredScenes_Glasspaint
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Glasspaint: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Glasspaint: Int
    
    /// 拥有者ID
    var titleUserId_Glasspaint: Int
    
    /// 拥有者昵称
    var titleUserName_Glasspaint: String
    
    /// 帖子媒体
    var titleMeidas_Glasspaint: [String]
    
    /// 帖子标题
    var title_Glasspaint: String
    
    /// 帖子内容
    var titleContent_Glasspaint: String
    
    /// 帖子评论列表
    var reviews_Glasspaint: [Comment_Glasspaint]
    
    /// 喜欢个数
    var likes_Glasspaint: Int
    
    // MARK: - 彩绘相关属性
    
    /// 彩绘难度等级
    var paintingLevel_Glasspaint: PaintingLevel_Glasspaint
    
    /// 彩绘风格
    var paintingStyle_Glasspaint: PaintingStyle_Glasspaint
    
    /// 应用场景
    var scene_Glasspaint: String
    
    /// 玻璃载体类型
    var carrier_Glasspaint: CarrierType_Glasspaint
    
    /// 复刻率（0-100）
    var replicationRate_Glasspaint: Int
    
    /// 创作日期
    var createdDate_Glasspaint: Date
    
    init(titleId_Glasspaint: Int,
         titleUserId_Glasspaint: Int,
         titleUserName_Glasspaint: String,
         titleMeidas_Glasspaint: [String],
         title_Glasspaint: String,
         titleContent_Glasspaint: String,
         reviews_Glasspaint: [Comment_Glasspaint],
         likes_Glasspaint: Int,
         paintingLevel_Glasspaint: PaintingLevel_Glasspaint = .beginner_glasspaint,
         paintingStyle_Glasspaint: PaintingStyle_Glasspaint = .modern_glasspaint,
         scene_Glasspaint: String = "Home Decoration",
         carrier_Glasspaint: CarrierType_Glasspaint = .glassCup_glasspaint,
         replicationRate_Glasspaint: Int = 50,
         createdDate_Glasspaint: Date = Date()) {
        self.titleId_Glasspaint = titleId_Glasspaint
        self.titleUserId_Glasspaint = titleUserId_Glasspaint
        self.titleUserName_Glasspaint = titleUserName_Glasspaint
        self.titleMeidas_Glasspaint = titleMeidas_Glasspaint
        self.title_Glasspaint = title_Glasspaint
        self.titleContent_Glasspaint = titleContent_Glasspaint
        self.reviews_Glasspaint = reviews_Glasspaint
        self.likes_Glasspaint = likes_Glasspaint
        self.paintingLevel_Glasspaint = paintingLevel_Glasspaint
        self.paintingStyle_Glasspaint = paintingStyle_Glasspaint
        self.scene_Glasspaint = scene_Glasspaint
        self.carrier_Glasspaint = carrier_Glasspaint
        self.replicationRate_Glasspaint = replicationRate_Glasspaint
        self.createdDate_Glasspaint = createdDate_Glasspaint
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Glasspaint: NSObject, Codable {
    
    /// 用户ID
    var userId_Glasspaint: Int?
    
    /// 用户密码
    var userPwd_Glasspaint: String?
    
    /// 用户名称
    var userName_Glasspaint: String?
    
    /// 用户头像
    var userHead_Glasspaint: String?
    
    /// 用户发布帖子列表
    var userPosts_Glasspaint: [TitleModel_Glasspaint]
    
    /// 用户喜欢帖子列表
    var userLike_Glasspaint: [TitleModel_Glasspaint]

    /// 用户关注列表
    var userFollow_Glasspaint: [PrewUserModel_Glasspaint]
    
    // MARK: - 彩绘相关属性
    
    /// 用户彩绘水平
    var paintingLevel_Glasspaint: PaintingLevel_Glasspaint
    
    /// 偏好风格列表
    var preferredStyles_Glasspaint: [PaintingStyle_Glasspaint]
    
    /// 创作场景偏好
    var preferredScenes_Glasspaint: [String]
    
    /// 成长数据
    var growthData_Glasspaint: GrowthData_Glasspaint
    
    /// 初始化
    init(userId_Glasspaint: Int? = nil,
         userPwd_Glasspaint: String? = nil,
         userName_Glasspaint: String? = nil,
         userHead_Glasspaint: String? = nil,
         userPosts_Glasspaint: [TitleModel_Glasspaint],
         userLike_Glasspaint: [TitleModel_Glasspaint],
         userFollow_Glasspaint: [PrewUserModel_Glasspaint],
         paintingLevel_Glasspaint: PaintingLevel_Glasspaint = .beginner_glasspaint,
         preferredStyles_Glasspaint: [PaintingStyle_Glasspaint] = [.modern_glasspaint],
         preferredScenes_Glasspaint: [String] = ["Home Decoration"],
         growthData_Glasspaint: GrowthData_Glasspaint = GrowthData_Glasspaint()) {
        self.userId_Glasspaint = userId_Glasspaint
        self.userPwd_Glasspaint = userPwd_Glasspaint
        self.userName_Glasspaint = userName_Glasspaint
        self.userHead_Glasspaint = userHead_Glasspaint
        self.userPosts_Glasspaint = userPosts_Glasspaint
        self.userLike_Glasspaint = userLike_Glasspaint
        self.userFollow_Glasspaint = userFollow_Glasspaint
        self.paintingLevel_Glasspaint = paintingLevel_Glasspaint
        self.preferredStyles_Glasspaint = preferredStyles_Glasspaint
        self.preferredScenes_Glasspaint = preferredScenes_Glasspaint
        self.growthData_Glasspaint = growthData_Glasspaint
    }
}

/// 消息数据模型
class MessageModel_Glasspaint: Codable {
    
    /// 消息ID
    var messageId_Glasspaint: Int?
    
    /// 消息内容
    var content_Glasspaint: String?
    
    /// 用户头像
    var userHead_Glasspaint: String?
    
    /// 是否是我发送的
    var isMine_Glasspaint: Bool?
    
    /// 消息时间
    var time_Glasspaint: String?
    
    /// 初始化
    init(messageId_glasspaint: Int? = nil,
         content_glasspaint: String? = nil,
         userHead_glasspaint: String? = nil,
         isMine_glasspaint: Bool? = nil,
         time_glasspaint: String? = nil) {
        self.messageId_Glasspaint = messageId_glasspaint
        self.content_Glasspaint = content_glasspaint
        self.userHead_Glasspaint = userHead_glasspaint
        self.isMine_Glasspaint = isMine_glasspaint
        self.time_Glasspaint = time_glasspaint
    }
}

/// 评论模型
class Comment_Glasspaint: NSObject, Codable {
    
    /// 评论ID
    var commentId_Glasspaint: Int
    
    /// 评论用户uid
    var commentUserId_Glasspaint: Int
    
    /// 评论用户昵称
    var commentUserName_Glasspaint: String
    
    /// 评论内容
    var commentContent_Glasspaint: String
    
    /// 初始化
    init(commentId_Glasspaint: Int,
         commentUserId_Glasspaint: Int,
         commentUserName_Glasspaint: String,
         commentContent_Glasspaint: String) {
        self.commentId_Glasspaint = commentId_Glasspaint
        self.commentUserId_Glasspaint = commentUserId_Glasspaint
        self.commentUserName_Glasspaint = commentUserName_Glasspaint
        self.commentContent_Glasspaint = commentContent_Glasspaint
    }
}

/// 成长数据模型
/// 功能：记录用户的彩绘技能成长数据
class GrowthData_Glasspaint: NSObject, Codable {
    
    /// 线条流畅度评分（0-100）
    var lineSmoothnessScore_Glasspaint: Double
    
    /// 色彩搭配评分（0-100）
    var colorMatchingScore_Glasspaint: Double
    
    /// 技法提升评分（0-100）
    var techniqueScore_Glasspaint: Double
    
    /// 月度进步曲线（月份 -> 综合评分）
    var monthlyProgress_Glasspaint: [String: Double]
    
    /// 初始化
    init(lineSmoothnessScore_glasspaint: Double = 0,
         colorMatchingScore_glasspaint: Double = 0,
         techniqueScore_glasspaint: Double = 0,
         monthlyProgress_glasspaint: [String: Double] = [:]) {
        self.lineSmoothnessScore_Glasspaint = lineSmoothnessScore_glasspaint
        self.colorMatchingScore_Glasspaint = colorMatchingScore_glasspaint
        self.techniqueScore_Glasspaint = techniqueScore_glasspaint
        self.monthlyProgress_Glasspaint = monthlyProgress_glasspaint
        super.init()
    }
}

/// 挑战模型
/// 功能：定义官方发起的彩绘挑战活动
class ChallengeModel_Glasspaint: NSObject, Codable {
    
    /// 挑战ID
    var challengeId_Glasspaint: Int
    
    /// 载体类型
    var carrier_Glasspaint: CarrierType_Glasspaint
    
    /// 挑战标题
    var challengeTitle_Glasspaint: String
    
    /// 挑战描述
    var challengeDescription_Glasspaint: String
    
    /// 参与人数
    var participantCount_Glasspaint: Int
    
    /// 相关作品列表
    var posts_Glasspaint: [TitleModel_Glasspaint]
    
    /// 开始时间
    var startDate_Glasspaint: Date
    
    /// 结束时间
    var endDate_Glasspaint: Date
    
    /// 初始化
    init(challengeId_Glasspaint: Int,
         carrier_Glasspaint: CarrierType_Glasspaint,
         challengeTitle_Glasspaint: String,
         challengeDescription_Glasspaint: String,
         participantCount_Glasspaint: Int,
         posts_Glasspaint: [TitleModel_Glasspaint],
         startDate_Glasspaint: Date,
         endDate_Glasspaint: Date) {
        self.challengeId_Glasspaint = challengeId_Glasspaint
        self.carrier_Glasspaint = carrier_Glasspaint
        self.challengeTitle_Glasspaint = challengeTitle_Glasspaint
        self.challengeDescription_Glasspaint = challengeDescription_Glasspaint
        self.participantCount_Glasspaint = participantCount_Glasspaint
        self.posts_Glasspaint = posts_Glasspaint
        self.startDate_Glasspaint = startDate_Glasspaint
        self.endDate_Glasspaint = endDate_Glasspaint
        super.init()
    }
}
