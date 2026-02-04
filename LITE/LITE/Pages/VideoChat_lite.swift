import SwiftUI

// MARK: - 视频通话界面
// 核心作用：模拟视频通话界面，展示对方头像和操作按钮
// 设计思路：现代化SwiftUI视觉效果，包含头像、水波纹动画、挂断按钮、举报按钮
// 关键功能：头像展示、水波纹动画、通话控制、举报功能

/// 视频通话页面
struct VideoChat_lite: View {
    
    // MARK: - 属性
    
    /// 通话用户信息
    let user_lite: PrewUserModel_lite
    
    /// 路由管理器
    @ObservedObject var router_lite = Router_lite.shared_lite
    @ObservedObject var localData_lite = LocalData_lite.shared_lite
    
    /// 状态
    @State private var showReportSheet_lite: Bool = false
    @State private var rippleScale_lite: [CGFloat] = [1.0, 1.0, 1.0]
    @State private var rippleOpacity_lite: [Double] = [0.0, 0.0, 0.0]
    @State private var buttonScale_lite: CGFloat = 1.0
    @State private var showContent_lite: Bool = false
    @State private var showReportButton_lite: Bool = false
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 中间头像和信息
            if showContent_lite {
                centerContent_lite
                    .transition(.opacity)
            }
            
            // 底部挂断按钮（使用VStack定位）
            VStack {
                Spacer()
                
                if showContent_lite {
                    bottomControls_lite
                        .transition(.opacity)
                }
            }
            
            // 顶部举报按钮（最上层）
            VStack {
                HStack {
                    Spacer()
                    
                    if showReportButton_lite {
                        // 举报按钮
                        Button(action: {
                            // 触觉反馈
                            let generator_lite = UIImpactFeedbackGenerator(style: .medium)
                            generator_lite.impactOccurred()
                            
                            showReportSheet_lite = true
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 36.sp_lite, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(.top, 50.h_lite)
                .padding(.trailing, 20.w_lite)
                
                Spacer()
            }
            
            // 举报ActionSheet
            ReportActionSheet_lite(
                isShowing_lite: $showReportSheet_lite,
                isBlockUser_lite: true,
                onConfirm_lite: {
                    handleBlockUser_lite()
                }
            )
        }
        .background(
            // 背景层作为background修饰符，完全独立，不影响主内容布局
            backgroundView_lite
        )
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .onAppear {
            startAnimations_lite()
        }
    }
    
    // MARK: - 背景视图
    
    /// 背景视图
    /// 核心作用：展示模糊的用户头像背景，营造沉浸式通话氛围
    private var backgroundView_lite: some View {
        ZStack {
            // 用户头像作为背景
            if let avatarPath_lite = user_lite.userHead_lite,
               let image_lite = UIImage(named: avatarPath_lite) {
                Image(uiImage: image_lite)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                // 默认渐变背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "667EEA"),
                        Color(hex: "764BA2")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            // 模糊效果
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // 渐变遮罩
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - 中间内容
    
    /// 中间内容（头像和信息）
    /// 核心作用：展示对方头像、水波纹动画、用户名和状态
    private var centerContent_lite: some View {
        VStack(spacing: 24.h_lite) {
            // 头像和水波纹
            ZStack {
                // 水波纹动画层
                ForEach(0..<3) { index_lite in
                    Circle()
                        .stroke(Color(hex: "667EEA"), lineWidth: 2)
                        .frame(width: 126.w_lite, height: 126.h_lite)
                        .scaleEffect(rippleScale_lite[index_lite])
                        .opacity(rippleOpacity_lite[index_lite])
                }
                
                // 用户头像
                UserAvatarView_lite(
                    userId_lite: user_lite.userId_lite ?? 0,
                    size_lite: 126.w_lite
                )
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 4.w_lite)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            }
            .frame(width: 180.w_lite, height: 180.h_lite)
            
            // 用户名
            Text(user_lite.userName_lite ?? "User")
                .font(.system(size: 28.sp_lite, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // 状态标签
            Text("Calling...")
                .font(.system(size: 16.sp_lite, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .scaleEffect(showContent_lite ? 1.0 : 0.8)
        .opacity(showContent_lite ? 1.0 : 0.0)
    }
    
    // MARK: - 底部控制
    
    /// 底部控制按钮
    /// 核心作用：展示挂断按钮
    private var bottomControls_lite: some View {
        Button(action: {
            handleHangUp_lite()
        }) {
            ZStack {
                // 按钮背景
                Capsule()
                    .fill(Color(hex: "FF6B9D"))
                    .frame(width: 120.w_lite, height: 70.h_lite)
                    .shadow(color: Color(hex: "FF6B9D").opacity(0.4), radius: 16, x: 0, y: 8)
                
                // 挂断图标
                Image(systemName: "phone.down.fill")
                    .font(.system(size: 32.sp_lite, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(buttonScale_lite)
        }
        .padding(.bottom, 80.h_lite)
    }
    
    // MARK: - 动画方法
    
    /// 启动所有动画
    /// 核心作用：启动水波纹动画和内容渐入动画，背景完全显示后再显示举报按钮
    private func startAnimations_lite() {
        // 立即显示举报按钮（测试布局）
        showReportButton_lite = true
        
        // 延迟显示内容
        withAnimation(.easeIn(duration: 0.6).delay(0.2)) {
            showContent_lite = true
        }
        
        // 启动水波纹动画
        startRippleAnimation_lite()
        
        // 启动按钮摇摆动画
        startButtonSwayAnimation_lite()
    }
    
    /// 启动水波纹动画
    /// 核心作用：为头像添加扩散的水波纹效果
    private func startRippleAnimation_lite() {
        for index_lite in 0..<3 {
            // 每个水波纹延迟启动
            let delay_lite = Double(index_lite) * 0.66
            
            // 缩放动画
            withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false).delay(delay_lite)) {
                rippleScale_lite[index_lite] = 1.8
            }
            
            // 透明度动画
            withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false).delay(delay_lite)) {
                rippleOpacity_lite[index_lite] = 0.0
            }
            
            // 重置初始值以触发动画
            DispatchQueue.main.asyncAfter(deadline: .now() + delay_lite) {
                rippleOpacity_lite[index_lite] = 0.6
            }
        }
    }
    
    /// 启动按钮摇摆动画
    /// 核心作用：挂断按钮轻微摇摆，增强视觉吸引力
    private func startButtonSwayAnimation_lite() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.6)) {
            buttonScale_lite = 1.05
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理挂断通话
    /// 核心作用：挂断通话并返回上一页
    private func handleHangUp_lite() {
        // 触觉反馈
        let generator_lite = UINotificationFeedbackGenerator()
        generator_lite.notificationOccurred(.success)
        
        // 缩放动画
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            buttonScale_lite = 0.9
        }
        
        // 延迟关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            router_lite.dismissFullScreen_lite()
        }
        
        print("📞 挂断视频通话")
    }
    
    /// 处理拉黑用户
    /// 核心作用：拉黑用户后关闭通话并返回（从ReportActionSheet回调）
    private func handleBlockUser_lite() {
        Utils_lite.showLoading_lite(message_lite: "Processing...")
        
        // 拉黑用户
        ReportHelper_lite.blockUser_lite(user_lite: user_lite) {
            Utils_lite.dismissLoading_lite()
            
            // 关闭视频通话
            router_lite.dismissFullScreen_lite()
            
            // 返回上一页
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                router_lite.pop_lite()
            }
        }
    }
}
