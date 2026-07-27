import Foundation
import UIKit

// MARK: 首页数据逻辑类

/// 首页逻辑层
/// 功能：聚合帖子、用户、每日一语等数据，为首页 UI 提供数据源，封装打卡、点赞、问候等操作入口
/// 设计：单例；纯逻辑，不包含任何 UIKit 视图代码，所有数据来源于各 ViewModel / LocalData
class HomeViewModel_Maki {
    
    // MARK: - 单例
    static let shared_Maki = HomeViewModel_Maki()
    private init() {}
    
    // MARK: - 每日一语素材
    
    /// 符合"造物小记"主题的每日励志语
    private let dailyQuotes_Maki: [String] = [
        "Every creation starts with a single spark of curiosity.",
        "Your hands hold the power to turn ideas into reality.",
        "Small creations, big stories — document every moment.",
        "In the art of making, there are no mistakes, only discoveries.",
        "The best journal is the one you make yourself.",
        "Create something today, even if it's just a note.",
        "Every maker has a story worth sharing.",
        "Gather around the fire — great ideas need warmth to grow.",
        "Craft your world, one detail at a time.",
        "The most beautiful things are made with patience and heart."
    ]
    
    // MARK: - 数据属性
    
    /// 轮播帖子：按点赞数降序排列，最多取5条
    var bannerPosts_Maki: [TitleModel_Maki] {
        Array(
            TitleViewModel_Maki.shared_Maki.getPosts_Maki()
                .sorted { $0.likes_Maki > $1.likes_Maki }
                .prefix(5)
        )
    }
    
    /// 推荐创作者：从本地用户列表中取前5名
    var featuredCreators_Maki: [PrewUserModel_Maki] {
        Array(LocalData_Maki.shared_Maki.userList_Maki.prefix(5))
    }
    
    /// 最新帖子：按 ID 降序排列，最多取8条
    var latestPosts_Maki: [TitleModel_Maki] {
        Array(
            TitleViewModel_Maki.shared_Maki.getPosts_Maki()
                .sorted { $0.titleId_Maki > $1.titleId_Maki }
                .prefix(8)
        )
    }
    
    /// 今日每日一语（根据当天日期循环取值）
    var todayQuote_Maki: String {
        let day_maki = Calendar.current.component(.day, from: Date())
        return dailyQuotes_Maki[day_maki % dailyQuotes_Maki.count]
    }
    
    /// 是否已今日打卡
    var hasCheckedIn_Maki: Bool {
        UserViewModel_Maki.shared_Maki.hasCheckedInToday_Maki()
    }
    
    /// 当前登录用户
    var currentUser_Maki: LoginUserModel_Maki {
        UserViewModel_Maki.shared_Maki.getCurrentUser_Maki()
    }
    
    // MARK: - 操作方法
    
    /// 执行每日打卡操作
    func performCheckIn_Maki() {
        UserViewModel_Maki.shared_Maki.checkIn_Maki()
    }
    
    /// 切换帖子点赞状态
    /// - Parameter post_maki: 目标帖子
    func toggleLike_Maki(post_maki: TitleModel_Maki) {
        TitleViewModel_Maki.shared_Maki.likePost_Maki(post_maki: post_maki)
    }
    
    /// 判断当前用户是否已点赞指定帖子
    /// - Parameter post_maki: 目标帖子
    /// - Returns: 是否已点赞
    func isLiked_Maki(post_maki: TitleModel_Maki) -> Bool {
        TitleViewModel_Maki.shared_Maki.isLikedPost_Maki(post_maki: post_maki)
    }
    
    /// 根据用户ID获取用户信息
    /// - Parameter userId_maki: 目标用户ID
    /// - Returns: 用户模型
    func getUserById_Maki(userId_maki: Int) -> PrewUserModel_Maki {
        UserViewModel_Maki.shared_Maki.getUserById_Maki(userId_maki: userId_maki)
    }
    
    /// 根据当前时段和用户名返回英文问候语
    /// - Returns: 含问候语和用户名的字符串
    func greeting_Maki() -> String {
        let hour_maki = Calendar.current.component(.hour, from: Date())
        let name_maki = currentUser_Maki.userName_Maki ?? "Maker"
        switch hour_maki {
        case 5..<12:  return "Good Morning, \(name_maki)"
        case 12..<17: return "Good Afternoon, \(name_maki)"
        case 17..<21: return "Good Evening, \(name_maki)"
        default:      return "Good Night, \(name_maki)"
        }
    }
    
    /// 计算帖子瀑布流所需总高度
    /// - Returns: 高度（含底部 TabBar 安全间距）
    func postsGridHeight_Maki() -> CGFloat {
        let screenW_maki = UIScreen.main.bounds.width
        let itemW_maki   = (screenW_maki - 50) / 2
        let itemH_maki   = itemW_maki * 1.45
        let count_maki   = CGFloat(latestPosts_Maki.count)
        let rows_maki    = ceil(count_maki / 2)
        let spacing_maki: CGFloat = 12
        let bottom_maki: CGFloat  = 100
        return rows_maki * itemH_maki + max(0, rows_maki - 1) * spacing_maki + bottom_maki
    }
}
