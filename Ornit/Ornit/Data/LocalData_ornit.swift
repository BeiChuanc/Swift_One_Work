import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Ornit {
    /// ID起始值
    static let userIdStart_Ornit = 10
    static let postIdStart_Ornit = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Ornit = 2
}

/// 本地数据管理类
class LocalData_Ornit {
    
    /// 单例
    static let shared_Ornit = LocalData_Ornit()
    
    /// 用户列表
    var userList_Ornit: [PrewUserModel_Ornit] = []
    
    /// 帖子列表
    var titleList_Ornit: [TitleModel_Ornit] = []

    /// 四季专题列表（官方预置，支持用户追加评论）
    var seasonalTopics_Ornit: [SeasonalTopic_Ornit] = []
    
    /// 数据生成器
    private lazy var generator_Ornit: DataGenerator_Ornit = {
        return DataGenerator_Ornit(dataLocal_ornit: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Ornit() {
        generator_Ornit.initUsers_Ornit()
        generator_Ornit.initPosts_Ornit()
        generator_Ornit.setUserLikes_Ornit()
        initSeasonalTopics_Ornit()
    }

    /// 初始化四季专题预置数据（含每个专题 2 条来自真实用户的预设评论）
    private func initSeasonalTopics_Ornit() {
        // 使用已初始化的用户列表预设评论
        let u0_ornit = userList_Ornit.count > 0 ? userList_Ornit[0] : nil   // WillowWarbler (id 10)
        let u1_ornit = userList_Ornit.count > 1 ? userList_Ornit[1] : nil   // RaptorRidge   (id 11)
        let u2_ornit = userList_Ornit.count > 2 ? userList_Ornit[2] : nil   // MigrantMapper (id 12)
        let u3_ornit = userList_Ornit.count > 3 ? userList_Ornit[3] : nil   // NestFinder    (id 13)
        let u4_ornit = userList_Ornit.count > 4 ? userList_Ornit[4] : nil   // DawnChorus    (id 14)

        seasonalTopics_Ornit = [
            SeasonalTopic_Ornit(
                topicId_Ornit: 1,
                season_Ornit: "Spring",
                title_Ornit: "Spring Migration Arrivals",
                topicDescription_Ornit: "Witness thousands of migrating birds returning from their winter grounds. Spring migration peaks between March and May, with warblers, shorebirds, and raptors filling the sky. Share your best spring sighting!",
                gradientStart_Ornit: "#34D399",
                gradientEnd_Ornit: "#059669",
                iconName_Ornit: "arrow.up.circle.fill",
                comments_Ornit: [
                    Comment_Ornit(
                        commentId_Ornit: 1001,
                        commentUserId_Ornit: u0_ornit?.userId_Ornit ?? 10,
                        commentUserName_Ornit: u0_ornit?.userName_Ornit ?? "WillowWarbler",
                        commentContent_Ornit: "Spotted my first warbler of the season this morning! The yellow plumage was stunning against the fresh green leaves. Migration is definitely underway — I counted 8 species in 20 minutes."
                    ),
                    Comment_Ornit(
                        commentId_Ornit: 1002,
                        commentUserId_Ornit: u1_ornit?.userId_Ornit ?? 11,
                        commentUserName_Ornit: u1_ornit?.userName_Ornit ?? "RaptorRidge",
                        commentContent_Ornit: "The dawn chorus is incredible right now! I set my alarm at 5 AM and was rewarded with 14 species before breakfast. Spring is hands-down the best time to be out in the field."
                    )
                ]
            ),
            SeasonalTopic_Ornit(
                topicId_Ornit: 2,
                season_Ornit: "Summer",
                title_Ornit: "Summer Breeding Behaviors",
                topicDescription_Ornit: "Summer transforms birdwatching into an observation of breeding rituals. From elaborate courtship displays to nest-building and chick rearing, every moment tells a story of survival and adaptation.",
                gradientStart_Ornit: "#FBB60A",
                gradientEnd_Ornit: "#F97316",
                iconName_Ornit: "sun.max.fill",
                comments_Ornit: [
                    Comment_Ornit(
                        commentId_Ornit: 2001,
                        commentUserId_Ornit: u2_ornit?.userId_Ornit ?? 12,
                        commentUserName_Ornit: u2_ornit?.userName_Ornit ?? "MigrantMapper",
                        commentContent_Ornit: "Watched a pair of Cardinals feeding their fledglings all afternoon — the male was bringing berries every few minutes. Witnessing that level of parental dedication is what makes summer birding so rewarding."
                    ),
                    Comment_Ornit(
                        commentId_Ornit: 2002,
                        commentUserId_Ornit: u3_ornit?.userId_Ornit ?? 13,
                        commentUserName_Ornit: u3_ornit?.userName_Ornit ?? "NestFinder",
                        commentContent_Ornit: "Hummingbirds are everywhere now! Set up a feeder last week and already have three regulars. The iridescent throat feathers in direct sunlight are absolutely breathtaking — pure summer magic."
                    )
                ]
            ),
            SeasonalTopic_Ornit(
                topicId_Ornit: 3,
                season_Ornit: "Autumn",
                title_Ornit: "Autumn Raptor Watch",
                topicDescription_Ornit: "Autumn skies fill with impressive raptor migrations and massive flocking behaviors. Look for broad-winged hawks, geese formations, and starling murmurations painting the sky at dusk.",
                gradientStart_Ornit: "#F59E0B",
                gradientEnd_Ornit: "#EF4444",
                iconName_Ornit: "leaf.fill",
                comments_Ornit: [
                    Comment_Ornit(
                        commentId_Ornit: 3001,
                        commentUserId_Ornit: u4_ornit?.userId_Ornit ?? 14,
                        commentUserName_Ornit: u4_ornit?.userName_Ornit ?? "DawnChorus",
                        commentContent_Ornit: "Incredible raptor migration from the ridge today — over 400 Broad-winged Hawks riding a single thermal! A count like this only happens a few times each autumn. Already planning to come back tomorrow."
                    ),
                    Comment_Ornit(
                        commentId_Ornit: 3002,
                        commentUserId_Ornit: u0_ornit?.userId_Ornit ?? 10,
                        commentUserName_Ornit: u0_ornit?.userName_Ornit ?? "WillowWarbler",
                        commentContent_Ornit: "The Starling murmurations at dusk have started again — thousands of birds moving as one fluid organism against the orange sky. Still mesmerizing after years of watching. Nature's most spectacular free show."
                    )
                ]
            ),
            SeasonalTopic_Ornit(
                topicId_Ornit: 4,
                season_Ornit: "Winter",
                title_Ornit: "Winter Overwintering Species",
                topicDescription_Ornit: "While many birds migrate, resilient species remain through winter. Discover owls, snow buntings, and cold-weather specialists in their element. Winter birdwatching rewards patience with rare encounters.",
                gradientStart_Ornit: "#60A5FA",
                gradientEnd_Ornit: "#3B82F6",
                iconName_Ornit: "snowflake",
                comments_Ornit: [
                    Comment_Ornit(
                        commentId_Ornit: 4001,
                        commentUserId_Ornit: u1_ornit?.userId_Ornit ?? 11,
                        commentUserName_Ornit: u1_ornit?.userName_Ornit ?? "RaptorRidge",
                        commentContent_Ornit: "Found a Short-eared Owl hunting at dawn over the marsh this morning. They're much more visible in winter when food is scarce and they hunt in daylight. One of those rare and magical encounters you never forget."
                    ),
                    Comment_Ornit(
                        commentId_Ornit: 4002,
                        commentUserId_Ornit: u2_ornit?.userId_Ornit ?? 12,
                        commentUserName_Ornit: u2_ornit?.userName_Ornit ?? "MigrantMapper",
                        commentContent_Ornit: "Winter feeders are my best investment every year. I'm seeing Pine Siskins and Common Redpolls that I never get in summer — these irruptive species make each winter season unique and keep birding exciting year-round."
                    )
                ]
            )
        ]
    }

    /// 向指定专题添加评论
    /// - Parameters:
    ///   - topicId_ornit: 专题 ID
    ///   - comment_ornit: 新评论
    func addTopicComment_Ornit(topicId_ornit: Int, comment_ornit: Comment_Ornit) {
        guard let idx_ornit = seasonalTopics_Ornit.firstIndex(where: { $0.topicId_Ornit == topicId_ornit }) else { return }
        seasonalTopics_Ornit[idx_ornit].comments_Ornit.append(comment_ornit)
    }

    /// 删除指定专题中的评论
    /// - Parameters:
    ///   - topicId_ornit: 专题 ID
    ///   - commentId_ornit: 评论 ID
    func deleteTopicComment_Ornit(topicId_ornit: Int, commentId_ornit: Int) {
        guard let idx_ornit = seasonalTopics_Ornit.firstIndex(where: { $0.topicId_Ornit == topicId_ornit }) else { return }
        seasonalTopics_Ornit[idx_ornit].comments_Ornit.removeAll { $0.commentId_Ornit == commentId_ornit }
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Ornit(userId_ornit: Int) -> [TitleModel_Ornit] {
        return titleList_Ornit.filter { $0.titleUserId_Ornit != userId_ornit }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Ornit(postAuthorUserId_ornit: Int) -> [PrewUserModel_Ornit] {
        return userList_Ornit.filter { $0.userId_Ornit != postAuthorUserId_ornit }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Ornit {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Ornit: [(String, String, String, String)] = [
        ("WillowWarbler", "Chasing warblers through every woodland and wetland I can find", "head1", "head1"),
        ("RaptorRidge", "From hawk watches to backyard feeders — birds are my life", "head2", "head2"),
        ("MigrantMapper", "Plotting migration routes one sighting at a time", "head3", "head3"),
        ("NestFinder", "Documenting nests and breeding behavior since 2015", "head4", "head4"),
        ("DawnChorus", "Up before sunrise every morning for the best bird songs", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Ornit: [(String, String, String)] = [
        ("First Warbler of Spring", "Spotted the season's first Yellow Warbler singing from a willow branch this morning. That bright yellow plumage against fresh green leaves is pure spring magic. Migration is officially underway — I counted five species in under twenty minutes.", "title1"),
        ("Osprey Fishing Dive", "Watched an Osprey plunge feet-first into the lake and emerge with a trout nearly half its own body length. The entire sequence took less than three seconds. Nature's precision hunting never gets old, no matter how many times you witness it.", "title2"),
        ("Dawn Chorus Magic", "Set the alarm for 4:45 AM and hiked to the ridge before first light. By sunrise I had logged 18 species by ear alone. The American Robin led the chorus, followed closely by the Wood Thrush. Every early morning like this reminds me why I started birding.", "title3"),
        ("Rare Visitor at the Feeder", "A male Black-headed Grosbeak appeared at my feeder today — far outside its usual range! Grabbed the camera just in time and got a dozen clean shots before it flew off into the hedgerow. Life bird number 312 and counting!", "title4"),
        ("Peregrine Stoop", "From the cliff top I watched a Peregrine Falcon fold its wings and stoop at over 200 mph on a pigeon flock circling below. The sheer speed still leaves me speechless, even after dozens of sightings over the years. There is nothing faster in the natural world.", "title5"),
        ("Heron at Sunrise", "The Great Blue Heron stood absolutely motionless in the shallows for twenty-three minutes, then struck with lightning speed. Patience is its greatest superpower — and, as a birder, mine too. Worth every cold, quiet minute of waiting.", "title6"),
        ("Kingfisher Flash", "Cycling the riverside path when a brilliant turquoise flash shot past at eye level — a Belted Kingfisher! I pulled over, leaned my bike against the fence, and watched it hunt from a low branch for the next thirty minutes. Best morning commute of my life.", "title7"),
        ("Murmuration at Dusk", "A Starling murmuration gathered over the marshes as the sun dropped. Thousands of birds moving like liquid smoke, twisting and flowing against the orange sky. Thirty years of birding and it still gives me chills every single time.", "title8"),
        ("Snowy Owl Winter Irruption", "First Snowy Owl of the season perched on a fence post at the edge of the open field. Those pale, piercing yellow eyes held mine for a long moment before it turned away. Winter irruption birding simply does not get better than this.", "title9"),
        ("Bluebird Fledgling Day", "The pair of Eastern Bluebirds in the nest box finally fledged all five chicks today. I watched each one make that first brave leap into the wide world. Months of careful monitoring, and moments like this make every visit completely worthwhile.", "title10"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Ornit: [(String, String)] = [
        ("That first warbler sighting always confirms spring has truly arrived — lucky you!", "Yellow plumage against fresh green leaves sounds stunning. What location was this?"),
        ("Osprey dives are jaw-dropping every single time. What an incredible moment to witness!", "Three seconds from dive to catch — nature's precision never stops amazing me. Great sighting!"),
        ("The dawn chorus is my absolute favorite part of birding. Every early alarm is worth it!", "18 species by ear alone is seriously impressive. Do you use any audio recording apps out there?"),
        ("A Black-headed Grosbeak out of range is a genuine mega rarity — huge congratulations!", "Life bird 312! What an unexpected feeder visitor. Have you reported it to eBird yet?"),
        ("Peregrine stoops are the most thrilling thing in all of birding. What a view from that cliff!", "200 mph is just mind-blowing. That bird is an absolute force of nature unlike anything else!"),
        ("Great Blue Herons are such wonderfully patient hunters — true masters of stillness!", "That lightning-fast strike after such stillness is always a shock to watch. Beautiful description!"),
        ("A Kingfisher encounter always makes the whole day worthwhile — those colors are unreal!", "Best commute ever indeed! Kingfishers never disappoint. You chose the right route today!"),
        ("Murmurations are honestly one of nature's greatest spectacles. Thirty years and still chills — same!", "Liquid smoke against an orange sky — you paint the most vivid pictures with your words!"),
        ("Snowy Owls are pure Arctic magic visiting us. Those yellow eyes must have been unforgettable!", "A strong irruption winter makes every cold field trip completely worth it. Amazing encounter!"),
        ("Five fledglings from one nest box in a single season is a truly fantastic result — well done!", "That first brave leap from the nest is always emotional to witness. Thank you so much for sharing!"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Ornit {
    
    /// 生成指定范围的随机整数
    static func nextInt_Ornit(min_ornit: Int, range_ornit: Int) -> Int {
        return Int.random(in: min_ornit..<(min_ornit + range_ornit))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Ornit<T>(from list_ornit: [T], count_ornit: Int) -> [T] {
        guard !list_ornit.isEmpty else { return [] }
        guard list_ornit.count > count_ornit else { return list_ornit }
        
        var selected_ornit: [T] = []
        var indices_ornit: Set<Int> = []
        
        while selected_ornit.count < count_ornit && indices_ornit.count < list_ornit.count {
            let index_ornit = Int.random(in: 0..<list_ornit.count)
            if !indices_ornit.contains(index_ornit) {
                indices_ornit.insert(index_ornit)
                selected_ornit.append(list_ornit[index_ornit])
            }
        }
        
        return selected_ornit
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Ornit {
    
    private weak var dataLocal_Ornit: LocalData_Ornit?
    
    init(dataLocal_ornit: LocalData_Ornit) {
        self.dataLocal_Ornit = dataLocal_ornit
    }
    
    /// 初始化生成用户数据
    func initUsers_Ornit() {
        guard let dataLocal_ornit = dataLocal_Ornit else { return }
        dataLocal_ornit.userList_Ornit.removeAll()
        
        for (index_ornit, userInfo_ornit) in DataSource_Ornit.usersInfo_Ornit.enumerated() {
            let (username_ornit, introduce_ornit, userHead_ornit, userAlbum_ornit) = userInfo_ornit
            
            let user_ornit = PrewUserModel_Ornit()
            user_ornit.userId_Ornit = index_ornit + DataConfig_Ornit.userIdStart_Ornit
            user_ornit.userName_Ornit = username_ornit
            user_ornit.userIntroduce_Ornit = introduce_ornit
            user_ornit.userHead_Ornit = userHead_ornit
            user_ornit.userMedia_Ornit = [userAlbum_ornit]
            user_ornit.userLike_Ornit = []
            user_ornit.userFollow_Ornit = 15 + Int.random(in: 1...50)
            user_ornit.userFans_Ornit = 20 + Int.random(in: 1...50)
            
            dataLocal_ornit.userList_Ornit.append(user_ornit)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Ornit() {
        guard let dataLocal_ornit = dataLocal_Ornit else { return }
        dataLocal_ornit.titleList_Ornit.removeAll()
        
        for (index_ornit, postInfo_ornit) in DataSource_Ornit.postsInfo_Ornit.enumerated() {
            let (title_ornit, content_ornit, media_ornit) = postInfo_ornit
            
            // 循环分配作者
            let authorIndex_ornit = index_ornit % dataLocal_ornit.userList_Ornit.count
            guard authorIndex_ornit < dataLocal_ornit.userList_Ornit.count else { continue }
            let author_ornit = dataLocal_ornit.userList_Ornit[authorIndex_ornit]
            
            // 生成评论
            let comments_ornit = generateComments_Ornit(
                postIndex_ornit: index_ornit,
                postAuthorUserId_ornit: author_ornit.userId_Ornit ?? 0
            )
            
            // 创建帖子
            let post_ornit = TitleModel_Ornit(
                titleId_Ornit: index_ornit + DataConfig_Ornit.postIdStart_Ornit,
                titleUserId_Ornit: author_ornit.userId_Ornit ?? 0,
                titleUserName_Ornit: author_ornit.userName_Ornit ?? "",
                titleMeidas_Ornit: [media_ornit],
                title_Ornit: title_ornit,
                titleContent_Ornit: content_ornit,
                reviews_Ornit: comments_ornit,
                likes_Ornit: RandomUtil_Ornit.nextInt_Ornit(min_ornit: 10, range_ornit: 150)
            )
            
            dataLocal_ornit.titleList_Ornit.append(post_ornit)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Ornit(postIndex_ornit: Int, postAuthorUserId_ornit: Int) -> [Comment_Ornit] {
        guard let dataLocal_ornit = dataLocal_Ornit else { return [] }
        
        let availableUsers_ornit = dataLocal_ornit.getAvailableCommenters_Ornit(postAuthorUserId_ornit: postAuthorUserId_ornit)
        guard availableUsers_ornit.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_ornit = availableUsers_ornit[postIndex_ornit % availableUsers_ornit.count]
        let commenter2_ornit = availableUsers_ornit[(postIndex_ornit + 1) % availableUsers_ornit.count]
        
        // 获取评论内容
        let commentIndex_ornit = postIndex_ornit % DataSource_Ornit.comments_Ornit.count
        let (comment1_ornit, comment2_ornit) = DataSource_Ornit.comments_Ornit[commentIndex_ornit]
        
        return [
            Comment_Ornit(
                commentId_Ornit: postIndex_ornit * 2 + 1,
                commentUserId_Ornit: commenter1_ornit.userId_Ornit ?? 0,
                commentUserName_Ornit: commenter1_ornit.userName_Ornit ?? "",
                commentContent_Ornit: comment1_ornit
            ),
            Comment_Ornit(
                commentId_Ornit: postIndex_ornit * 2 + 2,
                commentUserId_Ornit: commenter2_ornit.userId_Ornit ?? 0,
                commentUserName_Ornit: commenter2_ornit.userName_Ornit ?? "",
                commentContent_Ornit: comment2_ornit
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Ornit() {
        guard let dataLocal_ornit = dataLocal_Ornit else { return }
        
        for i_ornit in 0..<dataLocal_ornit.userList_Ornit.count {
            let user_ornit = dataLocal_ornit.userList_Ornit[i_ornit]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_ornit = dataLocal_ornit.getPostsExcludingUser_Ornit(
                userId_ornit: user_ornit.userId_Ornit ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_ornit = RandomUtil_Ornit.selectRandomItems_Ornit(
                from: availablePosts_ornit,
                count_ornit: DataConfig_Ornit.likePostCount_Ornit
            )
            
            dataLocal_ornit.userList_Ornit[i_ornit].userLike_Ornit = likePosts_ornit
        }
    }
}
