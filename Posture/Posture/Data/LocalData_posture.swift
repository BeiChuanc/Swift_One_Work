import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Posture {
    /// ID起始值
    static let userIdStart_Posture = 10
    static let postIdStart_Posture = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Posture = 2
}

/// 本地数据管理类
class LocalData_Posture {
    
    /// 单例
    static let shared_Posture = LocalData_Posture()
    
    /// 用户列表
    var userList_Posture: [PrewUserModel_Posture] = []
    
    /// 帖子列表
    var titleList_Posture: [TitleModel_Posture] = []

    /// 话题列表
    var topicList_Posture: [Topic_Posture] = []
    
    /// 数据生成器
    private lazy var generator_Posture: DataGenerator_Posture = {
        return DataGenerator_Posture(dataLocal_posture: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Posture() {
        generator_Posture.initUsers_Posture()
        generator_Posture.initPosts_Posture()
        generator_Posture.setUserLikes_Posture()
        generator_Posture.initTopics_Posture()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Posture(userId_posture: Int) -> [TitleModel_Posture] {
        return titleList_Posture.filter { $0.titleUserId_Posture != userId_posture }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Posture(postAuthorUserId_posture: Int) -> [PrewUserModel_Posture] {
        return userList_Posture.filter { $0.userId_Posture != postAuthorUserId_posture }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Posture {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Posture: [(String, String, String, String)] = [
        ("DeskResetter", "Sharing gentle desk posture routines", "head1", "head1"),
        ("SpineSpark", "Helping small alignment wins feel fun", "head2", "head2"),
        ("CoreBloom", "Daily core work and mobility notes", "head3", "head3"),
        ("NeckEase", "Tiny habits for a lighter neck", "head4", "head4"),
        ("MoveMuse", "Playful posture ideas for busy days", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Posture: [(String, String, String)] = [
        ("Two-Minute Neck Reset", "I tried a tiny neck reset between meetings today: chin tuck, slow shoulder roll, and one deep breath. My screen felt less heavy afterward, and it was easy enough to repeat.", "title10"),
        ("Desk Flow That Sticks", "The best posture routine for me is one I can do without leaving the chair. Three slow reaches, a seated twist, and a gentle chest opener made my afternoon feel completely different.", "title9"),
        ("Core Before Coffee", "Five quiet core breaths before coffee changed the tone of my morning. It is not intense, but it reminds my body to stack ribs, hips, and shoulders before the day speeds up.", "title3"),
        ("Walking Tall Trick", "I started imagining a balloon lifting the crown of my head during walks. It sounds silly, but it helps me soften my shoulders and keep my stride relaxed.", "title4"),
        ("Screen Height Win", "Raised my laptop with two books and the neck tension dropped fast. Tiny setup upgrades can feel like self-care when they make good posture easier.", "title5"),
        ("Stretch Snack Break", "Instead of waiting for a long workout, I added tiny stretch snacks: doorway chest opener, wrist circles, and a soft back bend. The small breaks are finally adding up.", "title6"),
        ("Shoulder Blade Reminder", "My favorite cue today: slide shoulder blades into back pockets, then relax. It wakes up my upper back without making me stiff or robotic.", "title7"),
        ("Breathing For Alignment", "A slow exhale helped my ribs settle and my lower back calm down. Posture is starting to feel less like holding a pose and more like finding space.", "title8"),
        ("Commute Posture Check", "On the train, I planted both feet and let my phone come up instead of my head dropping down. One commute, fewer neck complaints.", "title2"),
        ("Evening Spine Unwind", "Finished the day with a pillow under my upper back and arms open wide. Two minutes later, my chest felt lighter and my sleep routine felt kinder.", "title1"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Posture: [(String, String)] = [
        ("This is exactly the kind of micro routine I can keep during work.", "The chin tuck cue helped me notice how much I was leaning forward."),
        ("Seated twists are underrated. They make my desk day feel less locked up.", "Love that this does not require a full workout block."),
        ("Core breathing before coffee is such a calm way to start.", "Ribs over hips is the cue I needed today."),
        ("The balloon image sounds playful, but it really works for walking tall.", "Trying this on my next walk around the block."),
        ("Laptop height changed everything for me too.", "Simple setup wins are the easiest posture wins."),
        ("Stretch snacks make consistency feel possible.", "Doorway chest openers are my favorite reset."),
        ("Back pockets cue is clear and easy to remember.", "This helped without making my shoulders tense."),
        ("Breathing makes posture feel kinder and less forced.", "The exhale cue helped my lower back settle."),
        ("Phone up instead of head down is a huge commute habit.", "My neck needed this reminder today."),
        ("Evening unwind sounds perfect after long screen time.", "Two minutes is doable, and that is why it works."),
    ]

    /// 话题预制数据（话题ID, 标题, 描述, 图标, 参与人数）
    static let topicsInfo_Posture: [(Int, String, String, String, Int)] = [
        (1, "Office Sitting Correction", "Tips and tricks for correcting posture from long desk hours", "chair", 2340),
        (2, "Post-Partum Body Recovery", "Gentle posture restoration routines for new moms", "figure.and.child.holdinghands", 1582),
        (3, "Student Hunchback Fix", "Proven exercises to reduce academic-induced hunchback", "graduationcap", 3019),
    ]

    /// 话题评论预制数据（每个话题对应一组评论：用户下标, 内容）
    static let topicComments_Posture: [[(Int, String)]] = [
        [
            (0, "Raising my monitor helped so much. Highly recommend for long desk workers."),
            (1, "I set a 30-min timer to stand and stretch. It changed everything."),
            (2, "Lumbar support cushion was my biggest unlock for office sitting."),
            (3, "A quick shoulder roll every hour helps reset accumulated tension."),
        ],
        [
            (1, "Core breathing exercises were the first thing I could do postpartum."),
            (2, "Gentle hip openers and pelvic tilts helped me feel aligned again."),
            (0, "My physio recommended wall angels. Amazing for upper back postpartum."),
            (3, "Don't rush it. Small daily stretches compound beautifully over weeks."),
        ],
        [
            (2, "Chin tuck + wall posture checks are my daily student routine now."),
            (3, "Switching to a higher desk in the library made a huge difference."),
            (0, "Band pull-aparts between study sessions make my back feel way lighter."),
            (1, "Taking notes on paper instead of laptop helped reduce my forward head."),
        ],
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Posture {
    
    /// 生成指定范围的随机整数
    static func nextInt_Posture(min_posture: Int, range_posture: Int) -> Int {
        return Int.random(in: min_posture..<(min_posture + range_posture))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Posture<T>(from list_posture: [T], count_posture: Int) -> [T] {
        guard !list_posture.isEmpty else { return [] }
        guard list_posture.count > count_posture else { return list_posture }
        
        var selected_posture: [T] = []
        var indices_posture: Set<Int> = []
        
        while selected_posture.count < count_posture && indices_posture.count < list_posture.count {
            let index_posture = Int.random(in: 0..<list_posture.count)
            if !indices_posture.contains(index_posture) {
                indices_posture.insert(index_posture)
                selected_posture.append(list_posture[index_posture])
            }
        }
        
        return selected_posture
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Posture {
    
    private weak var dataLocal_Posture: LocalData_Posture?
    
    init(dataLocal_posture: LocalData_Posture) {
        self.dataLocal_Posture = dataLocal_posture
    }
    
    /// 初始化生成用户数据
    func initUsers_Posture() {
        guard let dataLocal_posture = dataLocal_Posture else { return }
        dataLocal_posture.userList_Posture.removeAll()
        
        for (index_posture, userInfo_posture) in DataSource_Posture.usersInfo_Posture.enumerated() {
            let (username_posture, introduce_posture, userHead_posture, userAlbum_posture) = userInfo_posture
            
            let user_posture = PrewUserModel_Posture()
            user_posture.userId_Posture = index_posture + DataConfig_Posture.userIdStart_Posture
            user_posture.userName_Posture = username_posture
            user_posture.userIntroduce_Posture = introduce_posture
            user_posture.userHead_Posture = userHead_posture
            user_posture.userMedia_Posture = [userAlbum_posture]
            user_posture.userLike_Posture = []
            user_posture.userFollow_Posture = 15 + Int.random(in: 1...50)
            user_posture.userFans_Posture = 20 + Int.random(in: 1...50)
            
            dataLocal_posture.userList_Posture.append(user_posture)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Posture() {
        guard let dataLocal_posture = dataLocal_Posture else { return }
        dataLocal_posture.titleList_Posture.removeAll()
        
        for (index_posture, postInfo_posture) in DataSource_Posture.postsInfo_Posture.enumerated() {
            let (title_posture, content_posture, media_posture) = postInfo_posture
            
            // 循环分配作者
            let authorIndex_posture = index_posture % dataLocal_posture.userList_Posture.count
            guard authorIndex_posture < dataLocal_posture.userList_Posture.count else { continue }
            let author_posture = dataLocal_posture.userList_Posture[authorIndex_posture]
            
            // 生成评论
            let comments_posture = generateComments_Posture(
                postIndex_posture: index_posture,
                postAuthorUserId_posture: author_posture.userId_Posture ?? 0
            )
            
            // 创建帖子
            let post_posture = TitleModel_Posture(
                titleId_Posture: index_posture + DataConfig_Posture.postIdStart_Posture,
                titleUserId_Posture: author_posture.userId_Posture ?? 0,
                titleUserName_Posture: author_posture.userName_Posture ?? "",
                titleMeidas_Posture: [media_posture],
                title_Posture: title_posture,
                titleContent_Posture: content_posture,
                reviews_Posture: comments_posture,
                likes_Posture: RandomUtil_Posture.nextInt_Posture(min_posture: 10, range_posture: 150)
            )
            
            dataLocal_posture.titleList_Posture.append(post_posture)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Posture(postIndex_posture: Int, postAuthorUserId_posture: Int) -> [Comment_Posture] {
        guard let dataLocal_posture = dataLocal_Posture else { return [] }
        
        let availableUsers_posture = dataLocal_posture.getAvailableCommenters_Posture(postAuthorUserId_posture: postAuthorUserId_posture)
        guard availableUsers_posture.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_posture = availableUsers_posture[postIndex_posture % availableUsers_posture.count]
        let commenter2_posture = availableUsers_posture[(postIndex_posture + 1) % availableUsers_posture.count]
        
        // 获取评论内容
        let commentIndex_posture = postIndex_posture % DataSource_Posture.comments_Posture.count
        let (comment1_posture, comment2_posture) = DataSource_Posture.comments_Posture[commentIndex_posture]
        
        return [
            Comment_Posture(
                commentId_Posture: postIndex_posture * 2 + 1,
                commentUserId_Posture: commenter1_posture.userId_Posture ?? 0,
                commentUserName_Posture: commenter1_posture.userName_Posture ?? "",
                commentContent_Posture: comment1_posture
            ),
            Comment_Posture(
                commentId_Posture: postIndex_posture * 2 + 2,
                commentUserId_Posture: commenter2_posture.userId_Posture ?? 0,
                commentUserName_Posture: commenter2_posture.userName_Posture ?? "",
                commentContent_Posture: comment2_posture
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Posture() {        guard let dataLocal_posture = dataLocal_Posture else { return }
        
        for i_posture in 0..<dataLocal_posture.userList_Posture.count {
            let user_posture = dataLocal_posture.userList_Posture[i_posture]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_posture = dataLocal_posture.getPostsExcludingUser_Posture(
                userId_posture: user_posture.userId_Posture ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_posture = RandomUtil_Posture.selectRandomItems_Posture(
                from: availablePosts_posture,
                count_posture: DataConfig_Posture.likePostCount_Posture
            )
            
            dataLocal_posture.userList_Posture[i_posture].userLike_Posture = likePosts_posture
        }
    }

    /// 初始化话题数据
    /// - Parameters: 无
    /// - Returns: Void
    func initTopics_Posture() {
        guard let dataLocal_posture = dataLocal_Posture else { return }
        dataLocal_posture.topicList_Posture.removeAll()

        for topicInfo_posture in DataSource_Posture.topicsInfo_Posture {
            let (id_posture, title_posture, desc_posture, icon_posture, memberCount_posture) = topicInfo_posture

            // 生成该话题的预制评论
            let commentDataIndex_posture = id_posture - 1
            guard commentDataIndex_posture < DataSource_Posture.topicComments_Posture.count else { continue }
            let commentData_posture = DataSource_Posture.topicComments_Posture[commentDataIndex_posture]

            var comments_posture: [Comment_Posture] = []
            for (idx_posture, (userIdx_posture, content_posture)) in commentData_posture.enumerated() {
                let safeIdx_posture = userIdx_posture % max(1, dataLocal_posture.userList_Posture.count)
                let user_posture = dataLocal_posture.userList_Posture[safeIdx_posture]
                comments_posture.append(Comment_Posture(
                    commentId_Posture: id_posture * 100 + idx_posture,
                    commentUserId_Posture: user_posture.userId_Posture ?? 0,
                    commentUserName_Posture: user_posture.userName_Posture ?? "User",
                    commentContent_Posture: content_posture
                ))
            }

            let topic_posture = Topic_Posture(
                topicId_Posture: id_posture,
                topicTitle_Posture: title_posture,
                topicDesc_Posture: desc_posture,
                topicIcon_Posture: icon_posture,
                comments_Posture: comments_posture,
                memberCount_Posture: memberCount_posture
            )
            dataLocal_posture.topicList_Posture.append(topic_posture)
        }
    }
}
