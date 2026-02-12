import Foundation
import Combine

// MARK: - 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_platbell {
    /// ID起始值
    static let userIdStart_platbell = 10
    static let postIdStart_platbell = 20
    
    /// 喜欢帖子数量
    static let likePostCount_platbell = 2
}

/// 本地数据管理类
class LocalData_platbell: ObservableObject {
    
    /// 单例实例
    static let shared_platbell = LocalData_platbell()
    
    /// 用户列表
    @Published var userList_platbell: [PrewUserModel_platbell] = []
    
    /// 帖子列表
    @Published var titleList_platbell: [TitleModel_platbell] = []
    
    /// 数据生成器
    private lazy var generator_platbell: DataGenerator_platbell = {
        return DataGenerator_platbell(dataLocal_platbell: self)
    }()
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    /// 初始化所有数据
    func initData_platbell() {
        generator_platbell.initUsers_platbell()
        generator_platbell.initPosts_platbell()
        generator_platbell.setUserLikes_platbell()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_platbell(userId_platbell: Int) -> [TitleModel_platbell] {
        return titleList_platbell.filter { $0.titleUserId_platbell != userId_platbell }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_platbell(postAuthorUserId_platbell: Int) -> [PrewUserModel_platbell] {
        return userList_platbell.filter { $0.userId_platbell != postAuthorUserId_platbell }
    }
    
    // MARK: - 话题标签
    
    /// 获取话题标签列表
    func getTopicTags_platbell() -> [TopicTag_platbell] {
        return [
            TopicTag_platbell(id: 0, name_platbell: "Explore", gradientIndex_platbell: 0),
            TopicTag_platbell(id: 1, name_platbell: "Adventure", gradientIndex_platbell: 1),
            TopicTag_platbell(id: 2, name_platbell: "Nature", gradientIndex_platbell: 2),
            TopicTag_platbell(id: 3, name_platbell: "Discovery", gradientIndex_platbell: 3),
            TopicTag_platbell(id: 4, name_platbell: "Journey", gradientIndex_platbell: 4),
            TopicTag_platbell(id: 5, name_platbell: "Mystery", gradientIndex_platbell: 0),
            TopicTag_platbell(id: 6, name_platbell: "Forest", gradientIndex_platbell: 2),
            TopicTag_platbell(id: 7, name_platbell: "Bell", gradientIndex_platbell: 1)
        ]
    }
    
    // MARK: - 推荐排序
    
    /// 获取推荐用户列表（按关注数和粉丝数排序）
    func getRecommendedUsers_platbell() -> [PrewUserModel_platbell] {
        return userList_platbell.sorted { user1_platbell, user2_platbell in
            let score1_platbell = (user1_platbell.userFollow_platbell ?? 0) + (user1_platbell.userFans_platbell ?? 0)
            let score2_platbell = (user2_platbell.userFollow_platbell ?? 0) + (user2_platbell.userFans_platbell ?? 0)
            return score1_platbell > score2_platbell
        }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_platbell {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_platbell: [(String, String, String, String)] = [
        ("TechExplorer", "Passionate about technology and innovation", "head1", "album1"),
        ("CreativeMinds", "Designer and creative thinker", "head2", "album2"),
        ("CodeMaster", "Full-stack developer and problem solver", "head3", "album3"),
        ("DigitalNomad", "Traveling the world while working remotely", "head4", "album4"),
        ("UXWizard", "Crafting seamless user experiences", "head5", "album5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL, 类型, 标签数组)
    static let postsInfo_platbell: [(String, String, String, Int, [String])] = [
        ("Amazing Discovery", "Just discovered this incredible new feature that's going to change everything. The attention to detail is remarkable, and the user experience is seamless. Can't wait to share more about this with everyone!", "title1", 0, []),
        ("Beautiful Design", "There's something special about clean, minimal design. It's not just about looks—it's about creating an experience that feels natural and effortless. This project captures that perfectly.", "title2", 1, ["Design", "UI/UX", "Inspiration"]),
        ("Innovation at Work", "Watching innovation unfold in real-time is fascinating. The way technology seamlessly integrates into our daily lives never ceases to amaze me. Here's to the future!", "title3", 1, ["Tech", "Innovation", "Future"]),
        ("Creative Process", "Behind every great project is a creative process filled with iterations, late nights, and breakthrough moments. This journey has been incredible so far.", "title4", 0, []),
        ("Team Collaboration", "Look at what we built together! Collaboration brings out the best in everyone. When different perspectives come together, magic happens.", "title5", 1, ["Teamwork", "Success", "Growth"]),
        ("Perfect Execution", "Weeks of planning and hard work have led to this moment. Every detail was carefully considered, and the result speaks for itself. So proud of this achievement!", "title6", 0, []),
        ("Learning Journey", "I used to think success was about knowing everything, but now I realize it's about being willing to learn. This experience taught me so much.", "title7", 1, ["Learning", "Growth", "Mindset"]),
        ("Fun Activities", "We spent today exploring new ideas, testing concepts, and pushing boundaries. What's your favorite way to stay creative and inspired?", "title8", 1, ["Fun", "Creative", "Adventure"]),
        ("Inspiration Everywhere", "Above us, infinite possibilities; around us, endless inspiration. The world is full of ideas waiting to be discovered and brought to life.", "title9", 1, ["Inspiration", "Ideas", "Nature"]),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_platbell: [(String, String)] = [
        ("This looks absolutely incredible! The attention to detail is remarkable", "Can't wait to learn more about this feature. Keep us updated!"),
        ("You captured the essence of great design perfectly! Love this approach", "The simplicity and elegance here is truly inspiring. Beautifully done!"),
        ("Watching technology evolve like this is fascinating. Thanks for sharing!", "This is exactly the kind of innovation we need. Excited to see where it goes!"),
        ("The creative process is always so interesting. Thanks for sharing your journey!", "Love seeing the behind-the-scenes of great work. Inspiring stuff!"),
        ("Already inspired by this collaboration! Nothing beats working with great people", "First thing I'd say? Team work makes the dream work! Who's with me?"),
        ("Your execution is flawless! The planning really shows in the final result", "Weeks of hard work definitely paid off. Congratulations on this achievement!"),
        ("Your learning journey is inspiring! Always room to grow and improve", "It really is about the willingness to learn. Keep sharing your insights!"),
        ("Exploring new ideas is my favorite too! Also love the creative energy here", "My go-to activity: brainstorming with coffee and good music"),
        ("The infinite possibilities and endless inspiration—beautifully put!", "That feeling of discovering new ideas... perfectly captured!"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
private struct RandomUtil_platbell {
    
    /// 生成指定范围的随机整数
    static func nextInt_platbell(min_platbell: Int, range_platbell: Int) -> Int {
        return Int.random(in: min_platbell..<(min_platbell + range_platbell))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_platbell<T>(from list_platbell: [T], count_platbell: Int) -> [T] {
        guard !list_platbell.isEmpty else { return [] }
        guard list_platbell.count > count_platbell else { return list_platbell }
        
        var selected_platbell: [T] = []
        var indices_platbell: Set<Int> = []
        
        while selected_platbell.count < count_platbell && indices_platbell.count < list_platbell.count {
            let index_platbell = Int.random(in: 0..<list_platbell.count)
            if !indices_platbell.contains(index_platbell) {
                indices_platbell.insert(index_platbell)
                selected_platbell.append(list_platbell[index_platbell])
            }
        }
        
        return selected_platbell
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_platbell {
    
    /// 弱引用本地数据管理器，避免循环引用
    private weak var dataLocal_platbell: LocalData_platbell?
    
    /// 初始化方法
    init(dataLocal_platbell: LocalData_platbell) {
        self.dataLocal_platbell = dataLocal_platbell
    }
    
    /// 初始化生成用户数据
    func initUsers_platbell() {
        guard let dataLocal_platbell = dataLocal_platbell else { return }
        dataLocal_platbell.userList_platbell.removeAll()
        
        for (index_platbell, userInfo_platbell) in DataSource_platbell.usersInfo_platbell.enumerated() {
            let (username_platbell, introduce_platbell, userHead_platbell, userAlbum_platbell) = userInfo_platbell
            
            let user_platbell = PrewUserModel_platbell()
            user_platbell.userId_platbell = index_platbell + DataConfig_platbell.userIdStart_platbell
            user_platbell.userName_platbell = username_platbell
            user_platbell.userIntroduce_platbell = introduce_platbell
            user_platbell.userHead_platbell = userHead_platbell
            user_platbell.userMedia_platbell = [userAlbum_platbell]
            user_platbell.userLike_platbell = []
            user_platbell.userFollow_platbell = 15 + Int.random(in: 1...50)
            user_platbell.userFans_platbell = 20 + Int.random(in: 1...50)
            
            dataLocal_platbell.userList_platbell.append(user_platbell)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_platbell() {
        guard let dataLocal_platbell = dataLocal_platbell else { return }
        dataLocal_platbell.titleList_platbell.removeAll()
        
        for (index_platbell, postInfo_platbell) in DataSource_platbell.postsInfo_platbell.enumerated() {
            let (title_platbell, content_platbell, media_platbell, type_platbell, tags_platbell) = postInfo_platbell
            
            // 循环分配作者
            let authorIndex_platbell = index_platbell % dataLocal_platbell.userList_platbell.count
            guard authorIndex_platbell < dataLocal_platbell.userList_platbell.count else { continue }
            let author_platbell = dataLocal_platbell.userList_platbell[authorIndex_platbell]
            
            // 生成评论
            let comments_platbell = generateComments_platbell(
                postIndex_platbell: index_platbell,
                postAuthorUserId_platbell: author_platbell.userId_platbell ?? 0
            )
            
            // 创建帖子
            let post_platbell = TitleModel_platbell(
                titleId_platbell: index_platbell + DataConfig_platbell.postIdStart_platbell,
                titleUserId_platbell: author_platbell.userId_platbell ?? 0,
                titleUserName_platbell: author_platbell.userName_platbell ?? "",
                titleMeidas_platbell: [media_platbell],
                title_platbell: title_platbell,
                titleContent_platbell: content_platbell,
                reviews_platbell: comments_platbell,
                likes_platbell: RandomUtil_platbell.nextInt_platbell(min_platbell: 10, range_platbell: 150),
                type_platbell: type_platbell,
                tags_platbell: tags_platbell
            )
            
            dataLocal_platbell.titleList_platbell.append(post_platbell)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_platbell(postIndex_platbell: Int, postAuthorUserId_platbell: Int) -> [Comment_platbell] {
        guard let dataLocal_platbell = dataLocal_platbell else { return [] }
        
        let availableUsers_platbell = dataLocal_platbell.getAvailableCommenters_platbell(postAuthorUserId_platbell: postAuthorUserId_platbell)
        guard availableUsers_platbell.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_platbell = availableUsers_platbell[postIndex_platbell % availableUsers_platbell.count]
        let commenter2_platbell = availableUsers_platbell[(postIndex_platbell + 1) % availableUsers_platbell.count]
        
        // 获取评论内容
        let commentIndex_platbell = postIndex_platbell % DataSource_platbell.comments_platbell.count
        let (comment1_platbell, comment2_platbell) = DataSource_platbell.comments_platbell[commentIndex_platbell]
        
        return [
            Comment_platbell(
                commentId_platbell: postIndex_platbell * 2 + 1,
                commentUserId_platbell: commenter1_platbell.userId_platbell ?? 0,
                commentUserName_platbell: commenter1_platbell.userName_platbell ?? "",
                commentContent_platbell: comment1_platbell
            ),
            Comment_platbell(
                commentId_platbell: postIndex_platbell * 2 + 2,
                commentUserId_platbell: commenter2_platbell.userId_platbell ?? 0,
                commentUserName_platbell: commenter2_platbell.userName_platbell ?? "",
                commentContent_platbell: comment2_platbell
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_platbell() {
        guard let dataLocal_platbell = dataLocal_platbell else { return }
        
        for i_platbell in 0..<dataLocal_platbell.userList_platbell.count {
            let user_platbell = dataLocal_platbell.userList_platbell[i_platbell]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_platbell = dataLocal_platbell.getPostsExcludingUser_platbell(
                userId_platbell: user_platbell.userId_platbell ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_platbell = RandomUtil_platbell.selectRandomItems_platbell(
                from: availablePosts_platbell,
                count_platbell: DataConfig_platbell.likePostCount_platbell
            )
            
            dataLocal_platbell.userList_platbell[i_platbell].userLike_platbell = likePosts_platbell
        }
    }
}
