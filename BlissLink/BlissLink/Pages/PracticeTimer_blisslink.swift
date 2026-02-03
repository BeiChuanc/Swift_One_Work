import SwiftUI

// MARK: - 练习计时页面
// 核心作用：记录练习时长，累计到用户总时长
// 设计思路：简洁的计时器界面，开始/暂停/完成功能
// 关键功能：计时、暂停、保存练习记录

/// 练习计时页面
struct PracticeTimer_blisslink: View {
    
    // MARK: - ViewModels
    
    @ObservedObject var practiceVM_blisslink = PracticeViewModel_blisslink.shared_blisslink
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    // MARK: - 状态
    
    @State private var elapsedTime_blisslink: Int = 0  // 秒
    @State private var isRunning_blisslink: Bool = false
    @State private var timer_blisslink: Timer?
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 背景层
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "667EEA"),
                        Color(hex: "764BA2"),
                        Color(hex: "FA8BFF")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 装饰圆圈
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 300.w_baseswiftui, height: 300.h_baseswiftui)
                    .offset(x: -150.w_baseswiftui, y: -200.h_baseswiftui)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 350.w_baseswiftui, height: 350.h_baseswiftui)
                    .offset(x: 170.w_baseswiftui, y: 400.h_baseswiftui)
                    .blur(radius: 60)
            }
            .ignoresSafeArea()
            
            // 内容层
            VStack(spacing: 0) {
                // 顶部导航栏
                topNavigationBar_blisslink
                
                Spacer()
                
                // 计时器显示
                timerDisplay_blisslink
                
                Spacer()
                
                // 控制按钮
                controlButtons_blisslink
                    .padding(.bottom, 80.h_baseswiftui)
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            stopTimer_blisslink()
        }
    }
    
    // MARK: - 顶部导航栏
    
    private var topNavigationBar_blisslink: some View {
        HStack {
            // 返回按钮
            Button(action: {
                handleBack_blisslink()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 36.w_baseswiftui, height: 36.h_baseswiftui)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16.sp_baseswiftui, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            // 标题
            Text("Practice Timer")
                .font(.system(size: 18.sp_baseswiftui, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // 占位
            Color.clear
                .frame(width: 36.w_baseswiftui, height: 36.h_baseswiftui)
        }
        .padding(.horizontal, 20.w_baseswiftui)
        .padding(.top, 10.h_baseswiftui)
        .padding(.bottom, 12.h_baseswiftui)
    }
    
    // MARK: - 计时器显示
    
    private var timerDisplay_blisslink: some View {
        VStack(spacing: 30.h_baseswiftui) {
            // 图标
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 120.w_baseswiftui, height: 120.h_baseswiftui)
                    .blur(radius: 20)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100.w_baseswiftui, height: 100.h_baseswiftui)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                
                Image(systemName: isRunning_blisslink ? "figure.yoga" : "timer")
                    .font(.system(size: 50.sp_baseswiftui, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .floatingAnimation_blisslink()
            
            // 时间显示
            Text(formattedTime_blisslink)
                .font(.system(size: 64.sp_baseswiftui, weight: .bold))
                .foregroundColor(.white)
                .monospacedDigit()
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            // 状态文字
            Text(isRunning_blisslink ? "Keep going!" : "Ready to practice")
                .font(.system(size: 18.sp_baseswiftui, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    // MARK: - 控制按钮
    
    private var controlButtons_blisslink: some View {
        HStack(spacing: 20.w_baseswiftui) {
            // 重置按钮
            if elapsedTime_blisslink > 0 {
                Button(action: {
                    handleReset_blisslink()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 60.w_baseswiftui, height: 60.h_baseswiftui)
                        
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 24.sp_baseswiftui, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 开始/暂停按钮
            Button(action: {
                handleStartPause_blisslink()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80.w_baseswiftui, height: 80.h_baseswiftui)
                        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
                    
                    Image(systemName: isRunning_blisslink ? "pause.fill" : "play.fill")
                        .font(.system(size: 32.sp_baseswiftui, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .offset(x: isRunning_blisslink ? 0 : 3.w_baseswiftui)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isRunning_blisslink ? 1.0 : 1.05)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isRunning_blisslink)
            
            // 完成按钮
            if elapsedTime_blisslink > 0 {
                Button(action: {
                    handleFinish_blisslink()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 60.w_baseswiftui, height: 60.h_baseswiftui)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 24.sp_baseswiftui, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - 计算属性
    
    /// 格式化时间显示 (HH:MM:SS)
    private var formattedTime_blisslink: String {
        let hours_blisslink = elapsedTime_blisslink / 3600
        let minutes_blisslink = (elapsedTime_blisslink % 3600) / 60
        let seconds_blisslink = elapsedTime_blisslink % 60
        
        return String(format: "%02d:%02d:%02d", hours_blisslink, minutes_blisslink, seconds_blisslink)
    }
    
    // MARK: - 事件处理
    
    /// 处理返回
    private func handleBack_blisslink() {
        if isRunning_blisslink {
            // 如果正在计时，提示用户
            Utils_baseswiftui.showWarning_baseswiftui(
                message_baseswiftui: "Please pause or finish your practice first.",
                delay_baseswiftui: 2.0
            )
            return
        }
        
        router_baseswiftui.pop_baseswiftui()
    }
    
    /// 处理开始/暂停
    private func handleStartPause_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        if isRunning_blisslink {
            // 暂停
            stopTimer_blisslink()
        } else {
            // 开始
            startTimer_blisslink()
        }
    }
    
    /// 开始计时
    private func startTimer_blisslink() {
        isRunning_blisslink = true
        
        timer_blisslink = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime_blisslink += 1
        }
    }
    
    /// 停止计时
    private func stopTimer_blisslink() {
        isRunning_blisslink = false
        timer_blisslink?.invalidate()
        timer_blisslink = nil
    }
    
    /// 处理重置
    private func handleReset_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        stopTimer_blisslink()
        elapsedTime_blisslink = 0
    }
    
    /// 处理完成
    private func handleFinish_blisslink() {
        // 检查是否登录
        if !userVM_baseswiftui.isLoggedIn_baseswiftui {
            // 延迟跳转到登录页面
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
                Router_baseswiftui.shared_baseswiftui.toLogin_baseswiftui()
            }
            return
        }
        
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.success)
        
        stopTimer_blisslink()
        
        // 保存练习记录（将秒转换为分钟）
        let minutes_blisslink = elapsedTime_blisslink / 60
        
        if minutes_blisslink > 0 {
            practiceVM_blisslink.addPracticeSession_blisslink(duration_blisslink: minutes_blisslink)
            
            Utils_baseswiftui.showSuccess_baseswiftui(
                message_baseswiftui: "Practice saved! +\(minutes_blisslink) min",
                image_baseswiftui: UIImage(systemName: "checkmark.circle.fill"),
                delay_baseswiftui: 2.0
            )
            
            // 延迟返回
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                router_baseswiftui.pop_baseswiftui()
            }
        } else {
            Utils_baseswiftui.showWarning_baseswiftui(
                message_baseswiftui: "Practice too short!",
                delay_baseswiftui: 1.5
            )
        }
    }
}
