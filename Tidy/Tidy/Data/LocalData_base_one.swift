import Foundation

// MARK: 本地数据存放类 - Tidy 家居整理社区预制数据

/// 数据配置常量
private struct DataConfig_Base_one {
    /// 用户ID起始值
    static let userIdStart_Base_one = 10
    /// 帖子ID起始值
    static let postIdStart_Base_one = 20
    /// 每位用户默认喜欢帖子数
    static let likePostCount_Base_one = 2
}

/// 本地数据管理类
/// 功能：管理预制的用户、帖子及分类数据，作为社区内容的离线数据源
/// 设计思路：单例模式，通过 DataGenerator 延迟初始化各类数据
class LocalData_Base_one {
    
    /// 单例
    static let shared_Base_one = LocalData_Base_one()
    
    /// 用户列表
    var userList_Base_one: [PrewUserModel_Base_one] = []
    
    /// 帖子列表
    var titleList_Base_one: [TitleModel_Base_one] = []
    
    /// 数据生成器（延迟初始化）
    private lazy var generator_Base_one: DataGenerator_Base_one = {
        return DataGenerator_Base_one(dataLocal_base_one: self)
    }()
    
    private init() {}
    
    /// 初始化所有预制数据
    func initData_Base_one() {
        generator_Base_one.initUsers_Base_one()
        generator_Base_one.initPosts_Base_one()
        generator_Base_one.setUserLikes_Base_one()
    }
    
    /// 获取排除指定用户的帖子列表
    /// 参数：
    /// - userId_base_one: 需排除的用户ID
    /// 返回值：过滤后的帖子数组
    func getPostsExcludingUser_Base_one(userId_base_one: Int) -> [TitleModel_Base_one] {
        return titleList_Base_one.filter { $0.titleUserId_Base_one != userId_base_one }
    }
    
    /// 获取可评论的用户列表（排除帖子作者）
    /// 参数：
    /// - postAuthorUserId_base_one: 帖子作者ID
    /// 返回值：可作为评论者的用户数组
    func getAvailableCommenters_Base_one(postAuthorUserId_base_one: Int) -> [PrewUserModel_Base_one] {
        return userList_Base_one.filter { $0.userId_Base_one != postAuthorUserId_base_one }
    }
}

// MARK: - 静态数据源（Tidy 家居主题）

/// 静态数据源 - 家居整理归类主题
private struct DataSource_Base_one {
    
    /// 用户信息列表 (用户名, 简介, 头像标识, 相册标识)
    static let usersInfo_Base_one: [(String, String, String, String)] = [
        ("TidyNest",    "Passionate about creating cozy, organized spaces at home",       "head1", "head1"),
        ("ClutterFree", "Minimalist lifestyle advocate and home organizing enthusiast",    "head2", "head2"),
        ("HomeHaven",   "Transforming chaos into calm, one room at a time",               "head3", "head3"),
        ("NeatNook",    "Budget-friendly home decor and smart storage solutions",         "head4", "head4"),
        ("SpaceGuru",   "Professional organizer sharing tips for a stress-free home",     "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体标识, 分类ID)
    static let postsInfo_Base_one: [(String, String, String, String)] = [
        (
            "Living Room Refresh",
            "Finally tackled the living room clutter! Sorted everything into labeled bins and added floating shelves for the knick-knacks. The key is finding a home for every single item — if it doesn't have a place, it doesn't belong. The space feels so open and breathable now.",
            "title1",
            "living_room"
        ),
        (
            "Bedroom Closet Makeover",
            "Spent the whole weekend reorganizing my wardrobe. Used the KonMari method — kept only things that spark joy. Divided clothes by category and color, added a second hanging rod for shorter items, and finally have a drawer system that actually makes sense. Morning routines are a breeze now!",
            "title2",
            "bedroom"
        ),
        (
            "Kitchen Pantry System",
            "Created a zero-waste pantry system using glass jars and clear labels. Grouped items by frequency of use — daily essentials front and center, seasonal spices in the back. Added pull-out drawer organizers for the deep cabinets. Cooking is genuinely enjoyable when you can find everything instantly.",
            "title3",
            "kitchen"
        ),
        (
            "Bathroom Cabinet Edit",
            "Decluttered three years of half-used products from under the sink. Installed a tiered shelf, drawer dividers, and a magnetic strip for bobby pins and nail files. Every item now has a visible, accessible spot. The morning rush is so much calmer.",
            "title4",
            "bathroom"
        ),
        (
            "Home Study Organization",
            "Transformed my study corner into a productivity powerhouse. Cable management box hides the wire chaos, a pegboard holds frequently used supplies, and a tickler file system keeps documents in order. The most effective change? A single inbox tray — everything lands there first.",
            "title5",
            "study"
        ),
        (
            "Seasonal Storage Solution",
            "Swapped out winter items for summer gear using vacuum storage bags — saved so much closet space! Color-coded bins stack neatly in the top shelf. Each bin has a QR code label that links to a photo inventory on my phone. No more digging through boxes to find what I need.",
            "title6",
            "storage"
        ),
        (
            "Balcony Garden Corner",
            "Turned a cluttered balcony into a mini garden sanctuary. Wall-mounted planter pockets hold herbs, a folding potting table tucks away when not in use, and tool hooks keep gardening gear organized. The garden tools each have their own hook — no more tangled hoses!",
            "title7",
            "garden"
        ),
        (
            "Kitchen Drawer Deep Dive",
            "Emptied every kitchen drawer and started fresh. Bamboo drawer dividers for utensils, a dedicated drawer for food wraps and bags, and a separate zone for appliance manuals. Labeled everything with a label maker. Finding the right tool now takes two seconds, not two minutes.",
            "title8",
            "kitchen"
        ),
        (
            "Kids Room Tidy Hacks",
            "Created a toy rotation system that keeps the bedroom from being overwhelmed. Only one bin of toys accessible at a time — rotate weekly. Used pegboards for art supplies and low hooks for bags and jackets. Kids actually maintain it themselves now!",
            "title9",
            "bedroom"
        ),
        (
            "Entry Hall Declutter",
            "The entry hall sets the tone for the whole home. Added a wall-mounted key holder, a shoe rack that fits exactly four pairs per family member, and a small basket for incoming mail. The 'one in, one out' rule keeps it permanently tidy.",
            "title10",
            "living_room"
        ),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Base_one: [(String, String)] = [
        ("This is exactly what my living room needs! Love the floating shelves idea", "Labeled bins are a game changer — my family finally puts things back where they belong!"),
        ("The KonMari method changed my relationship with stuff too. Great wardrobe system!", "A second hanging rod — why did I never think of that? Trying this weekend for sure."),
        ("Glass jars make everything look so clean and intentional. Inspired to redo my pantry!", "Pull-out organizers for deep cabinets are brilliant. No more losing things in the back."),
        ("That magnetic strip for small items is genius! Stealing this idea immediately", "A tiered shelf under the sink makes such a difference. Bathroom goals right here."),
        ("Cable management is the hidden hero of any tidy workspace. Love the pegboard!", "The inbox tray idea is so simple but so effective. One landing spot changes everything."),
        ("QR code labels for bins?! You're living in the future. I need to try this!", "Vacuum bags are essential for seasonal swaps. Your color-coding system is chef's kiss."),
        ("A potting table that folds away — perfect solution for small balconies!", "Love how every tool has its own hook. The garden looks so peaceful and organized."),
        ("Bamboo dividers over plastic any day! Your drawer zones are so logical", "I spent 10 minutes finding a spatula this morning. Clearly I need this system yesterday."),
        ("The toy rotation idea is revolutionary for parents. Tried it and my kids love the 'new' toys every week!", "Low hooks for independence — teaching kids to tidy up starts with the right setup."),
        ("'One in, one out' in the entry hall is the rule that keeps everything sane", "A shoe rack sized per family member is so smart. No more pile-up at the door!"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成辅助方法
private struct RandomUtil_Base_one {
    
    /// 生成指定范围的随机整数
    /// 参数：
    /// - min_base_one: 最小值（含）
    /// - range_base_one: 范围跨度
    /// 返回值：随机整数
    static func nextInt_Base_one(min_base_one: Int, range_base_one: Int) -> Int {
        return Int.random(in: min_base_one..<(min_base_one + range_base_one))
    }
    
    /// 从列表中随机选择不重复的 N 个元素
    /// 参数：
    /// - list_base_one: 来源数组
    /// - count_base_one: 需要选取的数量
    /// 返回值：选取结果数组
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

// MARK: - 数据生成器

/// 数据生成器
/// 功能：根据静态数据源生成用户、帖子及点赞关联数据
/// 设计思路：与 LocalData 弱引用关联，避免循环引用
class DataGenerator_Base_one {
    
    private weak var dataLocal_Base_one: LocalData_Base_one?
    
    /// 初始化
    /// 参数：
    /// - dataLocal_base_one: 所属 LocalData 实例（弱引用）
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
    
    /// 初始化生成帖子数据（带分类标识）
    func initPosts_Base_one() {
        guard let dataLocal_base_one = dataLocal_Base_one else { return }
        dataLocal_base_one.titleList_Base_one.removeAll()
        
        for (index_base_one, postInfo_base_one) in DataSource_Base_one.postsInfo_Base_one.enumerated() {
            let (title_base_one, content_base_one, media_base_one, category_base_one) = postInfo_base_one
            
            // 循环分配作者
            let authorIndex_base_one = index_base_one % dataLocal_base_one.userList_Base_one.count
            guard authorIndex_base_one < dataLocal_base_one.userList_Base_one.count else { continue }
            let author_base_one = dataLocal_base_one.userList_Base_one[authorIndex_base_one]
            
            // 生成评论
            let comments_base_one = generateComments_Base_one(
                postIndex_base_one: index_base_one,
                postAuthorUserId_base_one: author_base_one.userId_Base_one ?? 0
            )
            
            let post_base_one = TitleModel_Base_one(
                titleId_Base_one: index_base_one + DataConfig_Base_one.postIdStart_Base_one,
                titleUserId_Base_one: author_base_one.userId_Base_one ?? 0,
                titleUserName_Base_one: author_base_one.userName_Base_one ?? "",
                titleMeidas_Base_one: [media_base_one],
                title_Base_one: title_base_one,
                titleContent_Base_one: content_base_one,
                reviews_Base_one: comments_base_one,
                likes_Base_one: RandomUtil_Base_one.nextInt_Base_one(min_base_one: 10, range_base_one: 150),
                titleCategory_Base_one: category_base_one
            )
            
            dataLocal_base_one.titleList_Base_one.append(post_base_one)
        }
    }
    
    /// 为帖子生成评论
    /// 参数：
    /// - postIndex_base_one: 帖子索引
    /// - postAuthorUserId_base_one: 帖子作者ID（排除自评）
    /// 返回值：评论数组
    private func generateComments_Base_one(postIndex_base_one: Int, postAuthorUserId_base_one: Int) -> [Comment_Base_one] {
        guard let dataLocal_base_one = dataLocal_Base_one else { return [] }
        
        let availableUsers_base_one = dataLocal_base_one.getAvailableCommenters_Base_one(
            postAuthorUserId_base_one: postAuthorUserId_base_one
        )
        guard availableUsers_base_one.count >= 2 else { return [] }
        
        let commenter1_base_one = availableUsers_base_one[postIndex_base_one % availableUsers_base_one.count]
        let commenter2_base_one = availableUsers_base_one[(postIndex_base_one + 1) % availableUsers_base_one.count]
        
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
    
    /// 随机设置各用户的喜欢帖子列表
    func setUserLikes_Base_one() {
        guard let dataLocal_base_one = dataLocal_Base_one else { return }
        
        for i_base_one in 0..<dataLocal_base_one.userList_Base_one.count {
            let user_base_one = dataLocal_base_one.userList_Base_one[i_base_one]
            
            let availablePosts_base_one = dataLocal_base_one.getPostsExcludingUser_Base_one(
                userId_base_one: user_base_one.userId_Base_one ?? 0
            )
            
            let likePosts_base_one = RandomUtil_Base_one.selectRandomItems_Base_one(
                from: availablePosts_base_one,
                count_base_one: DataConfig_Base_one.likePostCount_Base_one
            )
            
            dataLocal_base_one.userList_Base_one[i_base_one].userLike_Base_one = likePosts_base_one
        }
    }
}
