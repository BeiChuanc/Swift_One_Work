import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 本地数据管理类
/// 功能：管理预制用户与帖子数据，提供查询过滤方法
/// 设计：单例 + 内部 DataGenerator 负责批量生成
class LocalData_Maki {
    
    static let shared_Maki = LocalData_Maki()
    
    /// 用户列表
    var userList_Maki: [PrewUserModel_Maki] = []
    
    /// 帖子列表
    var titleList_Maki: [TitleModel_Maki] = []
    
    private lazy var generator_Maki = DataGenerator_Maki(dataLocal_maki: self)
    
    private init() {}
    
    /// 初始化所有预制数据
    func initData_Maki() {
        generator_Maki.initUsers_Maki()
        generator_Maki.initPosts_Maki()
        generator_Maki.setUserLikes_Maki()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Maki(userId_maki: Int) -> [TitleModel_Maki] {
        titleList_Maki.filter { $0.titleUserId_Maki != userId_maki }
    }
    
    /// 获取可评论的用户列表（排除帖子作者）
    func getAvailableCommenters_Maki(postAuthorUserId_maki: Int) -> [PrewUserModel_Maki] {
        userList_Maki.filter { $0.userId_Maki != postAuthorUserId_maki }
    }
}

// MARK: - 静态数据源

/// 预制用户与帖子原始数据
private enum DataSource_Maki {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    /// 主题：造物小记 — 记录手工创作、DIY与灵感捕捉的创作者社区
    static let usersInfo_Maki: [(String, String, String, String)] = [
        ("CraftEmber", "Documenting handmade creations one spark at a time 🔥", "head1", "head1"),
        ("WildNotebook", "Field notes, sketches & slow-living stories from the woods", "head2", "head2"),
        ("KilnWhisper", "Ceramics & clay journals — shaping thoughts with my hands", "head3", "head3"),
        ("TinkerAsh", "Turning scraps into stories; upcycling since forever ✂️", "head4", "head4"),
        ("IndigoGlow", "Natural dye, fiber arts & the magic of making from scratch", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    /// 主题：造物小记 — 围绕手工、创作、DIY的日常记录
    static let postsInfo_Maki: [(String, String, String)] = [
        ("First Batch of Beeswax Wraps", "Spent the afternoon melting beeswax pellets with a bit of pine resin and jojoba oil. The fabric came out with this gorgeous honey glow — zero plastic, fully compostable. Imperfect edges, but that's the whole point. Maki is about the process, not just the product.", "title1"),
        ("Just Finished My DIY Project!", "Literally just put down my tools and I'm still buzzing ✨ That last stitch finally clicked into place and my whole mood went from 'ugh, is this even working' to 'I'm basically a genius' in about ten seconds. Hands are tired, heart is full, and I already can't stop thinking about what to make next~", "title2"),
        ("Hand-Stitched Leather Journal Cover", "Cut and punched the holes by hand, then spent two evenings saddle-stitching with waxed linen thread. The leather still smells like the tannery. Every time I open this journal I'm reminded that slowing down is its own reward.", "title3"),
        ("Wildflower Paper — Pressed & Embedded", "Foraged chamomile, clover and a couple of tiny violets from the hillside. Laid them into the wet pulp sheet and let the press do the rest overnight. Held them up to the window this morning — pure stained glass energy. Each sheet is completely unrepeatable.", "title4"),
        ("Terracotta Pinch Pots — Round 3", "Started with just enough clay to fill my palm. No wheel, no tools — just thumbs and patience. These little guys are wonky and lopsided and I absolutely love them. Bisque firing next week. If you haven't tried pinch-pot meditation, you're missing out.", "title5"),
        ("DIY Done — Feeling Unstoppable!", "Finally wrapped up the little project I've been chipping away at all week, and my mood right now? Pure sunshine ☀️ There's nothing quite like that messy-hands, happy-heart feeling after a good DIY session. Already scrolling for ideas for the next one — send help.", "title6"),
        ("Soy Candle Pour — Amber & Cedar", "Blended soy flakes, beeswax and a tiny strip of coconut wax for opacity. Scented with real cedarwood EO and a hint of sweet orange. Poured at 54 °C into recycled jam jars. Tunneling is the enemy — patience is the cure. These are for gifting.", "title7"),
        ("Linocut Print — Harvest Moon", "Carved the relief block over three evenings listening to rain. The crescent-moon hare took shape slowly — one miscut early on that became its ear. Printed in two passes: ochre base, then a deep indigo overlay. Edition of 12, all slightly different.", "title8"),
        ("Wabi-Sabi Mending — Visible Repairs", "Three worn denim items, a needle, and some bright sashiko thread. The goal wasn't to hide the damage but to celebrate the history of the cloth. Gold and terracotta running stitches now live where the tears used to be. Wear it as a story.", "title9"),
        ("Clay Stamp Collection — Finished!", "Forty small impression stamps carved from air-dry clay: leaves, seeds, geometric marks, a tiny campfire. They'll be used for journaling, fabric printing and wax seals. The campfire one took four attempts but finally came out crisp. Worth every redo.", "title10"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    /// 主题：创作者社区的真实互动反馈
    static let comments_Maki: [(String, String)] = [
        ("The honey glow on that fabric is everything! What ratio of wax to resin did you use?", "Zero plastic gifting wraps are such a great idea — I need to make a batch for the holidays 🎁"),
        ("That happy-glow energy is contagious! What did you end up making?", "Nothing resets a whole week like finishing a DIY project. Congrats, this is so well deserved 🎉"),
        ("That saddle stitch is so clean for hand-work! What weight linen thread?", "The smell of fresh leather on a journal... there's nothing else like it. Beautiful craft."),
        ("Pressed wildflower paper is pure magic! The violet one must look incredible backlit.", "Stained glass energy is exactly right. I want to frame one of these sheets, not write on it."),
        ("Pinch-pot meditation is a real thing and I will defend it forever 🏺", "The wonkier the better! Perfection is for machines. These look alive."),
        ("This is exactly the energy I need to finally finish my own project! What's next on your list?", "'Messy hands, happy heart' might be the most accurate way to describe DIY I've ever heard 😂"),
        ("Soy + beeswax blend is my favourite — the throw is so clean. Gifting candles is the ultimate love language.", "Tunneling fixed by patience — writing that on a Post-it for my studio wall."),
        ("The miscut that became the ear is the best kind of happy accident. Edition of 12 is perfect.", "Linocut in two passes! That ochre + indigo combo sounds rich. Would love to see the full edition."),
        ("Visible mending is such a powerful act. Sashiko on denim is one of my favourite combos.", "Gold running stitches on worn denim... that's not a repair, that's an upgrade. Love this."),
        ("A campfire stamp that took four attempts — and you kept going. That's the whole maker spirit.", "Forty stamps carved by hand is a serious labour of love! The seed and leaf ones must be so versatile."),
    ]
}

// MARK: - 随机数工具

/// 随机数工具（仅供数据生成使用）
private enum RandomUtil_Maki {
    
    /// 生成 [min, min + range) 范围内的随机整数
    static func nextInt_Maki(min_maki: Int, range_maki: Int) -> Int {
        Int.random(in: min_maki..<(min_maki + range_maki))
    }
    
    /// 从列表中随机选取不重复的 N 个元素
    static func selectRandomItems_Maki<T>(from list_maki: [T], count_maki: Int) -> [T] {
        guard !list_maki.isEmpty else { return [] }
        guard list_maki.count > count_maki else { return list_maki }
        
        var selected_maki: [T] = []
        var usedIndices_maki = Set<Int>()
        while selected_maki.count < count_maki {
            let index_maki = Int.random(in: 0..<list_maki.count)
            if usedIndices_maki.insert(index_maki).inserted {
                selected_maki.append(list_maki[index_maki])
            }
        }
        return selected_maki
    }
}

// MARK: - 数据生成器

/// 预制数据生成器（仅 LocalData 内部使用）
private class DataGenerator_Maki {
    
    private weak var dataLocal_Maki: LocalData_Maki?
    
    init(dataLocal_maki: LocalData_Maki) {
        self.dataLocal_Maki = dataLocal_maki
    }
    
    /// 根据静态数据源生成用户列表
    func initUsers_Maki() {
        guard let dataLocal_maki = dataLocal_Maki else { return }
        dataLocal_maki.userList_Maki = DataSource_Maki.usersInfo_Maki.enumerated().map { index, info in
            let (name, intro, head, album) = info
            let user_maki = PrewUserModel_Maki()
            user_maki.userId_Maki = index + 10
            user_maki.userName_Maki = name
            user_maki.userIntroduce_Maki = intro
            user_maki.userHead_Maki = head
            user_maki.userMedia_Maki = [album]
            user_maki.userLike_Maki = []
            user_maki.userFollow_Maki = 15 + Int.random(in: 1...50)
            user_maki.userFans_Maki = 20 + Int.random(in: 1...50)
            return user_maki
        }
    }
    
    /// 根据静态数据源生成帖子列表（循环分配作者）
    func initPosts_Maki() {
        guard let dataLocal_maki = dataLocal_Maki else { return }
        let users_maki = dataLocal_maki.userList_Maki
        guard !users_maki.isEmpty else {
            dataLocal_maki.titleList_Maki = []
            return
        }
        
        dataLocal_maki.titleList_Maki = DataSource_Maki.postsInfo_Maki.enumerated().map { index, info in
            let (title, content, media) = info
            let author_maki = users_maki[index % users_maki.count]
            let authorId_maki = author_maki.userId_Maki ?? 0
            
            return TitleModel_Maki(
                titleId_Maki: index + 20,
                titleUserId_Maki: authorId_maki,
                titleUserName_Maki: author_maki.userName_Maki ?? "",
                titleMeidas_Maki: [media],
                title_Maki: title,
                titleContent_Maki: content,
                reviews_Maki: generateComments_Maki(postIndex_maki: index, postAuthorUserId_maki: authorId_maki),
                likes_Maki: RandomUtil_Maki.nextInt_Maki(min_maki: 10, range_maki: 150)
            )
        }
    }
    
    /// 为帖子生成两条评论
    private func generateComments_Maki(postIndex_maki: Int, postAuthorUserId_maki: Int) -> [Comment_Maki] {
        guard let dataLocal_maki = dataLocal_Maki else { return [] }
        let available_maki = dataLocal_maki.getAvailableCommenters_Maki(postAuthorUserId_maki: postAuthorUserId_maki)
        guard available_maki.count >= 2 else { return [] }
        
        let commenter1_maki = available_maki[postIndex_maki % available_maki.count]
        let commenter2_maki = available_maki[(postIndex_maki + 1) % available_maki.count]
        let (text1, text2) = DataSource_Maki.comments_Maki[postIndex_maki % DataSource_Maki.comments_Maki.count]
        
        return [
            makeComment_Maki(id: postIndex_maki * 2 + 1, user: commenter1_maki, content: text1),
            makeComment_Maki(id: postIndex_maki * 2 + 2, user: commenter2_maki, content: text2)
        ]
    }
    
    /// 为每个用户随机分配喜欢的帖子（排除自己的帖子）
    func setUserLikes_Maki() {
        guard let dataLocal_maki = dataLocal_Maki else { return }
        for i in dataLocal_maki.userList_Maki.indices {
            let userId_maki = dataLocal_maki.userList_Maki[i].userId_Maki ?? 0
            dataLocal_maki.userList_Maki[i].userLike_Maki = RandomUtil_Maki.selectRandomItems_Maki(
                from: dataLocal_maki.getPostsExcludingUser_Maki(userId_maki: userId_maki),
                count_maki: 2
            )
        }
    }
    
    /// 构建评论模型
    private func makeComment_Maki(id: Int, user: PrewUserModel_Maki, content: String) -> Comment_Maki {
        Comment_Maki(
            commentId_Maki: id,
            commentUserId_Maki: user.userId_Maki ?? 0,
            commentUserName_Maki: user.userName_Maki ?? "",
            commentContent_Maki: content
        )
    }
}
