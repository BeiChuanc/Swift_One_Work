import SwiftUI

// MARK: - 注册页
// 核心作用：用户注册界面
// 设计思路：现代化设计，密码验证，协议展示，动画自然有趣
// 关键功能：用户名密码注册、密码确认、表单验证、协议展示

/// 注册页
struct Register_baseswift: View {
    
    // MARK: - ViewModels
    
    @ObservedObject var userVM_blisslink = UserViewModel_blisslink.shared_blisslink
    @ObservedObject var router_blisslink = Router_blisslink.shared_blisslink
    
    // MARK: - 状态
    
    @State private var username_blisslink: String = ""
    @State private var password_blisslink: String = ""
    @State private var confirmPassword_blisslink: String = ""
    @State private var isRegistering_blisslink: Bool = false
    @State private var showPassword_blisslink: Bool = false
    @State private var showConfirmPassword_blisslink: Bool = false
    @State private var showTerms_blisslink: Bool = false
    @State private var showPrivacy_blisslink: Bool = false
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 背景层
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "FA8BFF"),
                        Color(hex: "2BD2FF"),
                        Color(hex: "667EEA")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 装饰圆圈
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 280.w_blisslink, height: 280.h_blisslink)
                    .offset(x: -140.w_blisslink, y: -180.h_blisslink)
                    .blur(radius: 45)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 320.w_blisslink, height: 320.h_blisslink)
                    .offset(x: 160.w_blisslink, y: 380.h_blisslink)
                    .blur(radius: 55)
            }
            .ignoresSafeArea()
            
            // 内容层
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // 顶部Logo区域
                    logoSection_blisslink
                        .padding(.top, 80.h_blisslink)
                    
                    // 注册表单卡片
                    registerFormCard_blisslink
                        .padding(.top, 40.h_blisslink)
                    
                    // 协议文字
                    protocolText_blisslink
                        .padding(.top, 24.h_blisslink)
                        .padding(.bottom, 40.h_blisslink)
                }
                .padding(.horizontal, 20.w_blisslink)
            }
            
            // 返回按钮
            VStack {
                HStack {
                    Button(action: {
                        router_blisslink.pop_blisslink()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 36.w_blisslink, height: 36.h_blisslink)
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16.sp_blisslink, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 50.h_blisslink)
                    .padding(.leading, 20.w_blisslink)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Logo区域
    
    private var logoSection_blisslink: some View {
        VStack(spacing: 16.h_blisslink) {
            // Logo图标
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 90.w_blisslink, height: 90.h_blisslink)
                    .blur(radius: 18)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 80.w_blisslink, height: 80.h_blisslink)
                    .shadow(color: Color.black.opacity(0.15), radius: 18, x: 0, y: 8)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40.sp_blisslink, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "FA8BFF"), Color(hex: "2BD2FF")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .bounceIn_blisslink(delay_blisslink: 0.1)
            
            // 标题
            VStack(spacing: 8.h_blisslink) {
                Text("Create Account")
                    .font(.system(size: 32.sp_blisslink, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Join the yoga community")
                    .font(.system(size: 15.sp_blisslink, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.2)
        }
    }
    
    // MARK: - 注册表单卡片
    
    private var registerFormCard_blisslink: some View {
        VStack(spacing: 20.h_blisslink) {
            // 标题
            VStack(spacing: 6.h_blisslink) {
                Text("Get Started")
                    .font(.system(size: 24.sp_blisslink, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Create your account to begin")
                    .font(.system(size: 14.sp_blisslink))
                    .foregroundColor(.secondary)
            }
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.3)
            
            // 用户名输入
            inputField_blisslink(
                icon_blisslink: "person.fill",
                placeholder_blisslink: "Username",
                text_blisslink: $username_blisslink,
                isSecure_blisslink: false
            )
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.35)
            
            // 密码输入
            passwordField_blisslink(
                placeholder_blisslink: "Password",
                text_blisslink: $password_blisslink,
                showPassword_blisslink: $showPassword_blisslink
            )
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.4)
            
            // 确认密码输入
            passwordField_blisslink(
                placeholder_blisslink: "Confirm Password",
                text_blisslink: $confirmPassword_blisslink,
                showPassword_blisslink: $showConfirmPassword_blisslink
            )
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.45)
            
            // 密码强度提示
            if !password_blisslink.isEmpty {
                passwordStrengthIndicator_blisslink
                    .slideIn_blisslink(from: .bottom, delay_blisslink: 0.1)
            }
            
            // 注册按钮
            registerButton_blisslink
                .padding(.top, 10.h_blisslink)
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.5)
        }
        .padding(28.w_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 28.w_blisslink)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
        .bounceIn_blisslink(delay_blisslink: 0.25)
    }
    
    // MARK: - 输入框
    
    private func inputField_blisslink(
        icon_blisslink: String,
        placeholder_blisslink: String,
        text_blisslink: Binding<String>,
        isSecure_blisslink: Bool
    ) -> some View {
        HStack(spacing: 12.w_blisslink) {
            Image(systemName: icon_blisslink)
                .font(.system(size: 18.sp_blisslink, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "FA8BFF"), Color(hex: "2BD2FF")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24.w_blisslink)
            
            TextField(placeholder_blisslink, text: text_blisslink)
                .font(.system(size: 16.sp_blisslink, weight: .medium))
                .autocapitalization(.none)
        }
        .padding(18.w_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 14.w_blisslink)
                .fill(Color.gray.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14.w_blisslink)
                .stroke(
                    !text_blisslink.wrappedValue.isEmpty ?
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "FA8BFF").opacity(0.5), Color(hex: "2BD2FF").opacity(0.5)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2.w_blisslink
                )
        )
    }
    
    // MARK: - 密码输入框
    
    private func passwordField_blisslink(
        placeholder_blisslink: String,
        text_blisslink: Binding<String>,
        showPassword_blisslink: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12.w_blisslink) {
            Image(systemName: "lock.fill")
                .font(.system(size: 18.sp_blisslink, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "FA8BFF"), Color(hex: "2BD2FF")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24.w_blisslink)
            
            if showPassword_blisslink.wrappedValue {
                TextField(placeholder_blisslink, text: text_blisslink)
                    .font(.system(size: 16.sp_blisslink, weight: .medium))
                    .autocapitalization(.none)
            } else {
                SecureField(placeholder_blisslink, text: text_blisslink)
                    .font(.system(size: 16.sp_blisslink, weight: .medium))
            }
            
            // 显示/隐藏密码按钮
            Button(action: {
                showPassword_blisslink.wrappedValue.toggle()
                
                let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
                generator_blisslink.impactOccurred()
            }) {
                Image(systemName: showPassword_blisslink.wrappedValue ? "eye.fill" : "eye.slash.fill")
                    .font(.system(size: 16.sp_blisslink))
                    .foregroundColor(.secondary)
            }
        }
        .padding(18.w_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 14.w_blisslink)
                .fill(Color.gray.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14.w_blisslink)
                .stroke(
                    !text_blisslink.wrappedValue.isEmpty ?
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "FA8BFF").opacity(0.5), Color(hex: "2BD2FF").opacity(0.5)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2.w_blisslink
                )
        )
    }
    
    // MARK: - 密码强度指示器
    
    private var passwordStrengthIndicator_blisslink: some View {
        HStack(spacing: 8.w_blisslink) {
            // 强度条
            ForEach(0..<3) { index_blisslink in
                Rectangle()
                    .fill(
                        password_blisslink.count > (index_blisslink + 1) * 3 ?
                        LinearGradient(
                            gradient: Gradient(colors: strengthColor_blisslink),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.2)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 4.h_blisslink)
                    .cornerRadius(2.h_blisslink)
            }
            
            // 强度文字
            Text(strengthText_blisslink)
                .font(.system(size: 12.sp_blisslink, weight: .semibold))
                .foregroundColor(strengthTextColor_blisslink)
        }
    }
    
    // MARK: - 注册按钮
    
    private var registerButton_blisslink: some View {
        Button(action: {
            handleRegister_blisslink()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 14.w_blisslink)
                    .fill(
                        isValid_blisslink && !isRegistering_blisslink ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "FA8BFF"), Color(hex: "2BD2FF")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 54.h_blisslink)
                
                // 顶部光晕
                if isValid_blisslink && !isRegistering_blisslink {
                    VStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.35), Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 27.h_blisslink)
                        
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14.w_blisslink))
                }
                
                // 按钮内容
                HStack(spacing: 12.w_blisslink) {
                    if isRegistering_blisslink {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text("Creating account...")
                            .font(.system(size: 17.sp_blisslink, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 20.sp_blisslink))
                        
                        Text("Create Account")
                            .font(.system(size: 17.sp_blisslink, weight: .bold))
                    }
                }
                .foregroundColor(.white)
            }
            .shadow(
                color: isValid_blisslink && !isRegistering_blisslink ? Color(hex: "2BD2FF").opacity(0.4) : Color.clear,
                radius: 20,
                x: 0,
                y: 10
            )
        }
        .disabled(!isValid_blisslink || isRegistering_blisslink)
        .scaleEffect(isValid_blisslink && !isRegistering_blisslink ? 1.0 : 0.97)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isValid_blisslink)
    }
    
    // MARK: - 协议文字
    
    private var protocolText_blisslink: some View {
        VStack {
            (
                Text("By continuing, you agree to our ")
                    .font(.system(size: 12.sp_blisslink))
                    .foregroundColor(.white.opacity(0.8)) +
                
                Text("Terms of Service")
                    .font(.system(size: 12.sp_blisslink, weight: .medium))
                    .foregroundColor(.white)
                    .underline() +
                
                Text(" & ")
                    .font(.system(size: 12.sp_blisslink))
                    .foregroundColor(.white.opacity(0.8)) +
                
                Text("Privacy Policy")
                    .font(.system(size: 12.sp_blisslink, weight: .medium))
                    .foregroundColor(.white)
                    .underline() +
                
                Text(".")
                    .font(.system(size: 12.sp_blisslink))
                    .foregroundColor(.white.opacity(0.8))
            )
            .multilineTextAlignment(.center)
            .onTapGesture { coordinate_blisslink in
                handleProtocolTap_blisslink(at: coordinate_blisslink)
            }
        }
        .sheet(isPresented: $showTerms_blisslink) {
            NavigationStack {
                ProtocolContentView_blisslink(
                    type_blisslink: .terms_blisslink,
                    content_blisslink: "terms.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showTerms_blisslink = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPrivacy_blisslink) {
            NavigationStack {
                ProtocolContentView_blisslink(
                    type_blisslink: .privacy_blisslink,
                    content_blisslink: "privacy.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showPrivacy_blisslink = false
                        }
                    }
                }
            }
        }
        .slideIn_blisslink(from: .bottom, delay_blisslink: 0.6)
    }
    
    /// 处理协议文本点击
    private func handleProtocolTap_blisslink(at location_blisslink: CGPoint) {
        // 简单实现：点击显示Terms
        // 用户也可以通过设置页面查看Privacy
        showTerms_blisslink = true
    }
    
    // MARK: - 计算属性
    
    /// 验证输入是否有效
    private var isValid_blisslink: Bool {
        let hasUsername_blisslink = !username_blisslink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasPassword_blisslink = !password_blisslink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasConfirmPassword_blisslink = !confirmPassword_blisslink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let passwordsMatch_blisslink = password_blisslink == confirmPassword_blisslink
        
        return hasUsername_blisslink && hasPassword_blisslink && hasConfirmPassword_blisslink && passwordsMatch_blisslink
    }
    
    /// 密码强度颜色
    private var strengthColor_blisslink: [Color] {
        let length_blisslink = password_blisslink.count
        if length_blisslink < 6 {
            return [Color(hex: "FF6B6B"), Color(hex: "FF8E53")]
        } else if length_blisslink < 10 {
            return [Color(hex: "F2C94C"), Color(hex: "F2994A")]
        } else {
            return [Color(hex: "43E97B"), Color(hex: "38F9D7")]
        }
    }
    
    /// 密码强度文字
    private var strengthText_blisslink: String {
        let length_blisslink = password_blisslink.count
        if length_blisslink < 6 {
            return "Weak"
        } else if length_blisslink < 10 {
            return "Medium"
        } else {
            return "Strong"
        }
    }
    
    /// 密码强度文字颜色
    private var strengthTextColor_blisslink: Color {
        let length_blisslink = password_blisslink.count
        if length_blisslink < 6 {
            return Color(hex: "FF6B6B")
        } else if length_blisslink < 10 {
            return Color(hex: "F2994A")
        } else {
            return Color(hex: "43E97B")
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理跳转到登录页
    private func handleGoToLogin_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 返回上一页（登录页）
        router_blisslink.pop_blisslink()
    }
    
    /// 处理注册
    private func handleRegister_blisslink() {
        // 验证输入
        guard isValid_blisslink else {
            if username_blisslink.isEmpty || password_blisslink.isEmpty || confirmPassword_blisslink.isEmpty {
                Utils_blisslink.showWarning_blisslink(
                    message_blisslink: "Please fill in all fields.",
                    delay_blisslink: 1.5
                )
            } else if password_blisslink != confirmPassword_blisslink {
                Utils_blisslink.showWarning_blisslink(
                    message_blisslink: "Passwords do not match.",
                    delay_blisslink: 1.5
                )
            }
            return
        }
        
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.success)
        
        isRegistering_blisslink = true
        
        // 模拟注册过程
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
            
            // 注册成功，自动登录
            userVM_blisslink.loginById_blisslink(userId_blisslink: 1)
            
            isRegistering_blisslink = false
            
            // 返回上一页
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            router_blisslink.pop_blisslink()
        }
    }
}
