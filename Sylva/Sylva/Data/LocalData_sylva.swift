import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Sylva {
    /// ID起始值
    static let userIdStart_Sylva = 10
    static let postIdStart_Sylva = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Sylva = 2
}

/// 本地数据管理类
class LocalData_Sylva {
    
    /// 单例
    static let shared_Sylva = LocalData_Sylva()
    
    /// 用户列表
    var userList_Sylva: [PrewUserModel_Sylva] = []
    
    /// 帖子列表
    var titleList_Sylva: [TitleModel_Sylva] = []
    
    /// 数据生成器
    private lazy var generator_Sylva: DataGenerator_Sylva = {
        return DataGenerator_Sylva(dataLocal_sylva: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Sylva() {
        generator_Sylva.initUsers_Sylva()
        generator_Sylva.initPosts_Sylva()
        generator_Sylva.setUserLikes_Sylva()
    }
    
    /// 生成当日默认任务列表（每次调用返回新实例，用于重置）
    func makeDefaultEcoTasks_Sylva() -> [EcoTask_Sylva] {
        return [
            EcoTask_Sylva(taskId_Sylva: 1,  taskType_Sylva: .publishPost_Sylva,
                          taskTitle_Sylva: "Share a Story",
                          taskDesc_Sylva:  "Publish 1 post about your eco journey",
                          requiredCount_Sylva: 1,  ecoPoints_Sylva: 20,
                          difficulty_Sylva: .hard_Sylva,   iconName_Sylva: "square.and.pencil"),
            EcoTask_Sylva(taskId_Sylva: 2,  taskType_Sylva: .browsePost_Sylva,
                          taskTitle_Sylva: "Explore Stories",
                          taskDesc_Sylva:  "Browse 5 posts from the community",
                          requiredCount_Sylva: 5,  ecoPoints_Sylva: 5,
                          difficulty_Sylva: .easy_Sylva,   iconName_Sylva: "eye.fill"),
            EcoTask_Sylva(taskId_Sylva: 3,  taskType_Sylva: .followUser_Sylva,
                          taskTitle_Sylva: "Connect",
                          taskDesc_Sylva:  "Follow 1 fellow tree planter",
                          requiredCount_Sylva: 1,  ecoPoints_Sylva: 10,
                          difficulty_Sylva: .medium_Sylva, iconName_Sylva: "person.badge.plus"),
            EcoTask_Sylva(taskId_Sylva: 4,  taskType_Sylva: .likePost_Sylva,
                          taskTitle_Sylva: "Spread the Love",
                          taskDesc_Sylva:  "Like 3 posts you find inspiring",
                          requiredCount_Sylva: 3,  ecoPoints_Sylva: 8,
                          difficulty_Sylva: .easy_Sylva,   iconName_Sylva: "heart.fill"),
            EcoTask_Sylva(taskId_Sylva: 5,  taskType_Sylva: .commentPost_Sylva,
                          taskTitle_Sylva: "Engage",
                          taskDesc_Sylva:  "Leave 1 comment to encourage others",
                          requiredCount_Sylva: 1,  ecoPoints_Sylva: 15,
                          difficulty_Sylva: .medium_Sylva, iconName_Sylva: "bubble.left.fill"),
        ]
    }

    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Sylva(userId_sylva: Int) -> [TitleModel_Sylva] {
        return titleList_Sylva.filter { $0.titleUserId_Sylva != userId_sylva }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Sylva(postAuthorUserId_sylva: Int) -> [PrewUserModel_Sylva] {
        return userList_Sylva.filter { $0.userId_Sylva != postAuthorUserId_sylva }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Sylva {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Sylva: [(String, String, String, String)] = [
        ("GreenPioneer",  "Planting trees one root at a time 🌱",              "head1", "head1"),
        ("SylvaKeeper",   "Dedicated to reforesting our beautiful planet 🌍",   "head2", "head2"),
        ("LeafWhisper",   "Every leaf tells a story of hope and renewal 🍃",    "head3", "head3"),
        ("ForestGuardian","Protecting forests for the next generation 🌲",      "head4", "head4"),
        ("RootAndBranch", "Nature heals us. Let's heal nature back 🌿",         "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Sylva: [(String, String, String)] = [
        ("My First Tree Planting Day",
         "Today I planted my very first tree—a young oak sapling in the community park. Digging into the rich earth, I felt connected to something much bigger than myself. One small tree, one giant step for our green future.",
         "title1"),
        ("100 Trees in 30 Days",
         "Our neighborhood group just hit 100 trees planted in a single month! From maple to cherry blossom, every species chosen intentionally. The park already looks more alive. If we can do it, so can your community!",
         "title2"),
        ("Reforestation After the Wildfire",
         "Six months after the fire destroyed 200 acres of forest, our volunteer crew returned with 1,500 seedlings. Watching them take root in the scorched earth is a reminder that life always finds a way back.",
         "title3"),
        ("A Tree for Every Birthday",
         "This year, instead of gifts, I asked my friends to plant a tree for my birthday. We ended up with 18 saplings in three different ecosystems. Best birthday present to the planet I could ask for.",
         "title4"),
        ("Urban Forests Are the Future",
         "Did you know that a single mature tree can absorb 48 lbs of CO₂ per year? Imagine what 10,000 trees could do for a city. Our urban greening project just crossed the 5,000-tree milestone. We're halfway there!",
         "title5"),
        ("Mangrove Restoration Along the Coast",
         "Mangroves protect coastlines, filter water and store more carbon per acre than tropical rainforests. Joined a marine conservation team planting 300 mangrove seedlings today. The tide is quite literally turning.",
         "title6"),
        ("Teaching Kids to Plant Trees",
         "Brought a group of 8-year-olds to our community grove today. Watching their eyes light up as each seedling went into the ground was priceless. We are raising the next generation of forest guardians.",
         "title7"),
        ("The 10-Year Canopy Project",
         "Ten years ago, this hillside was bare. Today it's a thriving woodland with over 3,000 trees. The journey from barren slope to lush canopy proves that patience and persistence pay off in the most beautiful way.",
         "title8"),
        ("Ancient Seeds, New Beginnings",
         "We collected seeds from the oldest oak in our region—estimated to be over 400 years old. Propagating them into 200 new saplings feels like carrying ancient wisdom into the future. A story of continuity across centuries.",
         "title9"),
        ("Climate Action Starts Here",
         "Every tree we plant is a vote for a livable future. It absorbs carbon, provides shade, feeds wildlife, and reminds us that small actions compound into massive change. Start with one tree. Then plant another.",
         "title10"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Sylva: [(String, String)] = [
        ("This is so inspiring! Nothing beats the feeling of digging your hands into soil", "An oak sapling today, a mighty tree in 50 years. You're planting legacy!"),
        ("100 trees in a month is incredible. Your community is an example to all of us!", "The diversity of species really matters—great choices for the ecosystem"),
        ("Post-wildfire reforestation is one of the most powerful things humans can do.", "1,500 seedlings means 1,500 futures growing back from the ashes. Wow."),
        ("This birthday idea is absolutely beautiful. Stealing this concept for next year!", "18 saplings spread across three ecosystems is genuinely brilliant. Love this."),
        ("The CO₂ statistics always blow my mind. Trees are nature's carbon engineers!", "Crossing 5,000 trees is a massive milestone. Cheering you on to 10,000!"),
        ("Mangroves are so underappreciated! Thank you for highlighting their importance.", "This is coastal conservation at its finest. The ocean thanks you!"),
        ("Kids and trees go together perfectly. Future forest guardians right there!", "Environmental education this early makes such a lasting difference. Beautiful."),
        ("A hillside transformed in 10 years—this is what hope looks like in real life.", "From barren to breathtaking. The planet is healing one slope at a time."),
        ("Collecting seeds from a 400-year-old oak is honestly a sacred act.", "Carrying ancient DNA into the future—this is the most poetic thing I've read today."),
        ("Beautifully said. Every tree IS a vote for the future we want to see.", "Small actions, massive compound change. This is the only message that matters."),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Sylva {
    
    /// 生成指定范围的随机整数
    static func nextInt_Sylva(min_sylva: Int, range_sylva: Int) -> Int {
        return Int.random(in: min_sylva..<(min_sylva + range_sylva))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Sylva<T>(from list_sylva: [T], count_sylva: Int) -> [T] {
        guard !list_sylva.isEmpty else { return [] }
        guard list_sylva.count > count_sylva else { return list_sylva }
        
        var selected_sylva: [T] = []
        var indices_sylva: Set<Int> = []
        
        while selected_sylva.count < count_sylva && indices_sylva.count < list_sylva.count {
            let index_sylva = Int.random(in: 0..<list_sylva.count)
            if !indices_sylva.contains(index_sylva) {
                indices_sylva.insert(index_sylva)
                selected_sylva.append(list_sylva[index_sylva])
            }
        }
        
        return selected_sylva
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Sylva {
    
    private weak var dataLocal_Sylva: LocalData_Sylva?
    
    init(dataLocal_sylva: LocalData_Sylva) {
        self.dataLocal_Sylva = dataLocal_sylva
    }
    
    /// 初始化生成用户数据
    func initUsers_Sylva() {
        guard let dataLocal_sylva = dataLocal_Sylva else { return }
        dataLocal_sylva.userList_Sylva.removeAll()
        
        for (index_sylva, userInfo_sylva) in DataSource_Sylva.usersInfo_Sylva.enumerated() {
            let (username_sylva, introduce_sylva, userHead_sylva, userAlbum_sylva) = userInfo_sylva
            
            let user_sylva = PrewUserModel_Sylva()
            user_sylva.userId_Sylva = index_sylva + DataConfig_Sylva.userIdStart_Sylva
            user_sylva.userName_Sylva = username_sylva
            user_sylva.userIntroduce_Sylva = introduce_sylva
            user_sylva.userHead_Sylva = userHead_sylva
            user_sylva.userMedia_Sylva = [userAlbum_sylva]
            user_sylva.userLike_Sylva = []
            user_sylva.userFollow_Sylva = 15 + Int.random(in: 1...50)
            user_sylva.userFans_Sylva = 20 + Int.random(in: 1...50)
            
            dataLocal_sylva.userList_Sylva.append(user_sylva)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Sylva() {
        guard let dataLocal_sylva = dataLocal_Sylva else { return }
        dataLocal_sylva.titleList_Sylva.removeAll()
        
        for (index_sylva, postInfo_sylva) in DataSource_Sylva.postsInfo_Sylva.enumerated() {
            let (title_sylva, content_sylva, media_sylva) = postInfo_sylva
            
            // 循环分配作者
            let authorIndex_sylva = index_sylva % dataLocal_sylva.userList_Sylva.count
            guard authorIndex_sylva < dataLocal_sylva.userList_Sylva.count else { continue }
            let author_sylva = dataLocal_sylva.userList_Sylva[authorIndex_sylva]
            
            // 生成评论
            let comments_sylva = generateComments_Sylva(
                postIndex_sylva: index_sylva,
                postAuthorUserId_sylva: author_sylva.userId_Sylva ?? 0
            )
            
            // 创建帖子
            let post_sylva = TitleModel_Sylva(
                titleId_Sylva: index_sylva + DataConfig_Sylva.postIdStart_Sylva,
                titleUserId_Sylva: author_sylva.userId_Sylva ?? 0,
                titleUserName_Sylva: author_sylva.userName_Sylva ?? "",
                titleMeidas_Sylva: [media_sylva],
                title_Sylva: title_sylva,
                titleContent_Sylva: content_sylva,
                reviews_Sylva: comments_sylva,
                likes_Sylva: RandomUtil_Sylva.nextInt_Sylva(min_sylva: 10, range_sylva: 150)
            )
            
            dataLocal_sylva.titleList_Sylva.append(post_sylva)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Sylva(postIndex_sylva: Int, postAuthorUserId_sylva: Int) -> [Comment_Sylva] {
        guard let dataLocal_sylva = dataLocal_Sylva else { return [] }
        
        let availableUsers_sylva = dataLocal_sylva.getAvailableCommenters_Sylva(postAuthorUserId_sylva: postAuthorUserId_sylva)
        guard availableUsers_sylva.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_sylva = availableUsers_sylva[postIndex_sylva % availableUsers_sylva.count]
        let commenter2_sylva = availableUsers_sylva[(postIndex_sylva + 1) % availableUsers_sylva.count]
        
        // 获取评论内容
        let commentIndex_sylva = postIndex_sylva % DataSource_Sylva.comments_Sylva.count
        let (comment1_sylva, comment2_sylva) = DataSource_Sylva.comments_Sylva[commentIndex_sylva]
        
        return [
            Comment_Sylva(
                commentId_Sylva: postIndex_sylva * 2 + 1,
                commentUserId_Sylva: commenter1_sylva.userId_Sylva ?? 0,
                commentUserName_Sylva: commenter1_sylva.userName_Sylva ?? "",
                commentContent_Sylva: comment1_sylva
            ),
            Comment_Sylva(
                commentId_Sylva: postIndex_sylva * 2 + 2,
                commentUserId_Sylva: commenter2_sylva.userId_Sylva ?? 0,
                commentUserName_Sylva: commenter2_sylva.userName_Sylva ?? "",
                commentContent_Sylva: comment2_sylva
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Sylva() {
        guard let dataLocal_sylva = dataLocal_Sylva else { return }
        
        for i_sylva in 0..<dataLocal_sylva.userList_Sylva.count {
            let user_sylva = dataLocal_sylva.userList_Sylva[i_sylva]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_sylva = dataLocal_sylva.getPostsExcludingUser_Sylva(
                userId_sylva: user_sylva.userId_Sylva ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_sylva = RandomUtil_Sylva.selectRandomItems_Sylva(
                from: availablePosts_sylva,
                count_sylva: DataConfig_Sylva.likePostCount_Sylva
            )
            
            dataLocal_sylva.userList_Sylva[i_sylva].userLike_Sylva = likePosts_sylva
        }
    }
}
