import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Doze {
    /// ID起始值
    static let userIdStart_Doze = 10
    static let postIdStart_Doze = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Doze = 2
}

/// 本地数据管理类
class LocalData_Doze {
    
    /// 单例
    static let shared_Doze = LocalData_Doze()
    
    /// 用户列表
    var userList_Doze: [PrewUserModel_Doze] = []
    
    /// 帖子列表
    var titleList_Doze: [TitleModel_Doze] = []
    
    /// 数据生成器
    private lazy var generator_Doze: DataGenerator_Doze = {
        return DataGenerator_Doze(dataLocal_doze: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Doze() {
        generator_Doze.initUsers_Doze()
        generator_Doze.initPosts_Doze()
        generator_Doze.setUserLikes_Doze()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Doze(userId_doze: Int) -> [TitleModel_Doze] {
        return titleList_Doze.filter { $0.titleUserId_Doze != userId_doze }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Doze(postAuthorUserId_doze: Int) -> [PrewUserModel_Doze] {
        return userList_Doze.filter { $0.userId_Doze != postAuthorUserId_doze }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Doze {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Doze: [(String, String, String, String)] = [
        ("EmberSeeker", "Love exploring around bonfires", "user_head_1", "user_album_1"),
        ("ForestWhisper", "Nature enthusiast and storyteller", "user_head_2", "user_album_2"),
        ("FlameJumper", "Adventure seeker and fire dancer", "user_head_3", "user_album_3"),
        ("AshesToArt", "Turning moments into memories", "user_head_4", "user_album_4"),
        ("NightGlow", "Capturing the magic of firelight", "user_head_5", "user_album_5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Doze: [(String, String, String)] = [
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
    static let comments_Doze: [(String, String)] = [
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
private struct RandomUtil_Doze {
    
    /// 生成指定范围的随机整数
    static func nextInt_Doze(min_doze: Int, range_doze: Int) -> Int {
        return Int.random(in: min_doze..<(min_doze + range_doze))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Doze<T>(from list_doze: [T], count_doze: Int) -> [T] {
        guard !list_doze.isEmpty else { return [] }
        guard list_doze.count > count_doze else { return list_doze }
        
        var selected_doze: [T] = []
        var indices_doze: Set<Int> = []
        
        while selected_doze.count < count_doze && indices_doze.count < list_doze.count {
            let index_doze = Int.random(in: 0..<list_doze.count)
            if !indices_doze.contains(index_doze) {
                indices_doze.insert(index_doze)
                selected_doze.append(list_doze[index_doze])
            }
        }
        
        return selected_doze
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Doze {
    
    private weak var dataLocal_Doze: LocalData_Doze?
    
    init(dataLocal_doze: LocalData_Doze) {
        self.dataLocal_Doze = dataLocal_doze
    }
    
    /// 初始化生成用户数据
    func initUsers_Doze() {
        guard let dataLocal_doze = dataLocal_Doze else { return }
        dataLocal_doze.userList_Doze.removeAll()
        
        for (index_doze, userInfo_doze) in DataSource_Doze.usersInfo_Doze.enumerated() {
            let (username_doze, introduce_doze, userHead_doze, userAlbum_doze) = userInfo_doze
            
            let user_doze = PrewUserModel_Doze()
            user_doze.userId_Doze = index_doze + DataConfig_Doze.userIdStart_Doze
            user_doze.userName_Doze = username_doze
            user_doze.userIntroduce_Doze = introduce_doze
            user_doze.userHead_Doze = userHead_doze
            user_doze.userMedia_Doze = [userAlbum_doze]
            user_doze.userLike_Doze = []
            user_doze.userFollow_Doze = 15 + Int.random(in: 1...50)
            user_doze.userFans_Doze = 20 + Int.random(in: 1...50)
            
            dataLocal_doze.userList_Doze.append(user_doze)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Doze() {
        guard let dataLocal_doze = dataLocal_Doze else { return }
        dataLocal_doze.titleList_Doze.removeAll()
        
        for (index_doze, postInfo_doze) in DataSource_Doze.postsInfo_Doze.enumerated() {
            let (title_doze, content_doze, media_doze) = postInfo_doze
            
            // 循环分配作者
            let authorIndex_doze = index_doze % dataLocal_doze.userList_Doze.count
            guard authorIndex_doze < dataLocal_doze.userList_Doze.count else { continue }
            let author_doze = dataLocal_doze.userList_Doze[authorIndex_doze]
            
            // 生成评论
            let comments_doze = generateComments_Doze(
                postIndex_doze: index_doze,
                postAuthorUserId_doze: author_doze.userId_Doze ?? 0
            )
            
            // 创建帖子
            let post_doze = TitleModel_Doze(
                titleId_Doze: index_doze + DataConfig_Doze.postIdStart_Doze,
                titleUserId_Doze: author_doze.userId_Doze ?? 0,
                titleUserName_Doze: author_doze.userName_Doze ?? "",
                titleMeidas_Doze: [media_doze],
                title_Doze: title_doze,
                titleContent_Doze: content_doze,
                reviews_Doze: comments_doze,
                likes_Doze: RandomUtil_Doze.nextInt_Doze(min_doze: 10, range_doze: 150)
            )
            
            dataLocal_doze.titleList_Doze.append(post_doze)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Doze(postIndex_doze: Int, postAuthorUserId_doze: Int) -> [Comment_Doze] {
        guard let dataLocal_doze = dataLocal_Doze else { return [] }
        
        let availableUsers_doze = dataLocal_doze.getAvailableCommenters_Doze(postAuthorUserId_doze: postAuthorUserId_doze)
        guard availableUsers_doze.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_doze = availableUsers_doze[postIndex_doze % availableUsers_doze.count]
        let commenter2_doze = availableUsers_doze[(postIndex_doze + 1) % availableUsers_doze.count]
        
        // 获取评论内容
        let commentIndex_doze = postIndex_doze % DataSource_Doze.comments_Doze.count
        let (comment1_doze, comment2_doze) = DataSource_Doze.comments_Doze[commentIndex_doze]
        
        return [
            Comment_Doze(
                commentId_Doze: postIndex_doze * 2 + 1,
                commentUserId_Doze: commenter1_doze.userId_Doze ?? 0,
                commentUserName_Doze: commenter1_doze.userName_Doze ?? "",
                commentContent_Doze: comment1_doze
            ),
            Comment_Doze(
                commentId_Doze: postIndex_doze * 2 + 2,
                commentUserId_Doze: commenter2_doze.userId_Doze ?? 0,
                commentUserName_Doze: commenter2_doze.userName_Doze ?? "",
                commentContent_Doze: comment2_doze
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Doze() {
        guard let dataLocal_doze = dataLocal_Doze else { return }
        
        for i_doze in 0..<dataLocal_doze.userList_Doze.count {
            let user_doze = dataLocal_doze.userList_Doze[i_doze]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_doze = dataLocal_doze.getPostsExcludingUser_Doze(
                userId_doze: user_doze.userId_Doze ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_doze = RandomUtil_Doze.selectRandomItems_Doze(
                from: availablePosts_doze,
                count_doze: DataConfig_Doze.likePostCount_Doze
            )
            
            dataLocal_doze.userList_Doze[i_doze].userLike_Doze = likePosts_doze
        }
    }
}
