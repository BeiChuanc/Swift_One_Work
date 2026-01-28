import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Wanderbell {
    /// ID起始值
    static let userIdStart_Wanderbell = 10
    static let postIdStart_Wanderbell = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Wanderbell = 2
}

/// 本地数据管理类
class LocalData_Wanderbell {
    
    /// 单例
    static let shared_Wanderbell = LocalData_Wanderbell()
    
    /// 用户列表
    var userList_Wanderbell: [PrewUserModel_Wanderbell] = []
    
    /// 帖子列表
    var titleList_Wanderbell: [TitleModel_Wanderbell] = []
    
    /// 数据生成器
    private lazy var generator_Wanderbell: DataGenerator_Wanderbell = {
        return DataGenerator_Wanderbell(dataLocal_wanderbell: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Wanderbell() {
        generator_Wanderbell.initUsers_Wanderbell()
        generator_Wanderbell.initPosts_Wanderbell()
        generator_Wanderbell.setUserLikes_Wanderbell()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Wanderbell(userId_wanderbell: Int) -> [TitleModel_Wanderbell] {
        return titleList_Wanderbell.filter { $0.titleUserId_Wanderbell != userId_wanderbell }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Wanderbell(postAuthorUserId_wanderbell: Int) -> [PrewUserModel_Wanderbell] {
        return userList_Wanderbell.filter { $0.userId_Wanderbell != postAuthorUserId_wanderbell }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Wanderbell {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Wanderbell: [(String, String, String, String)] = [
        ("EmberSeeker", "Love exploring around bonfires", "user_head_1", "user_album_1"),
        ("ForestWhisper", "Nature enthusiast and storyteller", "user_head_2", "user_album_2"),
        ("FlameJumper", "Adventure seeker and fire dancer", "user_head_3", "user_album_3"),
        ("AshesToArt", "Turning moments into memories", "user_head_4", "user_album_4"),
        ("NightGlow", "Capturing the magic of firelight", "user_head_5", "user_album_5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Wanderbell: [(String, String, String)] = [
        ("Perfect Bonfire Night", "The bonfire crackles softly, wrapping every face in warm light; we pass around s'mores, and stories flow as freely as the laughter. This is the kind of night that stays with you long after the embers fade.", "post_media_1"),
        ("Magical Firelight", "There's something magical about firelight—it turns ordinary moments into treasures. Sitting here, feeling the warmth on my hands and listening to friends chat, I realize happiness is just this simple.", "post_media_2"),
        ("Dancing Flames", "The flames dance and flicker, casting gentle shadows on the grass. No loud noises, no rush—just the glow of fire, the breeze, and people who make the night feel like home.", "post_media_3"),
        ("Warm Hearts", "As the night grows darker, the bonfire burns brighter. It's not just the fire that warms us, but the company, the shared smiles, and the quiet connection between every heart here.", "post_media_4"),
        ("Glowing Memories", "Look at this glowing fire and the grinning faces around it—this is what good nights are made of! Tag the person you'd drag to sit with you by such a bonfire.", "post_media_5"),
        ("Absolute Perfection", "Last night's bonfire was absolute perfection: great friends, crispy marshmallows, and a fire that burned steady till midnight. Who's got a bonfire story to top this?", "post_media_6"),
        ("Fire Family", "I used to think bonfires were just about fire, but now I know it's about the people. This crew turned a simple fire into an unforgettable night.", "post_media_7"),
        ("Fun Activities", "We spent hours around this bonfire: singing off-key, playing silly games, and even debating whether the fire is orange or red. What's your go-to bonfire activity?", "post_media_8"),
        ("Stars and Fire", "Above us, the sky is dotted with stars; below us, the bonfire paints the night in warm hues. The universe feels so big, yet this little circle of fire and friends makes everything feel so close.", "post_media_9"),
        ("Peaceful Embers", "Embers drift up like tiny fireflies, mixing with the stars in the dark. I sit here, quiet, and let the warmth seep into my bones—this is the peace I've been craving.", "post_media_10"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Wanderbell: [(String, String)] = [
        ("This looks absolutely magical! Nothing beats a bonfire with good friends", "S'mores and stories by the fire—that's the perfect night right there!"),
        ("You captured the essence of what makes bonfires special! Love this vibe", "The simplicity of firelight and friendship is truly magical. Beautiful moment!"),
        ("Those dancing flames and peaceful vibes—I can feel the warmth through the screen!", "This is exactly what I needed to see today. Time to plan a bonfire night!"),
        ("The connection between hearts around a fire is something special. Beautifully said!", "Love how you describe the warmth coming from both the fire and the company"),
        ("Already know who I'd tag for this! Nothing beats bonfire nights with the right people", "First thing I'd share? Probably my terrible ghost stories! Who's with me?"),
        ("Our bonfire story: We accidentally used green wood and it wouldn't stop smoking!", "Crispy marshmallows till midnight sounds perfect! Need to organize one soon"),
        ("Your fire family sounds amazing! Count me in for round two", "It really is all about the people. The fire is just an excuse to gather!"),
        ("Off-key singing is mandatory at our bonfires too! Also love the fire color debate", "My go-to activity: trying to roast the perfect marshmallow"),
        ("The stars above and fire below—this is poetry in real life!", "That feeling of the universe being big yet feeling so close... perfectly captured!"),
        ("The embers mixing with stars is such a beautiful image. Pure peace", "Sometimes we just need warmth seeping into our bones and quiet moments"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Wanderbell {
    
    /// 生成指定范围的随机整数
    static func nextInt_Wanderbell(min_wanderbell: Int, range_wanderbell: Int) -> Int {
        return Int.random(in: min_wanderbell..<(min_wanderbell + range_wanderbell))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Wanderbell<T>(from list_wanderbell: [T], count_wanderbell: Int) -> [T] {
        guard !list_wanderbell.isEmpty else { return [] }
        guard list_wanderbell.count > count_wanderbell else { return list_wanderbell }
        
        var selected_wanderbell: [T] = []
        var indices_wanderbell: Set<Int> = []
        
        while selected_wanderbell.count < count_wanderbell && indices_wanderbell.count < list_wanderbell.count {
            let index_wanderbell = Int.random(in: 0..<list_wanderbell.count)
            if !indices_wanderbell.contains(index_wanderbell) {
                indices_wanderbell.insert(index_wanderbell)
                selected_wanderbell.append(list_wanderbell[index_wanderbell])
            }
        }
        
        return selected_wanderbell
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Wanderbell {
    
    private weak var dataLocal_Wanderbell: LocalData_Wanderbell?
    
    init(dataLocal_wanderbell: LocalData_Wanderbell) {
        self.dataLocal_Wanderbell = dataLocal_wanderbell
    }
    
    /// 初始化生成用户数据
    func initUsers_Wanderbell() {
        guard let dataLocal_wanderbell = dataLocal_Wanderbell else { return }
        dataLocal_wanderbell.userList_Wanderbell.removeAll()
        
        for (index_wanderbell, userInfo_wanderbell) in DataSource_Wanderbell.usersInfo_Wanderbell.enumerated() {
            let (username_wanderbell, introduce_wanderbell, userHead_wanderbell, userAlbum_wanderbell) = userInfo_wanderbell
            
            let user_wanderbell = PrewUserModel_Wanderbell()
            user_wanderbell.userId_Wanderbell = index_wanderbell + DataConfig_Wanderbell.userIdStart_Wanderbell
            user_wanderbell.userName_Wanderbell = username_wanderbell
            user_wanderbell.userIntroduce_Wanderbell = introduce_wanderbell
            user_wanderbell.userHead_Wanderbell = userHead_wanderbell
            user_wanderbell.userMedia_Wanderbell = [userAlbum_wanderbell]
            user_wanderbell.userLike_Wanderbell = []
            
            dataLocal_wanderbell.userList_Wanderbell.append(user_wanderbell)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Wanderbell() {
        guard let dataLocal_wanderbell = dataLocal_Wanderbell else { return }
        dataLocal_wanderbell.titleList_Wanderbell.removeAll()
        
        for (index_wanderbell, postInfo_wanderbell) in DataSource_Wanderbell.postsInfo_Wanderbell.enumerated() {
            let (title_wanderbell, content_wanderbell, media_wanderbell) = postInfo_wanderbell
            
            // 循环分配作者
            let authorIndex_wanderbell = index_wanderbell % dataLocal_wanderbell.userList_Wanderbell.count
            guard authorIndex_wanderbell < dataLocal_wanderbell.userList_Wanderbell.count else { continue }
            let author_wanderbell = dataLocal_wanderbell.userList_Wanderbell[authorIndex_wanderbell]
            
            // 生成评论
            let comments_wanderbell = generateComments_Wanderbell(
                postIndex_wanderbell: index_wanderbell,
                postAuthorUserId_wanderbell: author_wanderbell.userId_Wanderbell ?? 0
            )
            
            // 创建帖子
            let post_wanderbell = TitleModel_Wanderbell(
                titleId_Wanderbell: index_wanderbell + DataConfig_Wanderbell.postIdStart_Wanderbell,
                titleUserId_Wanderbell: author_wanderbell.userId_Wanderbell ?? 0,
                titleUserName_Wanderbell: author_wanderbell.userName_Wanderbell ?? "",
                titleMeidas_Wanderbell: [media_wanderbell],
                title_Wanderbell: title_wanderbell,
                titleContent_Wanderbell: content_wanderbell,
                reviews_Wanderbell: comments_wanderbell,
                likes_Wanderbell: RandomUtil_Wanderbell.nextInt_Wanderbell(min_wanderbell: 10, range_wanderbell: 150)
            )
            
            dataLocal_wanderbell.titleList_Wanderbell.append(post_wanderbell)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Wanderbell(postIndex_wanderbell: Int, postAuthorUserId_wanderbell: Int) -> [Comment_Wanderbell] {
        guard let dataLocal_wanderbell = dataLocal_Wanderbell else { return [] }
        
        let availableUsers_wanderbell = dataLocal_wanderbell.getAvailableCommenters_Wanderbell(postAuthorUserId_wanderbell: postAuthorUserId_wanderbell)
        guard availableUsers_wanderbell.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_wanderbell = availableUsers_wanderbell[postIndex_wanderbell % availableUsers_wanderbell.count]
        let commenter2_wanderbell = availableUsers_wanderbell[(postIndex_wanderbell + 1) % availableUsers_wanderbell.count]
        
        // 获取评论内容
        let commentIndex_wanderbell = postIndex_wanderbell % DataSource_Wanderbell.comments_Wanderbell.count
        let (comment1_wanderbell, comment2_wanderbell) = DataSource_Wanderbell.comments_Wanderbell[commentIndex_wanderbell]
        
        return [
            Comment_Wanderbell(
                commentId_Wanderbell: postIndex_wanderbell * 2 + 1,
                commentUserId_Wanderbell: commenter1_wanderbell.userId_Wanderbell ?? 0,
                commentUserName_Wanderbell: commenter1_wanderbell.userName_Wanderbell ?? "",
                commentContent_Wanderbell: comment1_wanderbell
            ),
            Comment_Wanderbell(
                commentId_Wanderbell: postIndex_wanderbell * 2 + 2,
                commentUserId_Wanderbell: commenter2_wanderbell.userId_Wanderbell ?? 0,
                commentUserName_Wanderbell: commenter2_wanderbell.userName_Wanderbell ?? "",
                commentContent_Wanderbell: comment2_wanderbell
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Wanderbell() {
        guard let dataLocal_wanderbell = dataLocal_Wanderbell else { return }
        
        for i_wanderbell in 0..<dataLocal_wanderbell.userList_Wanderbell.count {
            let user_wanderbell = dataLocal_wanderbell.userList_Wanderbell[i_wanderbell]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_wanderbell = dataLocal_wanderbell.getPostsExcludingUser_Wanderbell(
                userId_wanderbell: user_wanderbell.userId_Wanderbell ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_wanderbell = RandomUtil_Wanderbell.selectRandomItems_Wanderbell(
                from: availablePosts_wanderbell,
                count_wanderbell: DataConfig_Wanderbell.likePostCount_Wanderbell
            )
            
            dataLocal_wanderbell.userList_Wanderbell[i_wanderbell].userLike_Wanderbell = likePosts_wanderbell
        }
    }
}
