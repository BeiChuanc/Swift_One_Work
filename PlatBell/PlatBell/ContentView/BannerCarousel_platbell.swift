import SwiftUI

// MARK: - 轮播图组件
// 核心作用：展示轮播图，支持自动滚动和手动滑动
// 设计思路：TabView + 圆角卡片 + 自动轮播 + 渐变背景
// 关键功能：自动轮播、指示器、点击查看详情

/// 轮播图数据模型
struct BannerItem_platbell: Identifiable {
    let id: Int
    let user_platbell: PrewUserModel_platbell
    let gradientIndex_platbell: Int
}

/// 轮播图组件
struct BannerCarousel_platbell: View {
    
    @ObservedObject var localData_platbell = LocalData_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    /// 当前选中的索引
    @State private var currentIndex_platbell: Int = 0
    
    /// 自动滚动定时器
    @State private var timer_platbell: Timer?
    
    /// 轮播图高度
    let height_platbell: CGFloat = 200
    
    /// 圆角
    let cornerRadius_platbell: CGFloat = 20
    
    /// 轮播项目
    private var bannerItems_platbell: [BannerItem_platbell] {
        localData_platbell.userList_platbell.enumerated().map { index_platbell, user_platbell in
            BannerItem_platbell(
                id: index_platbell,
                user_platbell: user_platbell,
                gradientIndex_platbell: index_platbell
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 轮播图主体
            TabView(selection: $currentIndex_platbell) {
                ForEach(bannerItems_platbell) { item_platbell in
                    BannerCard_platbell(
                        user_platbell: item_platbell.user_platbell,
                        gradientIndex_platbell: item_platbell.gradientIndex_platbell
                    )
                    .tag(item_platbell.id)
                    .onTapGesture {
                        router_platbell.toUserInfo_platbell(user_platbell: item_platbell.user_platbell)
                    }
                }
            }
            .frame(height: height_platbell)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .cornerRadius(cornerRadius_platbell)
            .padding(.horizontal, 16)
            
            // 自定义指示器
            PageIndicator_platbell(
                numberOfPages_platbell: bannerItems_platbell.count,
                currentPage_platbell: currentIndex_platbell
            )
        }
        .onAppear {
            startAutoScroll_platbell()
        }
        .onDisappear {
            stopAutoScroll_platbell()
        }
    }
    
    // MARK: - 自动滚动
    
    /// 开始自动滚动
    private func startAutoScroll_platbell() {
        timer_platbell = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex_platbell = (currentIndex_platbell + 1) % bannerItems_platbell.count
            }
        }
    }
    
    /// 停止自动滚动
    private func stopAutoScroll_platbell() {
        timer_platbell?.invalidate()
        timer_platbell = nil
    }
}

// MARK: - 轮播图卡片

/// 轮播图卡片
struct BannerCard_platbell: View {
    
    /// 用户数据
    let user_platbell: PrewUserModel_platbell
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    var body: some View {
        ZStack {
            // 用户相册背景
            if let albumImage_platbell = user_platbell.userMedia_platbell?.first {
                Image(albumImage_platbell)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                // 降级方案：使用渐变背景
                ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                    .opacity(0.8)
            }
            
            // 半透明遮罩层（增强文字可读性）
            LinearGradient(
                colors: [
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 内容层
            HStack(spacing: 20) {
                // 用户头像
                UserAvatarView_platbell(
                    userId_platbell: user_platbell.userId_platbell ?? 0,
                    size_platbell: 100,
                    isClickable_platbell: false
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 10,
                    x: 0,
                    y: 5
                )
                
                // 用户信息
                VStack(alignment: .leading, spacing: 8) {
                    Text(user_platbell.userName_platbell ?? "User")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(user_platbell.userIntroduce_platbell ?? "No introduction yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                    
                    // 统计信息
                    HStack(spacing: 16) {
                        BannerStatBadge_platbell(
                            icon_platbell: "person.2.fill",
                            count_platbell: user_platbell.userFollow_platbell ?? 0,
                            color_platbell: .white
                        )
                        
                        BannerStatBadge_platbell(
                            icon_platbell: "heart.fill",
                            count_platbell: user_platbell.userFans_platbell ?? 0,
                            color_platbell: .white
                        )
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
        }
    }
    
}

// MARK: - 统计徽章（轮播图专用）

/// 统计徽章组件（轮播图专用，白色样式）
private struct BannerStatBadge_platbell: View {
    
    let icon_platbell: String
    let count_platbell: Int
    let color_platbell: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon_platbell)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color_platbell)
            
            Text("\(count_platbell)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color_platbell)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.2))
        )
    }
}

// MARK: - 页面指示器

/// 自定义页面指示器
struct PageIndicator_platbell: View {
    
    /// 总页数
    let numberOfPages_platbell: Int
    
    /// 当前页
    let currentPage_platbell: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages_platbell, id: \.self) { index_platbell in
                Circle()
                    .fill(
                        index_platbell == currentPage_platbell
                            ? ThemeColors_platbell.primaryStart_platbell
                            : Color(.systemGray4)
                    )
                    .frame(
                        width: index_platbell == currentPage_platbell ? 8 : 6,
                        height: index_platbell == currentPage_platbell ? 8 : 6
                    )
                    .scaleEffect(index_platbell == currentPage_platbell ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage_platbell)
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - 预览

#Preview {
    VStack {
        BannerCarousel_platbell()
        Spacer()
    }
    .background(Color(.systemBackground))
    .onAppear {
        LocalData_platbell.shared_platbell.initData_platbell()
    }
}
