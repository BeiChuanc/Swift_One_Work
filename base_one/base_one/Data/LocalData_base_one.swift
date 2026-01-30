import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Base_one {
    /// ID起始值
    static let userIdStart_Base_one = 10
    static let postIdStart_Base_one = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Base_one = 2
}

/// 本地数据管理类
class LocalData_Base_one {
    
    /// 单例
    static let shared_Base_one = LocalData_Base_one()
    
    /// 用户列表
    var userList_Base_one: [PrewUserModel_Base_one] = []
    
    /// 帖子列表
    var titleList_Base_one: [TitleModel_Base_one] = []
    
    /// 数据生成器
    private lazy var generator_Base_one: DataGenerator_Base_one = {
        return DataGenerator_Base_one(dataLocal_base_one: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Base_one() {
        generator_Base_one.initUsers_Base_one()
        generator_Base_one.initPosts_Base_one()
        generator_Base_one.setUserLikes_Base_one()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Base_one(userId_base_one: Int) -> [TitleModel_Base_one] {
        return titleList_Base_one.filter { $0.titleUserId_Base_one != userId_base_one }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Base_one(postAuthorUserId_base_one: Int) -> [PrewUserModel_Base_one] {
        return userList_Base_one.filter { $0.userId_Base_one != postAuthorUserId_base_one }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Base_one {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Base_one: [(String, String, String, String)] = [
        ("EmberSeeker", "Love exploring around bonfires", "user_head_1", "user_album_1"),
        ("ForestWhisper", "Nature enthusiast and storyteller", "user_head_2", "user_album_2"),
        ("FlameJumper", "Adventure seeker and fire dancer", "user_head_3", "user_album_3"),
        ("AshesToArt", "Turning moments into memories", "user_head_4", "user_album_4"),
        ("NightGlow", "Capturing the magic of firelight", "user_head_5", "user_album_5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Base_one: [(String, String, String)] = [
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
    static let comments_Base_one: [(String, String)] = [
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
private struct RandomUtil_Base_one {
    
    /// 生成指定范围的随机整数
    static func nextInt_Base_one(min_base_one: Int, range_base_one: Int) -> Int {
        return Int.random(in: min_base_one..<(min_base_one + range_base_one))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Base_one<T>(from list_base_one: [T], count_base_one: Int) -> [T] {
        guard !list_base_one.isEmpty else { return [] }
        guard list_base_one.count > count_base_one else { return list_base_one }
        
        var selected_base_one: [T] = []
        var indices_base_one: Set<Int> = []
        
        while selected_base_one.count < count_base_one && indices_base_one.count < list_base_one.count {
            let index_base_one = Int.random(in: 0..<list_base_one.count)
            if !indices_base_one.contains(index_base_one) {
                indices_base_one.insert(index_base_one)
                selected_base_one.append(list_base_one[index_base_one])
            }
        }
        
        return selected_base_one
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Base_one {
    
    private weak var dataLocal_Base_one: LocalData_Base_one?
    
    init(dataLocal_base_one: LocalData_Base_one) {
        self.dataLocal_Base_one = dataLocal_base_one
    }
    
    /// 初始化生成用户数据
    func initUsers_Base_one() {
        guard let dataLocal_base_one = dataLocal_Base_one else { return }
        dataLocal_base_one.userList_Base_one.removeAll()
        
        for (index_base_one, userInfo_base_one) in DataSource_Base_one.usersInfo_Base_one.enumerated() {
            let (username_base_one, introduce_base_one, userHead_base_one, userAlbum_base_one) = userInfo_base_one
            
            let user_base_one = PrewUserModel_Base_one()
            user_base_one.userId_Base_one = index_base_one + DataConfig_Base_one.userIdStart_Base_one
            user_base_one.userName_Base_one = username_base_one
            user_base_one.userIntroduce_Base_one = introduce_base_one
            user_base_one.userHead_Base_one = userHead_base_one
            user_base_one.userMedia_Base_one = [userAlbum_base_one]
            user_base_one.userLike_Base_one = []
            user_base_one.userFollow_Base_one = 15 + Int.random(in: 1...50)
            user_base_one.userFans_Base_one = 20 + Int.random(in: 1...50)
            
            dataLocal_base_one.userList_Base_one.append(user_base_one)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Base_one() {
        guard let dataLocal_base_one = dataLocal_Base_one else { return }
        dataLocal_base_one.titleList_Base_one.removeAll()
        
        for (index_base_one, postInfo_base_one) in DataSource_Base_one.postsInfo_Base_one.enumerated() {
            let (title_base_one, content_base_one, media_base_one) = postInfo_base_one
            
            // 循环分配作者
            let authorIndex_base_one = index_base_one % dataLocal_base_one.userList_Base_one.count
            guard authorIndex_base_one < dataLocal_base_one.userList_Base_one.count else { continue }
            let author_base_one = dataLocal_base_one.userList_Base_one[authorIndex_base_one]
            
            // 生成评论
            let comments_base_one = generateComments_Base_one(
                postIndex_base_one: index_base_one,
                postAuthorUserId_base_one: author_base_one.userId_Base_one ?? 0
            )
            
            // 创建帖子
            let post_base_one = TitleModel_Base_one(
                titleId_Base_one: index_base_one + DataConfig_Base_one.postIdStart_Base_one,
                titleUserId_Base_one: author_base_one.userId_Base_one ?? 0,
                titleUserName_Base_one: author_base_one.userName_Base_one ?? "",
                titleMeidas_Base_one: [media_base_one],
                title_Base_one: title_base_one,
                titleContent_Base_one: content_base_one,
                reviews_Base_one: comments_base_one,
                likes_Base_one: RandomUtil_Base_one.nextInt_Base_one(min_base_one: 10, range_base_one: 150)
            )
            
            dataLocal_base_one.titleList_Base_one.append(post_base_one)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Base_one(postIndex_base_one: Int, postAuthorUserId_base_one: Int) -> [Comment_Base_one] {
        guard let dataLocal_base_one = dataLocal_Base_one else { return [] }
        
        let availableUsers_base_one = dataLocal_base_one.getAvailableCommenters_Base_one(postAuthorUserId_base_one: postAuthorUserId_base_one)
        guard availableUsers_base_one.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_base_one = availableUsers_base_one[postIndex_base_one % availableUsers_base_one.count]
        let commenter2_base_one = availableUsers_base_one[(postIndex_base_one + 1) % availableUsers_base_one.count]
        
        // 获取评论内容
        let commentIndex_base_one = postIndex_base_one % DataSource_Base_one.comments_Base_one.count
        let (comment1_base_one, comment2_base_one) = DataSource_Base_one.comments_Base_one[commentIndex_base_one]
        
        return [
            Comment_Base_one(
                commentId_Base_one: postIndex_base_one * 2 + 1,
                commentUserId_Base_one: commenter1_base_one.userId_Base_one ?? 0,
                commentUserName_Base_one: commenter1_base_one.userName_Base_one ?? "",
                commentContent_Base_one: comment1_base_one
            ),
            Comment_Base_one(
                commentId_Base_one: postIndex_base_one * 2 + 2,
                commentUserId_Base_one: commenter2_base_one.userId_Base_one ?? 0,
                commentUserName_Base_one: commenter2_base_one.userName_Base_one ?? "",
                commentContent_Base_one: comment2_base_one
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Base_one() {
        guard let dataLocal_base_one = dataLocal_Base_one else { return }
        
        for i_base_one in 0..<dataLocal_base_one.userList_Base_one.count {
            let user_base_one = dataLocal_base_one.userList_Base_one[i_base_one]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_base_one = dataLocal_base_one.getPostsExcludingUser_Base_one(
                userId_base_one: user_base_one.userId_Base_one ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_base_one = RandomUtil_Base_one.selectRandomItems_Base_one(
                from: availablePosts_base_one,
                count_base_one: DataConfig_Base_one.likePostCount_Base_one
            )
            
            dataLocal_base_one.userList_Base_one[i_base_one].userLike_Base_one = likePosts_base_one
        }
    }
}
