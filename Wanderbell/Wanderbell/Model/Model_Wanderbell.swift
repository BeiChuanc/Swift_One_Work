import Foundation
import UIKit

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Wanderbell: NSObject, Codable {
    
    /// 用户ID
    var userId_Wanderbell: Int?
    
    /// 用户名字
    var userName_Wanderbell: String?
    
    /// 用户简介
    var userIntroduce_Wanderbell: String?
    
    /// 用户头像
    var userHead_Wanderbell: String?
    
    /// 用户媒体
    var userMedia_Wanderbell: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Wanderbell: [TitleModel_Wanderbell] = []

    /// 用户关注数
    var userFollowCount_Wanderbell: Int
    
    /// 用户用户粉丝数
    var userFollowers_Wanderbell: Int
    
    /// 初始化
    override init() {
        self.userFollowCount_Wanderbell = 0
        self.userFollowers_Wanderbell = 0
        super.init()
    }
    
    /// 初始化
    init(userId_Wanderbell: Int? = nil,
         userName_Wanderbell: String? = nil,
         userIntroduce_Wanderbell: String? = nil,
         userHead_Wanderbell: String? = nil,
         userMedia_Wanderbell: [String]? = nil,
         userLike_Wanderbell: [TitleModel_Wanderbell] = [],
         userFollowCount_Wanderbell: Int = 0,
         userFollowers_Wanderbell: Int = 0) {
        self.userId_Wanderbell = userId_Wanderbell
        self.userName_Wanderbell = userName_Wanderbell
        self.userIntroduce_Wanderbell = userIntroduce_Wanderbell
        self.userHead_Wanderbell = userHead_Wanderbell
        self.userMedia_Wanderbell = userMedia_Wanderbell
        self.userLike_Wanderbell = userLike_Wanderbell
        self.userFollowCount_Wanderbell = userFollowCount_Wanderbell
        self.userFollowers_Wanderbell = userFollowers_Wanderbell
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Wanderbell: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Wanderbell: Int
    
    /// 拥有者ID
    var titleUserId_Wanderbell: Int
    
    /// 拥有者昵称
    var titleUserName_Wanderbell: String
    
    /// 帖子媒体
    var titleMeidas_Wanderbell: [String]
    
    /// 帖子标题
    var title_Wanderbell: String
    
    /// 帖子内容
    var titleContent_Wanderbell: String
    
    /// 帖子评论列表
    var reviews_Wanderbell: [Comment_Wanderbell]
    
    /// 喜欢个数
    var likes_Wanderbell: Int
    
    init(titleId_Wanderbell: Int,
         titleUserId_Wanderbell: Int,
         titleUserName_Wanderbell: String,
         titleMeidas_Wanderbell: [String],
         title_Wanderbell: String,
         titleContent_Wanderbell: String,
         reviews_Wanderbell: [Comment_Wanderbell],
         likes_Wanderbell: Int) {
        self.titleId_Wanderbell = titleId_Wanderbell
        self.titleUserId_Wanderbell = titleUserId_Wanderbell
        self.titleUserName_Wanderbell = titleUserName_Wanderbell
        self.titleMeidas_Wanderbell = titleMeidas_Wanderbell
        self.title_Wanderbell = title_Wanderbell
        self.titleContent_Wanderbell = titleContent_Wanderbell
        self.reviews_Wanderbell = reviews_Wanderbell
        self.likes_Wanderbell = likes_Wanderbell
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Wanderbell: NSObject, Codable {
    
    /// 用户ID
    var userId_Wanderbell: Int?
    
    /// 用户密码
    var userPwd_Wanderbell: String?
    
    /// 用户名称
    var userName_Wanderbell: String?
    
    /// 用户头像
    var userHead_Wanderbell: String?
    
    /// 用户发布帖子列表
    var userPosts_Wanderbell: [TitleModel_Wanderbell]
    
    /// 用户喜欢帖子列表
    var userLike_Wanderbell: [TitleModel_Wanderbell]

    /// 用户关注列表
    var userFollow_Wanderbell: [PrewUserModel_Wanderbell]
    
    /// 用户情绪记录列表
    var userEmotionRecords_Wanderbell: [EmotionRecord_Wanderbell]
    
    /// 初始化
    init(userId_Wanderbell: Int? = nil,
         userPwd_Wanderbell: String? = nil,
         userName_Wanderbell: String? = nil,
         userHead_Wanderbell: String? = nil,
         userPosts_Wanderbell: [TitleModel_Wanderbell],
         userLike_Wanderbell: [TitleModel_Wanderbell],
         userFollow_Wanderbell: [PrewUserModel_Wanderbell],
         userEmotionRecords_Wanderbell: [EmotionRecord_Wanderbell] = []) {
        self.userId_Wanderbell = userId_Wanderbell
        self.userPwd_Wanderbell = userPwd_Wanderbell
        self.userName_Wanderbell = userName_Wanderbell
        self.userHead_Wanderbell = userHead_Wanderbell
        self.userPosts_Wanderbell = userPosts_Wanderbell
        self.userLike_Wanderbell = userLike_Wanderbell
        self.userFollow_Wanderbell = userFollow_Wanderbell
        self.userEmotionRecords_Wanderbell = userEmotionRecords_Wanderbell
    }
}

/// 消息数据模型
class MessageModel_Wanderbell: Codable {
    
    /// 消息ID
    var messageId_Wanderbell: Int?
    
    /// 消息内容
    var content_Wanderbell: String?
    
    /// 用户头像
    var userHead_Wanderbell: String?
    
    /// 是否是我发送的
    var isMine_Wanderbell: Bool?
    
    /// 消息时间
    var time_Wanderbell: String?
    
    /// 初始化
    init(messageId_wanderbell: Int? = nil,
         content_wanderbell: String? = nil,
         userHead_wanderbell: String? = nil,
         isMine_wanderbell: Bool? = nil,
         time_wanderbell: String? = nil) {
        self.messageId_Wanderbell = messageId_wanderbell
        self.content_Wanderbell = content_wanderbell
        self.userHead_Wanderbell = userHead_wanderbell
        self.isMine_Wanderbell = isMine_wanderbell
        self.time_Wanderbell = time_wanderbell
    }
}

/// 评论模型
class Comment_Wanderbell: NSObject, Codable {
    
    /// 评论ID
    var commentId_Wanderbell: Int
    
    /// 评论用户uid
    var commentUserId_Wanderbell: Int
    
    /// 评论用户昵称
    var commentUserName_Wanderbell: String
    
    /// 评论内容
    var commentContent_Wanderbell: String
    
    /// 初始化
    init(commentId_Wanderbell: Int,
         commentUserId_Wanderbell: Int,
         commentUserName_Wanderbell: String,
         commentContent_Wanderbell: String) {
        self.commentId_Wanderbell = commentId_Wanderbell
        self.commentUserId_Wanderbell = commentUserId_Wanderbell
        self.commentUserName_Wanderbell = commentUserName_Wanderbell
        self.commentContent_Wanderbell = commentContent_Wanderbell
    }
}

// MARK: 情绪相关数据模型

/// 情绪类型枚举
/// 功能：定义7种基础情绪类型和自定义情绪类型，每种情绪都有对应的颜色和图标
enum EmotionType_Wanderbell: String, Codable {
    case happy_wanderbell = "Happy"
    case calm_wanderbell = "Calm"
    case sad_wanderbell = "Sad"
    case anxious_wanderbell = "Anxious"
    case angry_wanderbell = "Angry"
    case excited_wanderbell = "Excited"
    case tired_wanderbell = "Tired"
    case custom_wanderbell = "Custom"
    
    /// 获取情绪颜色
    /// 功能：返回每种情绪对应的主题颜色
    /// 返回值：UIColor - 情绪颜色
    func getColor_Wanderbell() -> UIColor {
        switch self {
        case .happy_wanderbell: return UIColor(hexstring_Wanderbell: "#F6E05E")  // 阳光黄
        case .calm_wanderbell: return UIColor(hexstring_Wanderbell: "#63B3ED")   // 海洋蓝
        case .sad_wanderbell: return UIColor(hexstring_Wanderbell: "#4A5568")    // 暮色蓝
        case .anxious_wanderbell: return UIColor(hexstring_Wanderbell: "#9F7AEA") // 紫罗兰
        case .angry_wanderbell: return UIColor(hexstring_Wanderbell: "#FC8181")   // 火焰红
        case .excited_wanderbell: return UIColor(hexstring_Wanderbell: "#F6AD55") // 活力橙
        case .tired_wanderbell: return UIColor(hexstring_Wanderbell: "#B794F6")   // 薰衣草
        case .custom_wanderbell: return UIColor(hexstring_Wanderbell: "#B794F6")  // 渐变彩虹色（默认薰衣草）
        }
    }
    
    /// 获取情绪图标（SF Symbols）
    /// 功能：返回每种情绪对应的系统图标名称
    /// 返回值：String - SF Symbols图标名称
    func getIcon_Wanderbell() -> String {
        switch self {
        case .happy_wanderbell: return "sun.max.fill"
        case .calm_wanderbell: return "moon.stars.fill"
        case .sad_wanderbell: return "cloud.rain.fill"
        case .anxious_wanderbell: return "wind"
        case .angry_wanderbell: return "flame.fill"
        case .excited_wanderbell: return "sparkles"
        case .tired_wanderbell: return "zzz"
        case .custom_wanderbell: return "heart.fill"
        }
    }
    
    /// 获取所有基础情绪类型（不包含自定义）
    /// 返回值：[EmotionType_Wanderbell] - 所有基础情绪类型数组
    static func getAllBasicTypes_Wanderbell() -> [EmotionType_Wanderbell] {
        return [.happy_wanderbell, .calm_wanderbell, .sad_wanderbell, 
                .anxious_wanderbell, .angry_wanderbell, .excited_wanderbell, .tired_wanderbell]
    }
}

/// 情绪记录模型
/// 功能：存储用户的情绪记录信息，包括情绪类型、强度、笔记、媒体等
/// 核心属性：情绪类型、强度（1-5）、笔记、时间戳、标签
class EmotionRecord_Wanderbell: NSObject, Codable {
    
    /// 记录ID
    var recordId_Wanderbell: Int
    
    /// 用户ID
    var userId_Wanderbell: Int
    
    /// 情绪类型
    var emotionType_Wanderbell: EmotionType_Wanderbell
    
    /// 自定义情绪名称（仅当emotionType为custom时使用）
    var customEmotion_Wanderbell: String?
    
    /// 情绪强度（1-5，1最低，5最高）
    var intensity_Wanderbell: Int
    
    /// 笔记/日记内容
    var note_Wanderbell: String
    
    /// 媒体文件（图片/视频URL）
    var media_Wanderbell: [String]
    
    /// 时间戳
    var timestamp_Wanderbell: Date
    
    /// 标签列表
    var tags_Wanderbell: [String]
    
    /// 初始化方法
    /// 参数：
    /// - recordId_Wanderbell: 记录ID
    /// - userId_Wanderbell: 用户ID
    /// - emotionType_Wanderbell: 情绪类型
    /// - customEmotion_Wanderbell: 自定义情绪名称（可选）
    /// - intensity_Wanderbell: 强度（1-5）
    /// - note_Wanderbell: 笔记内容
    /// - media_Wanderbell: 媒体文件数组
    /// - timestamp_Wanderbell: 时间戳
    /// - tags_Wanderbell: 标签数组
    init(recordId_Wanderbell: Int, 
         userId_Wanderbell: Int, 
         emotionType_Wanderbell: EmotionType_Wanderbell, 
         customEmotion_Wanderbell: String? = nil,
         intensity_Wanderbell: Int, 
         note_Wanderbell: String, 
         media_Wanderbell: [String], 
         timestamp_Wanderbell: Date, 
         tags_Wanderbell: [String]) {
        self.recordId_Wanderbell = recordId_Wanderbell
        self.userId_Wanderbell = userId_Wanderbell
        self.emotionType_Wanderbell = emotionType_Wanderbell
        self.customEmotion_Wanderbell = customEmotion_Wanderbell
        self.intensity_Wanderbell = intensity_Wanderbell
        self.note_Wanderbell = note_Wanderbell
        self.media_Wanderbell = media_Wanderbell
        self.timestamp_Wanderbell = timestamp_Wanderbell
        self.tags_Wanderbell = tags_Wanderbell
        super.init()
    }
    
    /// 获取情绪显示名称
    /// 功能：如果是自定义情绪则返回自定义名称，否则返回情绪类型的原始值
    /// 返回值：String - 情绪显示名称
    func getEmotionDisplayName_Wanderbell() -> String {
        if emotionType_Wanderbell == .custom_wanderbell, let customName_wanderbell = customEmotion_Wanderbell {
            return customName_wanderbell
        }
        return emotionType_Wanderbell.rawValue
    }
}
