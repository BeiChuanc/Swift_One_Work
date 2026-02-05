import SwiftUI

// MARK: - 灵感活动详情页
// 核心作用：展示官方灵感活动的详细信息，并提供灵感评论区
// 设计思路：顶部展示活动描述，下方为灵感评论区，用户可发布灵感
// 关键功能：查看活动详情、发布灵感评论、显示参与状态

/// 灵感活动详情页视图
struct InspirationDetail_lite: View {
    
    let challenge_lite: OutfitChallenge_lite
    
    @ObservedObject private var titleVM_lite = TitleViewModel_lite.shared_lite
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var localData_lite = LocalData_lite.shared_lite
    
    @State private var inspirationText_lite = ""
    @State private var isPosting_lite = false
    @FocusState private var isTextFieldFocused_lite: Bool
    
    /// 获取最新的挑战数据（从LocalData实时获取）
    private var currentChallenge_lite: OutfitChallenge_lite? {
        localData_lite.challengeList_lite.first(where: { $0.challengeId_lite == challenge_lite.challengeId_lite })
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                colors: [
                    Color(hex: "667eea").opacity(0.05),
                    Color(hex: "764ba2").opacity(0.03),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 自定义顶部导航栏
                customHeaderView_lite
                
                // 顶部活动描述区域
                ScrollView {
                    VStack(spacing: 24.h_lite) {
                        // 活动头部卡片
                        activityHeaderCard_lite
                            .padding(.horizontal, 20.w_lite)
                            .padding(.top, 20.h_lite)
                        
                        // 活动描述
                        activityDescriptionSection_lite
                            .padding(.horizontal, 20.w_lite)
                        
                        // 灵感评论区标题
                        inspirationSectionHeader_lite
                            .padding(.horizontal, 20.w_lite)
                            .padding(.top, 12.h_lite)
                        
                        // 灵感评论列表
                        inspirationCommentsList_lite
                            .padding(.horizontal, 20.w_lite)
                            .padding(.bottom, 100.h_lite)
                    }
                }
                
                // 底部输入框
                inspirationInputBar_lite
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - 自定义顶部导航栏
    
    /// 自定义顶部导航栏
    private var customHeaderView_lite: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12.w_lite) {
                // 返回按钮（增强版）
                Button {
                    Router_lite.shared_lite.pop_lite()
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white, Color(hex: "F8F9FA")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44.w_lite, height: 44.h_lite)
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20.sp_lite, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "f093fb").opacity(0.3), Color(hex: "f5576c").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color(hex: "f093fb").opacity(0.3), radius: 15, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(ScaleButtonStyle_lite())
                
                // 页面标题
                VStack(alignment: .leading, spacing: 4.h_lite) {
                    Text("Inspiration Event")
                        .font(.system(size: 28.sp_lite, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "212529"), Color(hex: "495057")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Share your creative ideas")
                        .font(.system(size: 13.sp_lite, weight: .medium))
                        .foregroundColor(Color(hex: "6C757D"))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20.w_lite)
            .padding(.top, 12.h_lite)
            .padding(.bottom, 16.h_lite)
            .background(
                Color.white
                    .ignoresSafeArea(edges: .top)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - 活动头部卡片
    
    /// 活动头部卡片视图
    private var activityHeaderCard_lite: some View {
        VStack(alignment: .leading, spacing: 18.h_lite) {
            // 基础单品图标
            HStack(spacing: 16.w_lite) {
                ZStack {
                    // 背景光晕
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: MediaConfig_lite.getGradientColors_lite(for: challenge_lite.baseItem_lite.itemName_lite).map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72.w_lite, height: 72.h_lite)
                        .blur(radius: 8)
                    
                    // 主图标
                    Image(systemName: challenge_lite.baseItem_lite.itemImage_lite)
                        .font(.system(size: 28.sp_lite, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 64.w_lite, height: 64.h_lite)
                        .background(
                            ZStack {
                                LinearGradient(
                                    colors: MediaConfig_lite.getGradientColors_lite(for: challenge_lite.baseItem_lite.itemName_lite),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                // 高光
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        )
                        .cornerRadius(18.w_lite)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18.w_lite)
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                
                VStack(alignment: .leading, spacing: 8.h_lite) {
                    // 官方标识
                    HStack(spacing: 5.w_lite) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13.sp_lite, weight: .bold))
                        
                        Text("Official Event")
                            .font(.system(size: 12.sp_lite, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "FFC107"))
                    .padding(.horizontal, 10.w_lite)
                    .padding(.vertical, 5.h_lite)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(Color(hex: "FFC107").opacity(0.15))
                            
                            Capsule()
                                .stroke(Color(hex: "FFC107").opacity(0.3), lineWidth: 1)
                        }
                    )
                    
                    Text(challenge_lite.challengeTitle_lite)
                        .font(.system(size: 19.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "212529"))
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            // 统计信息
            HStack(spacing: 24.w_lite) {
                HStack(spacing: 8.w_lite) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "667eea").opacity(0.15))
                            .frame(width: 32.w_lite, height: 32.h_lite)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "667eea"))
                    }
                    
                    VStack(alignment: .leading, spacing: 2.h_lite) {
                        Text("\(currentChallenge_lite?.submissions_lite.count ?? 0)")
                            .font(.system(size: 16.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "212529"))
                        
                        Text("participated")
                            .font(.system(size: 11.sp_lite, weight: .medium))
                            .foregroundColor(Color(hex: "6C757D"))
                    }
                }
                
                HStack(spacing: 8.w_lite) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "f093fb").opacity(0.15))
                            .frame(width: 32.w_lite, height: 32.h_lite)
                        
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "f093fb"))
                    }
                    
                    VStack(alignment: .leading, spacing: 2.h_lite) {
                        Text(daysRemainingNumber_lite(endDate_lite: challenge_lite.endDate_lite))
                            .font(.system(size: 16.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "212529"))
                        
                        Text("days left")
                            .font(.system(size: 11.sp_lite, weight: .medium))
                            .foregroundColor(Color(hex: "6C757D"))
                    }
                }
            }
        }
        .padding(22.w_lite)
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color.white, Color(hex: "F8F9FA")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // 装饰性元素
                Circle()
                    .fill(Color(hex: "667eea").opacity(0.05))
                    .frame(width: 100.w_lite, height: 100.h_lite)
                    .offset(x: 120.w_lite, y: -40.h_lite)
                    .blur(radius: 20)
            }
        )
        .cornerRadius(24.w_lite)
        .overlay(
            RoundedRectangle(cornerRadius: 24.w_lite)
                .stroke(
                    LinearGradient(
                        colors: [Color.white, Color(hex: "E9ECEF")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - 活动描述区域
    
    /// 活动描述区域视图
    private var activityDescriptionSection_lite: some View {
        VStack(alignment: .leading, spacing: 14.h_lite) {
            HStack(spacing: 8.w_lite) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 14.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                
                Text("Event Description")
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
            }
            
            Text(challenge_lite.challengeDescription_lite)
                .font(.system(size: 15.sp_lite, weight: .regular))
                .foregroundColor(Color(hex: "495057"))
                .lineSpacing(4)
                .padding(16.w_lite)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16.w_lite)
                            .fill(Color.white)
                        
                        RoundedRectangle(cornerRadius: 16.w_lite)
                            .stroke(Color(hex: "E9ECEF"), lineWidth: 1)
                    }
                )
        }
    }
    
    // MARK: - 灵感评论区标题
    
    /// 灵感评论区标题视图
    private var inspirationSectionHeader_lite: some View {
        HStack(spacing: 8.w_lite) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16.sp_lite, weight: .bold))
                .foregroundColor(Color(hex: "FFC107"))
            
            Text("Inspiration Gallery")
                .font(.system(size: 18.sp_lite, weight: .bold))
                .foregroundColor(Color(hex: "212529"))
            
            Spacer()
            
            Text("\(currentChallenge_lite?.submissions_lite.count ?? 0)")
                .font(.system(size: 14.sp_lite, weight: .bold))
                .foregroundColor(Color(hex: "667eea"))
                .padding(.horizontal, 10.w_lite)
                .padding(.vertical, 4.h_lite)
                .background(Color(hex: "667eea").opacity(0.15))
                .cornerRadius(8.w_lite)
        }
    }
    
    // MARK: - 灵感评论列表
    
    /// 灵感评论列表视图
    private var inspirationCommentsList_lite: some View {
        VStack(spacing: 16.h_lite) {
            if let currentChallenge_lite = currentChallenge_lite {
                if currentChallenge_lite.submissions_lite.isEmpty {
                    emptyInspirationView_lite
                        .padding(.vertical, 40.h_lite)
                } else {
                    ForEach(currentChallenge_lite.submissions_lite) { submission_lite in
                        InspirationCommentCard_lite(
                            submission_lite: submission_lite,
                            challenge_lite: currentChallenge_lite
                        )
                    }
                }
            } else {
                emptyInspirationView_lite
                    .padding(.vertical, 40.h_lite)
            }
        }
    }
    
    /// 空状态视图
    private var emptyInspirationView_lite: some View {
        VStack(spacing: 16.h_lite) {
            Image(systemName: "lightbulb.slash")
                .font(.system(size: 50.sp_lite))
                .foregroundColor(Color(hex: "ADB5BD"))
            
            Text("No Inspiration Yet")
                .font(.system(size: 16.sp_lite, weight: .semibold))
                .foregroundColor(Color(hex: "495057"))
            
            Text("Be the first to share your inspiration!")
                .font(.system(size: 14.sp_lite, weight: .regular))
                .foregroundColor(Color(hex: "6C757D"))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 底部输入框
    
    /// 底部输入框视图
    private var inspirationInputBar_lite: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(hex: "E9ECEF"))
            
            HStack(spacing: 12.w_lite) {
                // 输入框
                TextField("Share your inspiration...", text: $inspirationText_lite, axis: .vertical)
                    .font(.system(size: 15.sp_lite, weight: .medium))
                    .padding(.horizontal, 16.w_lite)
                    .padding(.vertical, 12.h_lite)
                    .lineLimit(1...4)
                    .background(
                        RoundedRectangle(cornerRadius: 20.w_lite)
                            .fill(Color(hex: "F8F9FA"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20.w_lite)
                            .stroke(
                                isTextFieldFocused_lite ?
                                    Color(hex: "667eea").opacity(0.3) :
                                    Color(hex: "E9ECEF"),
                                lineWidth: 1.5
                            )
                    )
                    .focused($isTextFieldFocused_lite)
                
                // 发送按钮
                Button {
                    postInspiration_lite()
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: inspirationText_lite.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                        [Color(hex: "ADB5BD"), Color(hex: "CED4DA")] :
                                        [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44.w_lite, height: 44.h_lite)
                        
                        Image(systemName: isPosting_lite ? "hourglass" : "paperplane.fill")
                            .font(.system(size: 18.sp_lite, weight: .bold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isPosting_lite ? 0 : 45))
                    }
                }
                .disabled(inspirationText_lite.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting_lite)
                .buttonStyle(ScaleButtonStyle_lite())
            }
            .padding(.horizontal, 16.w_lite)
            .padding(.vertical, 12.h_lite)
            .background(
                Color.white
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
    
    // MARK: - 私有方法
    
    /// 发布灵感
    private func postInspiration_lite() {
        let content_lite = inspirationText_lite.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !content_lite.isEmpty else { return }
        guard userVM_lite.isLoggedIn_lite else {
            // 直接跳转到登录页
            Router_lite.shared_lite.toLogin_liteui()
            return
        }
        
        isPosting_lite = true
        
        // 发布灵感评论
        titleVM_lite.releaseInspirationComment_lite(
            challenge_lite: challenge_lite,
            content_lite: content_lite
        )
        
        // 清空输入框
        inspirationText_lite = ""
        isTextFieldFocused_lite = false
        isPosting_lite = false
    }
    
    /// 计算剩余天数数字
    private func daysRemainingNumber_lite(endDate_lite: Date) -> String {
        let days_lite = Calendar.current.dateComponents([.day], from: Date(), to: endDate_lite).day ?? 0
        return days_lite > 0 ? "\(days_lite)" : "0"
    }
}

// MARK: - 灵感评论卡片组件

/// 灵感评论卡片视图
struct InspirationCommentCard_lite: View {
    
    let submission_lite: OutfitCombo_lite
    let challenge_lite: OutfitChallenge_lite
    
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @State private var showReportSheet_lite = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14.h_lite) {
            // 用户信息
            HStack(spacing: 10.w_lite) {
                // 用户头像 - 使用UserAvatarView_lite组件
                UserAvatarView_lite(
                    userId_lite: submission_lite.userId_lite ?? 0,
                    size_lite: 36
                )
                
                VStack(alignment: .leading, spacing: 2.h_lite) {
                    Text(getUserName_lite())
                        .font(.system(size: 14.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "212529"))
                    
                    Text(timeAgo_lite(from: submission_lite.createDate_lite))
                        .font(.system(size: 12.sp_lite, weight: .medium))
                        .foregroundColor(Color(hex: "6C757D"))
                }
                
                Spacer()
                
                // 举报按钮
                Button {
                    showReportSheet_lite = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "F8F9FA"))
                            .frame(width: 32.w_lite, height: 32.h_lite)
                        
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 16.sp_lite, weight: .semibold))
                            .foregroundColor(Color(hex: "ADB5BD"))
                    }
                }
                .buttonStyle(ScaleButtonStyle_lite())
            }
            
            // 灵感内容
            Text(submission_lite.comboTitle_lite)
                .font(.system(size: 15.sp_lite, weight: .regular))
                .foregroundColor(Color(hex: "212529"))
                .lineSpacing(4)
            
            // 分隔线
            Rectangle()
                .fill(Color(hex: "E9ECEF"))
                .frame(height: 1)
        }
        .padding(18.w_lite)
        .background(
            RoundedRectangle(cornerRadius: 16.w_lite)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16.w_lite)
                .stroke(Color(hex: "E9ECEF"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .confirmationDialog("More", isPresented: $showReportSheet_lite, titleVisibility: .visible) {
            Button("Report Sexually Explicit Material") {
                reportInspirationComment_lite()
            }
            
            Button("Report spam") {
                reportInspirationComment_lite()
            }
            
            Button("Report something else") {
                reportInspirationComment_lite()
            }
            
            Button("Report", role: .destructive) {
                reportInspirationComment_lite()
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("")
        }
    }
    
    /// 举报灵感评论
    private func reportInspirationComment_lite() {
        ReportHelper_lite.reportInspirationComment_lite(
            inspirationComment_lite: submission_lite,
            challenge_lite: challenge_lite
        )
    }
    
    /// 获取用户名
    private func getUserName_lite() -> String {
        if let userId_lite = submission_lite.userId_lite {
            let user_lite = userVM_lite.getUserById_lite(userId_lite: userId_lite)
            return user_lite.userName_lite ?? "User \(userId_lite)"
        }
        return "Unknown User"
    }
    
    /// 计算时间差
    private func timeAgo_lite(from date_lite: Date) -> String {
        let components_lite = Calendar.current.dateComponents([.minute, .hour, .day], from: date_lite, to: Date())
        
        if let days_lite = components_lite.day, days_lite > 0 {
            return "\(days_lite)d ago"
        } else if let hours_lite = components_lite.hour, hours_lite > 0 {
            return "\(hours_lite)h ago"
        } else if let minutes_lite = components_lite.minute, minutes_lite > 0 {
            return "\(minutes_lite)m ago"
        } else {
            return "Just now"
        }
    }
}
