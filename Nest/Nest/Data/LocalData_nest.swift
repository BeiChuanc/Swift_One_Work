import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Nest {
    /// ID起始值
    static let userIdStart_Nest = 10
    static let postIdStart_Nest = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Nest = 2
}

/// 本地数据管理类
class LocalData_Nest {
    
    /// 单例
    static let shared_Nest = LocalData_Nest()
    
    /// 用户列表
    var userList_Nest: [PrewUserModel_Nest] = []
    
    /// 帖子列表
    var titleList_Nest: [TitleModel_Nest] = []
    
    /// 数据生成器
    private lazy var generator_Nest: DataGenerator_Nest = {
        return DataGenerator_Nest(dataLocal_nest: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Nest() {
        generator_Nest.initUsers_Nest()
        generator_Nest.initPosts_Nest()
        generator_Nest.setUserLikes_Nest()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Nest(userId_nest: Int) -> [TitleModel_Nest] {
        return titleList_Nest.filter { $0.titleUserId_Nest != userId_nest }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Nest(postAuthorUserId_nest: Int) -> [PrewUserModel_Nest] {
        return userList_Nest.filter { $0.userId_Nest != postAuthorUserId_nest }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Nest {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    /// 主题：独居生活爱好者，各有独特的独居品味与生活方式
    static let usersInfo_Nest: [(String, String, String, String)] = [
        ("NestMaker",    "Turning my tiny apartment into a cozy sanctuary, one good find at a time 🏠", "head1", "head1"),
        ("SoloBloom",    "Plant mom, candle collector & proud solo dweller ✨ Life is better with a good diffuser", "head2", "head2"),
        ("QuietCorner",  "Introvert living intentionally. Minimalist finds that spark maximum joy 🌿", "head3", "head3"),
        ("MorningRitual","Espresso, journaling & the perfect desk lamp. Solo mornings are sacred ☕", "head4", "head4"),
        ("CozyHaven",    "Making every square meter count. Solo living isn't lonely—it's a lifestyle 🌙", "head5", "head5"),
    ]

    /// 帖子信息列表 (标题, 内容, 媒体URL)
    /// 主题：独居好物分享、生活打卡，记录独居生活里的小美好
    static let postsInfo_Nest: [(String, String, String)] = [
        (
            "My Sleep Diffuser Changed Everything",
            "Three months ago I couldn't sleep without scrolling for hours. Then I found this ultrasonic diffuser with lavender and cedarwood oil. Now I fill it up, dim my warm lamp, and I'm asleep within 20 minutes. Solo living taught me that a good night routine is the best investment you'll ever make.",
            "title1"
        ),
        (
            "One-Cup Espresso, Maximum Happiness",
            "I resisted buying a mini coffee maker for ages—seemed indulgent for just me. But every morning now I pull a shot, listen to the hum of the machine, and feel genuinely excited about the day ahead. The ritual is the point. You deserve café-quality mornings even when you're dining solo.",
            "title2"
        ),
        (
            "The Foldable Storage Box That Saved My Sanity",
            "Clutter used to make my small space feel suffocating. These Japanese-style fabric boxes folded flat until I needed them, then popped open and slid perfectly under my bed. My room went from chaotic to calm in one afternoon. Solo living means owning your space completely—organize it to feel free.",
            "title3"
        ),
        (
            "Warm Lamp, Warm Evenings",
            "I used to spend evenings under harsh white ceiling light wondering why I felt so restless. Switched to a touch-dimmable 2700K desk lamp and everything changed. Same apartment, same life—but the golden light makes it feel like a different world. Mood lighting isn't a luxury; it's self-care.",
            "media_one"
        ),
        (
            "My Little Succulent Never Judges Me",
            "This tiny echeveria in a cement pot has been my desk companion for eight months. It's asked nothing from me except water every two weeks and a sunny windowsill. In return it's given me something green and alive to look at during long work-from-home days. Zero drama, all growth. 🌱",
            "media_two"
        ),
        (
            "Side-Sleeper Headphones Are Life-Changing",
            "I used to fall asleep to podcasts but the earbuds always fell out or dug into my ear. Found these sleep headphones built into a soft headband—6mm driver, ten-hour battery, and thin enough that I barely feel them. I sleep through the night now. Alone but never lonely when the story is good.",
            "title6"
        ),
        (
            "First Good Find After Moving Out",
            "The week I moved into my first solo apartment I was overwhelmed. Too much silence, too much space to fill. My first good find was a small bluetooth speaker that could fit on my bathroom shelf. Suddenly shower time felt like a concert. That little speaker taught me solo living has its own soundtrack.",
            "title7"
        ),
        (
            "The Desk Setup That Made Me Love Working From Home",
            "Monitor stand + warm lamp + a tiny plant + noise-cancelling headphones. That's my entire setup and I'm more productive than I've ever been in an open office. Curating your own space means curating your own focus. Solo workers, what's your non-negotiable desk essential?",
            "title8"
        ),
        (
            "Night Routine Items I Can't Live Without",
            "1. The diffuser starts 30 min before bed. 2. Chamomile tea in my favorite mug. 3. Reading lamp on lowest setting. 4. Sleep headphones playing rain sounds. By the time I'm done, my small apartment feels like the most peaceful place on earth. Alone at night hits different when you've designed it right.",
            "title4"
        ),
        (
            "Why I Started the Solo Birthday Tradition",
            "Last year on my birthday I ordered my favorite meal, lit every candle I own, and watched my comfort movie alone. It was the best birthday I've ever had. I bought myself a cake with my name on it and felt zero embarrassment. Solo birthdays are an act of radical self-love. Highly recommend.",
            "title5"
        ),
    ]

    /// 评论列表 (评论1, 评论2)
    /// 主题：独居好物社区的真实互动
    static let comments_Nest: [(String, String)] = [
        (
            "This is exactly why I got a diffuser last month! Lavender changed my sleep quality completely 😍",
            "The 20-minute wind-down routine sounds so achievable. Saving this post as motivation!"
        ),
        (
            "One-cup coffee makers are underrated! Fellow solo dwellers deserve barista mornings 100%",
            "The ritual really IS the point. I make tea every morning for the same reason. It grounds me."
        ),
        (
            "Those fabric storage boxes are on my wishlist now. My under-bed space is a nightmare 😅",
            "Calm space = calm mind. You've just convinced me to finally tackle my closet this weekend."
        ),
        (
            "Warm lighting is genuinely transformative. I switched bulbs 6 months ago and never looked back",
            "The golden hour glow indoors is real! Paired mine with some dimmer switches and wow."
        ),
        (
            "Succulents are the perfect solo companions—low maintenance, high visual reward 🌱",
            "Eight months! Goals. Mine always died within two weeks before I discovered the 'ignore it' strategy."
        ),
        (
            "Sleep headphones are the solo living hack nobody talks about enough. They're incredible.",
            "Never lonely with a good audiobook. I've listened to entire series this way falling asleep!"
        ),
        (
            "A bluetooth speaker in the bathroom was MY first solo purchase too! Great minds 🎶",
            "The silence of a new apartment is so loud. Having something that fills it with music is everything."
        ),
        (
            "Monitor stand + warm lamp is the power combo. Added a tiny plant last week and feel 10x more focused",
            "My non-negotiable: noise-cancelling headphones. Productivity doubled when I started using them."
        ),
        (
            "The diffuser + chamomile combo is so powerful. I do the exact same and it's like a reset button.",
            "Designing your own peace is the ultimate solo living skill. Your routine sounds perfect."
        ),
        (
            "Solo birthday with candles and a comfort movie?? This is GOALS. Adding it to my calendar now.",
            "Ordering your own cake is honestly one of the most freeing things you can do. No compromises!"
        ),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Nest {
    
    /// 生成指定范围的随机整数
    static func nextInt_Nest(min_nest: Int, range_nest: Int) -> Int {
        return Int.random(in: min_nest..<(min_nest + range_nest))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Nest<T>(from list_nest: [T], count_nest: Int) -> [T] {
        guard !list_nest.isEmpty else { return [] }
        guard list_nest.count > count_nest else { return list_nest }
        
        var selected_nest: [T] = []
        var indices_nest: Set<Int> = []
        
        while selected_nest.count < count_nest && indices_nest.count < list_nest.count {
            let index_nest = Int.random(in: 0..<list_nest.count)
            if !indices_nest.contains(index_nest) {
                indices_nest.insert(index_nest)
                selected_nest.append(list_nest[index_nest])
            }
        }
        
        return selected_nest
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Nest {
    
    private weak var dataLocal_Nest: LocalData_Nest?
    
    init(dataLocal_nest: LocalData_Nest) {
        self.dataLocal_Nest = dataLocal_nest
    }
    
    /// 初始化生成用户数据
    func initUsers_Nest() {
        guard let dataLocal_nest = dataLocal_Nest else { return }
        dataLocal_nest.userList_Nest.removeAll()
        
        for (index_nest, userInfo_nest) in DataSource_Nest.usersInfo_Nest.enumerated() {
            let (username_nest, introduce_nest, userHead_nest, userAlbum_nest) = userInfo_nest
            
            let user_nest = PrewUserModel_Nest()
            user_nest.userId_Nest = index_nest + DataConfig_Nest.userIdStart_Nest
            user_nest.userName_Nest = username_nest
            user_nest.userIntroduce_Nest = introduce_nest
            user_nest.userHead_Nest = userHead_nest
            user_nest.userMedia_Nest = [userAlbum_nest]
            user_nest.userLike_Nest = []
            user_nest.userFollow_Nest = 15 + Int.random(in: 1...50)
            user_nest.userFans_Nest = 20 + Int.random(in: 1...50)
            
            dataLocal_nest.userList_Nest.append(user_nest)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Nest() {
        guard let dataLocal_nest = dataLocal_Nest else { return }
        dataLocal_nest.titleList_Nest.removeAll()
        
        for (index_nest, postInfo_nest) in DataSource_Nest.postsInfo_Nest.enumerated() {
            let (title_nest, content_nest, media_nest) = postInfo_nest
            
            // 循环分配作者
            let authorIndex_nest = index_nest % dataLocal_nest.userList_Nest.count
            guard authorIndex_nest < dataLocal_nest.userList_Nest.count else { continue }
            let author_nest = dataLocal_nest.userList_Nest[authorIndex_nest]
            
            // 生成评论
            let comments_nest = generateComments_Nest(
                postIndex_nest: index_nest,
                postAuthorUserId_nest: author_nest.userId_Nest ?? 0
            )
            
            // 创建帖子
            let post_nest = TitleModel_Nest(
                titleId_Nest: index_nest + DataConfig_Nest.postIdStart_Nest,
                titleUserId_Nest: author_nest.userId_Nest ?? 0,
                titleUserName_Nest: author_nest.userName_Nest ?? "",
                titleMeidas_Nest: [media_nest],
                title_Nest: title_nest,
                titleContent_Nest: content_nest,
                reviews_Nest: comments_nest,
                likes_Nest: RandomUtil_Nest.nextInt_Nest(min_nest: 10, range_nest: 150)
            )
            
            dataLocal_nest.titleList_Nest.append(post_nest)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Nest(postIndex_nest: Int, postAuthorUserId_nest: Int) -> [Comment_Nest] {
        guard let dataLocal_nest = dataLocal_Nest else { return [] }
        
        let availableUsers_nest = dataLocal_nest.getAvailableCommenters_Nest(postAuthorUserId_nest: postAuthorUserId_nest)
        guard availableUsers_nest.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_nest = availableUsers_nest[postIndex_nest % availableUsers_nest.count]
        let commenter2_nest = availableUsers_nest[(postIndex_nest + 1) % availableUsers_nest.count]
        
        // 获取评论内容
        let commentIndex_nest = postIndex_nest % DataSource_Nest.comments_Nest.count
        let (comment1_nest, comment2_nest) = DataSource_Nest.comments_Nest[commentIndex_nest]
        
        return [
            Comment_Nest(
                commentId_Nest: postIndex_nest * 2 + 1,
                commentUserId_Nest: commenter1_nest.userId_Nest ?? 0,
                commentUserName_Nest: commenter1_nest.userName_Nest ?? "",
                commentContent_Nest: comment1_nest
            ),
            Comment_Nest(
                commentId_Nest: postIndex_nest * 2 + 2,
                commentUserId_Nest: commenter2_nest.userId_Nest ?? 0,
                commentUserName_Nest: commenter2_nest.userName_Nest ?? "",
                commentContent_Nest: comment2_nest
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Nest() {
        guard let dataLocal_nest = dataLocal_Nest else { return }
        
        for i_nest in 0..<dataLocal_nest.userList_Nest.count {
            let user_nest = dataLocal_nest.userList_Nest[i_nest]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_nest = dataLocal_nest.getPostsExcludingUser_Nest(
                userId_nest: user_nest.userId_Nest ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_nest = RandomUtil_Nest.selectRandomItems_Nest(
                from: availablePosts_nest,
                count_nest: DataConfig_Nest.likePostCount_Nest
            )
            
            dataLocal_nest.userList_Nest[i_nest].userLike_Nest = likePosts_nest
        }
    }
}
