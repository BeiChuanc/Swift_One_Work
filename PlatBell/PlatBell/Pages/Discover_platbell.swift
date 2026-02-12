import SwiftUI

// MARK: - 发现页
// 核心作用：展示热门话题、推荐用户和热门内容的综合探索页面
// 设计思路：话题标签 + 混合探索内容（热门帖子和推荐用户交替展示）
// 关键功能：话题筛选、用户关注、内容浏览

/// 发现页
struct Discover_platbell: View {
    
    @ObservedObject var localData_platbell = LocalData_platbell.shared_platbell
    @ObservedObject var titleVM_platbell = TitleViewModel_platbell.shared_platbell
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    /// 选中的话题标签ID
    @State private var selectedTagId_platbell: Int? = nil
    
    /// 卡片可见状态
    @State private var cardsVisible_platbell = false
    
    /// 话题标签列表
    private var topicTags_platbell: [TopicTag_platbell] {
        localData_platbell.getTopicTags_platbell()
    }
    
    /// 热门话题帖子列表（只显示类型为1的话题帖子）
    private var hotPosts_platbell: [TitleModel_platbell] {
        titleVM_platbell.getTopicPosts_platbell()
            .sorted { $0.likes_platbell > $1.likes_platbell }
            .prefix(5)
            .map { $0 }
    }
    
    /// 推荐用户列表
    private var recommendedUsers_platbell: [PrewUserModel_platbell] {
        localData_platbell.getRecommendedUsers_platbell()
    }
    
    /// 混合探索内容（用户和帖子交替）
    private var mixedContent_platbell: [MixedContentItem_platbell] {
        var items_platbell: [MixedContentItem_platbell] = []
        
        let maxCount_platbell = max(hotPosts_platbell.count, recommendedUsers_platbell.count)
        
        for index_platbell in 0..<maxCount_platbell {
            // 添加热门帖子
            if index_platbell < hotPosts_platbell.count {
                items_platbell.append(.post_platbell(hotPosts_platbell[index_platbell]))
            }
            
            // 每隔2个帖子添加一个推荐用户
            if index_platbell % 2 == 0 && index_platbell / 2 < recommendedUsers_platbell.count {
                items_platbell.append(.user_platbell(recommendedUsers_platbell[index_platbell / 2]))
            }
        }
        
        return items_platbell
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundView_platbell
            
            // 主内容
            ScrollView {
                VStack(spacing: 0) {
                    // 顶部标题
                    headerView_platbell
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    
                    // 话题标签云（瀑布流布局）
                    topicTagsSection_platbell
                        .padding(.top, 20)
                    
                    // 探索内容标题
                    contentSectionHeader_platbell
                        .padding(.top, 24)
                        .padding(.horizontal, 16)
                    
                    // 混合探索内容
                    LazyVStack(spacing: 16) {
                        ForEach(mixedContent_platbell.indices, id: \.self) { index_platbell in
                            let item_platbell = mixedContent_platbell[index_platbell]
                            
                            mixedContentView_platbell(item_platbell: item_platbell, index_platbell: index_platbell)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 100) // 为底部导航栏留出空间
                }
            }
            .refreshable {
                await performRefresh_platbell()
            }
        }
        .onAppear {
            // 延迟显示卡片动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    cardsVisible_platbell = true
                }
            }
        }
    }
    
    // MARK: - 子视图
    
    /// 渐变背景
    private var backgroundView_platbell: some View {
        LinearGradient(
            colors: [
                ThemeColors_platbell.secondaryStart_platbell.opacity(0.1),
                ThemeColors_platbell.accentGreenStart_platbell.opacity(0.05),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// 顶部标题
    private var headerView_platbell: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                // 装饰性图标
                ZStack {
                    Circle()
                        .fill(
                            ThemeColors_platbell.gradient_platbell(at: 1)
                                .opacity(0.2)
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "safari")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(
                            ThemeColors_platbell.gradient_platbell(at: 1)
                        )
                        .rotationEffect(.degrees(0))
                        .continuousRotation_platbell(duration_platbell: 8.0)
                }
                .shadow(
                    color: ThemeColors_platbell.secondaryStart_platbell.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discover")
                        .font(.system(size: 32, weight: .bold))
                        .gradientText_platbell(gradientIndex_platbell: 1)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ThemeColors_platbell.accentGreenStart_platbell)
                        
                        Text("Explore the unknown")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // 统计信息卡片
            statsCard_platbell
        }
    }
    
    /// 统计信息卡片
    private var statsCard_platbell: some View {
        HStack(spacing: 12) {
            // 话题数量
            StatItemCompact_platbell(
                icon_platbell: "tag.fill",
                value_platbell: "\(hotPosts_platbell.count)",
                label_platbell: "Topics",
                gradientIndex_platbell: 1
            )
            
            // 创作者数量
            StatItemCompact_platbell(
                icon_platbell: "person.2.fill",
                value_platbell: "\(recommendedUsers_platbell.count)",
                label_platbell: "Creators",
                gradientIndex_platbell: 2
            )
            
            // 总点赞数
            StatItemCompact_platbell(
                icon_platbell: "heart.fill",
                value_platbell: "\(calculateTotalLikes_platbell())",
                label_platbell: "Likes",
                gradientIndex_platbell: 3
            )
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            ThemeColors_platbell.secondaryStart_platbell.opacity(0.3),
                            ThemeColors_platbell.accentGreenStart_platbell.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    /// 计算总点赞数
    private func calculateTotalLikes_platbell() -> Int {
        return hotPosts_platbell.reduce(0) { $0 + $1.likes_platbell }
    }
    
    /// 话题标签区域（瀑布流布局）
    private var topicTagsSection_platbell: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // 装饰性火焰动画
                ZStack {
                    Circle()
                        .fill(ThemeColors_platbell.gradient_platbell(at: 4).opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 4))
                }
                .breathing_platbell(isEnabled_platbell: true, duration_platbell: 2.0, scaleRange_platbell: 0.15)
                
                Text("Hot Topics")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 标签数量徽章
                HStack(spacing: 4) {
                    Text("\(collectAllTags_platbell().count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(ThemeColors_platbell.gradient_platbell(at: 1))
                )
            }
            .padding(.horizontal, 16)
            
            // 收集所有话题帖子的标签
            let allTags_platbell = collectAllTags_platbell()
            
            if !allTags_platbell.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    // 使用自然流式布局的标签云
                    AdaptiveTagCloud_platbell(
                        tags_platbell: allTags_platbell,
                        onTagTapped_platbell: { tag_platbell in
                            handleTagTapped_platbell(tag_platbell: tag_platbell)
                        }
                    )
                }
                .padding(16)
                .background(
                    ZStack {
                        // 主背景
                        Color(.systemBackground)
                        
                        // 渐变装饰
                        LinearGradient(
                            colors: [
                                ThemeColors_platbell.secondaryStart_platbell.opacity(0.08),
                                ThemeColors_platbell.accentGreenStart_platbell.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ThemeColors_platbell.secondaryStart_platbell.opacity(0.4),
                                    ThemeColors_platbell.accentGreenStart_platbell.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .padding(.horizontal, 16)
            }
        }
    }
    
    /// 收集所有话题帖子的标签（去重）
    private func collectAllTags_platbell() -> [String] {
        var tags_platbell = Set<String>()
        for post_platbell in hotPosts_platbell {
            for tag_platbell in post_platbell.tags_platbell {
                tags_platbell.insert(tag_platbell)
            }
        }
        return Array(tags_platbell).sorted()
    }
    
    
    /// 处理标签点击
    private func handleTagTapped_platbell(tag_platbell: String) {
        // 震动反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .light)
        impactFeedback_platbell.impactOccurred()
        
        Utils_platbell.showInfo_platbell(
            message_platbell: "Filtering by: \(tag_platbell)",
            delay_platbell: 1.5
        )
    }
    
    /// 探索内容区域标题
    private var contentSectionHeader_platbell: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Explore Content")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Topics and creators for you")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 随机推荐按钮
            Button(action: {
                shuffleContent_platbell()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 14, weight: .bold))
                    
                    Text("Shuffle")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(ThemeColors_platbell.gradient_platbell(at: 3))
                )
                .shadow(
                    color: ThemeColors_platbell.accentGreenStart_platbell.opacity(0.3),
                    radius: 6,
                    x: 0,
                    y: 3
                )
            }
        }
    }
    
    /// 打乱内容顺序
    private func shuffleContent_platbell() {
        withAnimation(AnimationPresets_platbell.standardSpring_platbell) {
            cardsVisible_platbell = false
        }
        
        // 震动反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback_platbell.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                cardsVisible_platbell = true
            }
        }
        
        Utils_platbell.showSuccess_platbell(
            message_platbell: "Content refreshed",
            delay_platbell: 1.0
        )
    }
    
    /// 混合内容视图
    @ViewBuilder
    private func mixedContentView_platbell(item_platbell: MixedContentItem_platbell, index_platbell: Int) -> some View {
        let gradientIndex_platbell = index_platbell % ThemeColors_platbell.allGradients_platbell.count
        
        // 添加内容类型标签
        VStack(alignment: .leading, spacing: 8) {
            // 类型标签
            contentTypeBadge_platbell(for: item_platbell, gradientIndex: gradientIndex_platbell)
            
            switch item_platbell {
            case .post_platbell(let post_platbell):
                HotPostCard_platbell(
                    post_platbell: post_platbell,
                    gradientIndex_platbell: gradientIndex_platbell,
                    isVisible_platbell: cardsVisible_platbell
                )
                
            case .user_platbell(let user_platbell):
                UserRecommendCard_platbell(
                    user_platbell: user_platbell,
                    gradientIndex_platbell: gradientIndex_platbell,
                    isVisible_platbell: cardsVisible_platbell
                )
            }
        }
    }
    
    /// 内容类型徽章
    @ViewBuilder
    private func contentTypeBadge_platbell(for item_platbell: MixedContentItem_platbell, gradientIndex: Int) -> some View {
        HStack {
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: getContentTypeIcon_platbell(for: item_platbell))
                    .font(.system(size: 10, weight: .bold))
                
                Text(getContentTypeText_platbell(for: item_platbell))
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(ThemeColors_platbell.gradient_platbell(at: gradientIndex))
            )
            .shadow(
                color: ThemeColors_platbell.allStartColors_platbell[gradientIndex % ThemeColors_platbell.allStartColors_platbell.count]
                    .opacity(0.3),
                radius: 6,
                x: 0,
                y: 3
            )
        }
        .padding(.horizontal, 16)
    }
    
    /// 获取内容类型图标
    private func getContentTypeIcon_platbell(for item_platbell: MixedContentItem_platbell) -> String {
        switch item_platbell {
        case .post_platbell:
            return "doc.text.fill"
        case .user_platbell:
            return "person.fill"
        }
    }
    
    /// 获取内容类型文字
    private func getContentTypeText_platbell(for item_platbell: MixedContentItem_platbell) -> String {
        switch item_platbell {
        case .post_platbell:
            return "Topic Post"
        case .user_platbell:
            return "Creator"
        }
    }
    
    // MARK: - 事件处理
    
    /// 执行刷新
    private func performRefresh_platbell() async {
        // 模拟刷新延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // 重新加载数据
        titleVM_platbell.initPosts_platbell()
    }
}

// MARK: - 自适应高度标签云容器
// 核心作用：手动计算并布局标签，实现自动换行和高度自适应
// 设计思路：使用 VStack + HStack 手动分行布局标签
// 关键功能：自适应高度、完整显示所有标签、自动换行

/// 自适应标签云组件
struct AdaptiveTagCloud_platbell: View {
    
    /// 标签数组
    let tags_platbell: [String]
    
    /// 点击回调
    let onTagTapped_platbell: (String) -> Void
    
    /// 屏幕宽度
    private let screenWidth_platbell = UIScreen.main.bounds.width
    
    /// 每个标签估算的宽度字典
    @State private var tagWidths_platbell: [String: CGFloat] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(arrangeTagsInRows_platbell(), id: \.self) { row_platbell in
                HStack(spacing: 10) {
                    ForEach(row_platbell, id: \.self) { tag_platbell in
                        let index_platbell = tags_platbell.firstIndex(of: tag_platbell) ?? 0
                        TagChip_platbell(
                            text_platbell: tag_platbell,
                            gradientIndex_platbell: index_platbell % ThemeColors_platbell.allGradients_platbell.count,
                            isClickable_platbell: true,
                            onTapped_platbell: onTagTapped_platbell
                        )
                    }
                    
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// 将标签分行排列
    /// - Returns: 二维数组，每个子数组代表一行的标签
    private func arrangeTagsInRows_platbell() -> [[String]] {
        var rows_platbell: [[String]] = []
        var currentRow_platbell: [String] = []
        var currentRowWidth_platbell: CGFloat = 0
        
        // 容器可用宽度 = 屏幕宽度 - 左右 padding(16*2) - 卡片内 padding(16*2)
        let availableWidth_platbell = screenWidth_platbell - 64
        
        for tag_platbell in tags_platbell {
            let tagWidth_platbell = estimateTagWidth_platbell(tag_platbell: tag_platbell)
            
            // 检查当前行是否能容纳这个标签
            if currentRowWidth_platbell + tagWidth_platbell + (currentRow_platbell.isEmpty ? 0 : 10) <= availableWidth_platbell {
                // 可以放在当前行
                currentRow_platbell.append(tag_platbell)
                currentRowWidth_platbell += tagWidth_platbell + (currentRow_platbell.count > 1 ? 10 : 0)
            } else {
                // 需要换行
                if !currentRow_platbell.isEmpty {
                    rows_platbell.append(currentRow_platbell)
                }
                currentRow_platbell = [tag_platbell]
                currentRowWidth_platbell = tagWidth_platbell
            }
        }
        
        // 添加最后一行
        if !currentRow_platbell.isEmpty {
            rows_platbell.append(currentRow_platbell)
        }
        
        return rows_platbell
    }
    
    /// 估算标签宽度
    /// - Parameter tag_platbell: 标签文本
    /// - Returns: 估算的宽度值
    private func estimateTagWidth_platbell(tag_platbell: String) -> CGFloat {
        // 图标宽度(8) + 间距(4) + 文字宽度 + 左右padding(14*2)
        let iconWidth_platbell: CGFloat = 8
        let spacing_platbell: CGFloat = 4
        let padding_platbell: CGFloat = 28
        
        // 估算文字宽度：每个字符约 8.5 点
        let textWidth_platbell = CGFloat(tag_platbell.count) * 8.5
        
        return iconWidth_platbell + spacing_platbell + textWidth_platbell + padding_platbell
    }
}

// MARK: - 混合内容项枚举

/// 混合内容项
enum MixedContentItem_platbell {
    case post_platbell(TitleModel_platbell)
    case user_platbell(PrewUserModel_platbell)
}

// MARK: - 预览

#Preview {
    Discover_platbell()
        .onAppear {
            LocalData_platbell.shared_platbell.initData_platbell()
            TitleViewModel_platbell.shared_platbell.initPosts_platbell()
            UserViewModel_platbell.shared_platbell.initUser_platbell()
        }
}
