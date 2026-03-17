import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Pane {
    /// ID起始值
    static let userIdStart_Pane = 10
    static let postIdStart_Pane = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Pane = 2
}

/// 本地数据管理类
class LocalData_Pane {
    
    /// 单例
    static let shared_Pane = LocalData_Pane()
    
    /// 用户列表
    var userList_Pane: [PrewUserModel_Pane] = []
    
    /// 帖子列表
    var titleList_Pane: [TitleModel_Pane] = []
    
    /// 数据生成器
    private lazy var generator_Pane: DataGenerator_Pane = {
        return DataGenerator_Pane(dataLocal_pane: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Pane() {
        generator_Pane.initUsers_Pane()
        generator_Pane.initPosts_Pane()
        generator_Pane.setUserLikes_Pane()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Pane(userId_pane: Int) -> [TitleModel_Pane] {
        return titleList_Pane.filter { $0.titleUserId_Pane != userId_pane }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Pane(postAuthorUserId_pane: Int) -> [PrewUserModel_Pane] {
        return userList_Pane.filter { $0.userId_Pane != postAuthorUserId_pane }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Pane {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Pane: [(String, String, String, String)] = [
        ("FramedVista", "Every window tells a story worth framing", "head1", "head1"),
        ("GlassGazer", "Collecting views one windowpane at a time", "head2", "head2"),
        ("PaneMoment", "Finding beauty in the world beyond the glass", "head3", "head3"),
        ("WindowWatcher", "Turning ordinary views into extraordinary memories", "head4", "head4"),
        ("SceneSeeker", "Chasing the perfect view from every window", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Pane: [(String, String, String)] = [
        ("Morning Mist Through Glass", "The city wakes in silence behind the glass, wrapped in a soft morning mist. Steam rises from my coffee, mingling with the fog outside the pane. There's a quiet magic in watching the world stir from this side of the window.", "title1"),
        ("City Lights at Dusk", "As the sun slips below the skyline, the city transforms into a canvas of amber and gold. I pressed my face against the cold glass, watching each light flicker on—a constellation born from concrete and steel.", "media_one"),
        ("Rainy Day Reflections", "Rain traces silver paths down the windowpane, bending the world outside into something dreamlike. Every droplet is a tiny lens, capturing a distorted, beautiful version of the street below.", "title3"),
        ("Autumn Colors Framed", "The old maple outside my window has never looked so alive. Crimson, amber, and gold—each gust of wind sends a slow shower of leaves past the glass. Nature has painted the most perfect picture, and all I had to do was look.", "title4"),
        ("Golden Hour Window", "For exactly seventeen minutes, the light turns everything on the other side of the glass into pure gold. The dust motes dance, the rooftops glow, and even the concrete looks like something sacred. I've started setting an alarm just to catch it.", "media_two"),
        ("Snowfall Silhouettes", "By midnight, the world outside my window had gone completely white. The bare branches of the elm tree stood like ink brushstrokes against the pale sky. I sat there for a long time, watching the snow fall in slow, deliberate silence.", "title6"),
        ("Rooftop View Discovery", "I'd lived in this building for two years before I found the rooftop window. The view from up here is completely different—the same city, but from an angle no one below ever sees. Sometimes the best view just needs a new frame.", "title7"),
        ("Night Sky Glimpse", "On clear nights, if I angle myself just right by the east window, I can see a narrow strip of stars between the buildings. It's just a sliver of sky, barely a handful of constellations, but it's mine. That small square of darkness is enough.", "title8"),
        ("Street Life Below", "From four floors up, the street below moves like a slow river. People drift in and out of frame, pigeons hold committee meetings on the awning across the way, and every hour or so, something unexpected passes through. I never tire of this view.", "title9"),
        ("Cloudy Horizon", "The clouds today rolled in like slow thoughts, layering gray upon gray until the horizon disappeared entirely. But there, at the edge of the window frame, a single beam of light broke through—quiet, insistent, and worth every patient moment of waiting.", "media_three"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Pane: [(String, String)] = [
        ("The mist and the glass—such a peaceful way to start the day. Can feel the quiet through this photo", "That blend of coffee steam and morning fog is exactly what slow mornings are made of. Gorgeous frame!"),
        ("The way you captured those city lights through the window is just breathtaking. Pure gold!", "A constellation of concrete and steel—what a way to describe a city at dusk. Love this perspective!"),
        ("Those silver rain trails down the glass... there's something so poetic about how rain changes everything", "Rainy windows are the best lenses—every drop tells its own tiny story. This is beautiful!"),
        ("Your autumn maple view is unreal! I'd never leave that window", "Watching leaves fall past the glass like that sounds like the most peaceful afternoon. Stunning colors!"),
        ("Seventeen minutes of golden light—I love that you track it that carefully. Window magic is real!", "Setting an alarm for golden hour is such a good idea. Glad someone else does this too!"),
        ("Snow-covered branches against a pale sky through the window—this is a winter painting", "That ink-brushstroke description of the elm tree in snow is so perfectly visual. Beautiful quiet!"),
        ("Two years before finding the rooftop window?! Worth the wait though—that view is incredible", "The best views do need a new frame. Love how you put that. This city looks completely different!"),
        ("A sliver of stars between buildings is still a sky worth watching. Love your dedication!", "Knowing exactly which window gives you your star strip at night... that's pure city poetry"),
        ("Watching life unfold from four floors up like a slow river—I completely understand this view love", "The pigeon committee meetings on the awning made me laugh. Window life is the best life!"),
        ("That single beam breaking through the clouds at the edge of the frame is stunning. Worth the wait!", "Patient waiting at a gray window for that one beam of light—this is what slow living looks like"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Pane {
    
    /// 生成指定范围的随机整数
    static func nextInt_Pane(min_pane: Int, range_pane: Int) -> Int {
        return Int.random(in: min_pane..<(min_pane + range_pane))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Pane<T>(from list_pane: [T], count_pane: Int) -> [T] {
        guard !list_pane.isEmpty else { return [] }
        guard list_pane.count > count_pane else { return list_pane }
        
        var selected_pane: [T] = []
        var indices_pane: Set<Int> = []
        
        while selected_pane.count < count_pane && indices_pane.count < list_pane.count {
            let index_pane = Int.random(in: 0..<list_pane.count)
            if !indices_pane.contains(index_pane) {
                indices_pane.insert(index_pane)
                selected_pane.append(list_pane[index_pane])
            }
        }
        
        return selected_pane
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Pane {
    
    private weak var dataLocal_Pane: LocalData_Pane?
    
    init(dataLocal_pane: LocalData_Pane) {
        self.dataLocal_Pane = dataLocal_pane
    }
    
    /// 初始化生成用户数据
    func initUsers_Pane() {
        guard let dataLocal_pane = dataLocal_Pane else { return }
        dataLocal_pane.userList_Pane.removeAll()
        
        for (index_pane, userInfo_pane) in DataSource_Pane.usersInfo_Pane.enumerated() {
            let (username_pane, introduce_pane, userHead_pane, userAlbum_pane) = userInfo_pane
            
            let user_pane = PrewUserModel_Pane()
            user_pane.userId_Pane = index_pane + DataConfig_Pane.userIdStart_Pane
            user_pane.userName_Pane = username_pane
            user_pane.userIntroduce_Pane = introduce_pane
            user_pane.userHead_Pane = userHead_pane
            user_pane.userMedia_Pane = [userAlbum_pane]
            user_pane.userLike_Pane = []
            user_pane.userFollow_Pane = 15 + Int.random(in: 1...50)
            user_pane.userFans_Pane = 20 + Int.random(in: 1...50)
            
            dataLocal_pane.userList_Pane.append(user_pane)
        }
    }
    
    /// 初始化生成帖子数据（含分散在过去 30 天内的伪造日期，用于月度日历展示）
    func initPosts_Pane() {
        guard let dataLocal_pane = dataLocal_Pane else { return }
        dataLocal_pane.titleList_Pane.removeAll()
        
        let dateFormatter_pane = DateFormatter()
        dateFormatter_pane.dateFormat = "yyyy-MM-dd"
        
        for (index_pane, postInfo_pane) in DataSource_Pane.postsInfo_Pane.enumerated() {
            let (title_pane, content_pane, media_pane) = postInfo_pane
            
            // 循环分配作者
            let authorIndex_pane = index_pane % dataLocal_pane.userList_Pane.count
            guard authorIndex_pane < dataLocal_pane.userList_Pane.count else { continue }
            let author_pane = dataLocal_pane.userList_Pane[authorIndex_pane]
            
            // 生成评论
            let comments_pane = generateComments_Pane(
                postIndex_pane: index_pane,
                postAuthorUserId_pane: author_pane.userId_Pane ?? 0
            )
            
            // 帖子日期：以 postId 为种子确定性分散在当月内，保证每次生成结果一致
            let daysAgo_pane = (index_pane * 3) % 30
            let postDate_pane: String
            if let date_pane = Calendar.current.date(
                byAdding: .day,
                value: -daysAgo_pane,
                to: Date()
            ) {
                postDate_pane = dateFormatter_pane.string(from: date_pane)
            } else {
                postDate_pane = dateFormatter_pane.string(from: Date())
            }
            
            // 创建帖子
            let post_pane = TitleModel_Pane(
                titleId_Pane: index_pane + DataConfig_Pane.postIdStart_Pane,
                titleUserId_Pane: author_pane.userId_Pane ?? 0,
                titleUserName_Pane: author_pane.userName_Pane ?? "",
                titleMeidas_Pane: [media_pane],
                title_Pane: title_pane,
                titleContent_Pane: content_pane,
                reviews_Pane: comments_pane,
                likes_Pane: RandomUtil_Pane.nextInt_Pane(min_pane: 10, range_pane: 150),
                titleDate_Pane: postDate_pane
            )
            
            dataLocal_pane.titleList_Pane.append(post_pane)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Pane(postIndex_pane: Int, postAuthorUserId_pane: Int) -> [Comment_Pane] {
        guard let dataLocal_pane = dataLocal_Pane else { return [] }
        
        let availableUsers_pane = dataLocal_pane.getAvailableCommenters_Pane(postAuthorUserId_pane: postAuthorUserId_pane)
        guard availableUsers_pane.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_pane = availableUsers_pane[postIndex_pane % availableUsers_pane.count]
        let commenter2_pane = availableUsers_pane[(postIndex_pane + 1) % availableUsers_pane.count]
        
        // 获取评论内容
        let commentIndex_pane = postIndex_pane % DataSource_Pane.comments_Pane.count
        let (comment1_pane, comment2_pane) = DataSource_Pane.comments_Pane[commentIndex_pane]
        
        return [
            Comment_Pane(
                commentId_Pane: postIndex_pane * 2 + 1,
                commentUserId_Pane: commenter1_pane.userId_Pane ?? 0,
                commentUserName_Pane: commenter1_pane.userName_Pane ?? "",
                commentContent_Pane: comment1_pane
            ),
            Comment_Pane(
                commentId_Pane: postIndex_pane * 2 + 2,
                commentUserId_Pane: commenter2_pane.userId_Pane ?? 0,
                commentUserName_Pane: commenter2_pane.userName_Pane ?? "",
                commentContent_Pane: comment2_pane
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Pane() {
        guard let dataLocal_pane = dataLocal_Pane else { return }
        
        for i_pane in 0..<dataLocal_pane.userList_Pane.count {
            let user_pane = dataLocal_pane.userList_Pane[i_pane]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_pane = dataLocal_pane.getPostsExcludingUser_Pane(
                userId_pane: user_pane.userId_Pane ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_pane = RandomUtil_Pane.selectRandomItems_Pane(
                from: availablePosts_pane,
                count_pane: DataConfig_Pane.likePostCount_Pane
            )
            
            dataLocal_pane.userList_Pane[i_pane].userLike_Pane = likePosts_pane
        }
    }
}
