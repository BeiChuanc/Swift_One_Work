import SwiftUI
import PhotosUI

// MARK: - 编辑信息页
// 核心作用：编辑用户个人信息
// 设计思路：现代化表单设计，实时预览，流畅的交互体验
// 关键功能：头像编辑、用户名编辑、简介编辑、数据校验

/// 编辑信息页
struct EditInfo_lite: View {
    
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var router_lite = Router_lite.shared_lite
    
    // 表单数据
    @State private var userName_lite = ""
    @State private var userIntroduce_lite = ""
    @State private var selectedPhotoItem_lite: PhotosPickerItem?
    @State private var selectedImage_lite: UIImage?
    @State private var hasChangedAvatar_lite = false
    
    // 原始数据（用于比对是否有修改）
    @State private var originalUserName_lite = ""
    @State private var originalUserIntroduce_lite = ""
    
    // UI状态
    @State private var isSaving_lite = false
    @FocusState private var nameFieldFocused_lite: Bool
    @FocusState private var introduceFieldFocused_lite: Bool
    
    var body: some View {
        ZStack {
            // 动态渐变背景
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "667eea").opacity(0.06),
                        Color(hex: "F8F9FA"),
                        Color(hex: "f093fb").opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 装饰圆圈
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "667eea").opacity(0.08), Color.clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 200.w_lite
                        )
                    )
                    .frame(width: 300.w_lite, height: 300.h_lite)
                    .offset(x: -80.w_lite, y: -80.h_lite)
                    .blur(radius: 30)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 自定义顶部导航栏
                customHeaderView_lite
                
                ScrollView {
                    VStack(spacing: 28.h_lite) {
                        // 头像编辑区域
                        avatarSection_lite
                            .padding(.top, 24.h_lite)
                        
                        // 用户名编辑
                        userNameSection_lite
                        
                        // 简介编辑
                        introduceSection_lite
                        
                        // 保存按钮
                        saveButton_lite
                    }
                    .padding(.horizontal, 20.w_lite)
                    .padding(.bottom, 40.h_lite)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadUserData_lite()
        }
        .onTapGesture {
            // 点击空白处收起键盘
            nameFieldFocused_lite = false
            introduceFieldFocused_lite = false
        }
    }
    
    // MARK: - 自定义顶部导航栏
    
    /// 自定义顶部导航栏
    private var customHeaderView_lite: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12.w_lite) {
                // 返回按钮（增强版）
                Button {
                    router_lite.pop_lite()
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
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "667eea").opacity(0.3), Color(hex: "764ba2").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 15, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(ScaleButtonStyle_lite())
                
                // 页面标题
                VStack(alignment: .leading, spacing: 4.h_lite) {
                    Text("Edit Profile")
                        .font(.system(size: 28.sp_lite, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "212529"), Color(hex: "495057")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Personalize your info")
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
    
    // MARK: - 头像编辑区域
    
    /// 头像编辑区域
    private var avatarSection_lite: some View {
        VStack(spacing: 16.h_lite) {
            // 标题
            HStack {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 18.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                
                Text("Profile Photo")
                    .font(.system(size: 20.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Spacer()
            }
            
            // 头像选择器
            PhotosPicker(
                selection: $selectedPhotoItem_lite,
                matching: .images
            ) {
                ZStack {
                    // 外圈光晕
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: MediaConfig_lite.getGradientColors_lite(
                                    for: userName_lite
                                ).map { $0.opacity(0.3) },
                                center: .center,
                                startRadius: 60.w_lite,
                                endRadius: 80.w_lite
                            )
                        )
                        .frame(width: 150.w_lite, height: 150.h_lite)
                        .blur(radius: 10)
                    
                    // 主头像
                    if let selectedImage_lite = selectedImage_lite {
                        Image(uiImage: selectedImage_lite)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 130.w_lite, height: 130.h_lite)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 5)
                            )
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: MediaConfig_lite.getGradientColors_lite(for: userName_lite),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 130.w_lite, height: 130.h_lite)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 5)
                            )
                            .overlay(
                                Text(String((userName_lite.isEmpty ? "U" : userName_lite).prefix(1)).uppercased())
                                    .font(.system(size: 54.sp_lite, weight: .black))
                                    .foregroundColor(.white)
                                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                    }
                    
                    // 编辑标记
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40.w_lite, height: 40.h_lite)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18.sp_lite, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 12, x: 0, y: 6)
                    .offset(x: 45.w_lite, y: 45.h_lite)
                }
                .shadow(color: Color.black.opacity(0.15), radius: 25, x: 0, y: 12)
            }
            
            Text("Tap to change photo")
                .font(.system(size: 14.sp_lite, weight: .medium))
                .foregroundColor(Color(hex: "6C757D"))
        }
        .onChange(of: selectedPhotoItem_lite) { _, newItem_lite in
            Task {
                if let newItem_lite = newItem_lite {
                    if let data_lite = try? await newItem_lite.loadTransferable(type: Data.self),
                       let image_lite = UIImage(data: data_lite) {
                        await MainActor.run {
                            selectedImage_lite = image_lite
                            hasChangedAvatar_lite = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 用户名编辑区域
    
    /// 用户名编辑区域
    private var userNameSection_lite: some View {
        VStack(alignment: .leading, spacing: 12.h_lite) {
            // 标题
            HStack(spacing: 6.w_lite) {
                Image(systemName: "person.text.rectangle")
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                
                Text("Username")
                    .font(.system(size: 18.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Spacer()
                
                // 字数统计
                Text("\(userName_lite.count)/20")
                    .font(.system(size: 12.sp_lite, weight: .medium))
                    .foregroundColor(userName_lite.count >= 18 ? Color(hex: "f5576c") : Color(hex: "ADB5BD"))
            }
            
            // 输入框
            TextField("Enter your name...", text: $userName_lite)
                .font(.system(size: 17.sp_lite, weight: .semibold))
                .padding(18.w_lite)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 18.w_lite)
                            .fill(Color.white)
                        
                        RoundedRectangle(cornerRadius: 18.w_lite)
                            .stroke(
                                nameFieldFocused_lite ?
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color(hex: "E9ECEF"), Color(hex: "E9ECEF")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                lineWidth: 2
                            )
                    }
                )
                .shadow(
                    color: nameFieldFocused_lite ? Color(hex: "667eea").opacity(0.2) : Color.black.opacity(0.05),
                    radius: nameFieldFocused_lite ? 15 : 10,
                    x: 0,
                    y: 6
                )
                .focused($nameFieldFocused_lite)
                .onChange(of: userName_lite) { _, newValue_lite in
                    // 限制用户名最多20个字符
                    if newValue_lite.count > 20 {
                        userName_lite = String(newValue_lite.prefix(20))
                    }
                }
        }
    }
    
    // MARK: - 简介编辑区域
    
    /// 简介编辑区域
    private var introduceSection_lite: some View {
        VStack(alignment: .leading, spacing: 12.h_lite) {
            // 标题
            HStack(spacing: 6.w_lite) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                
                Text("Introduce")
                    .font(.system(size: 18.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Spacer()
                
                // 字数统计
                Text("\(userIntroduce_lite.count)/100")
                    .font(.system(size: 12.sp_lite, weight: .medium))
                    .foregroundColor(userIntroduce_lite.count >= 90 ? Color(hex: "f5576c") : Color(hex: "ADB5BD"))
            }
            
            // 输入框
            ZStack(alignment: .topLeading) {
                if userIntroduce_lite.isEmpty && !introduceFieldFocused_lite {
                    Text("Tell us about yourself...")
                        .font(.system(size: 16.sp_lite))
                        .foregroundColor(Color(hex: "ADB5BD"))
                        .padding(.horizontal, 18.w_lite)
                        .padding(.vertical, 18.h_lite)
                }
                
                TextEditor(text: $userIntroduce_lite)
                    .font(.system(size: 16.sp_lite, weight: .medium))
                    .frame(height: 120.h_lite)
                    .padding(.horizontal, 12.w_lite)
                    .padding(.vertical, 12.h_lite)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .focused($introduceFieldFocused_lite)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18.w_lite)
                        .fill(Color.white)
                    
                    RoundedRectangle(cornerRadius: 18.w_lite)
                        .stroke(
                            introduceFieldFocused_lite ?
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    colors: [Color(hex: "E9ECEF"), Color(hex: "E9ECEF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                            lineWidth: 2
                        )
                }
            )
            .shadow(
                color: introduceFieldFocused_lite ? Color(hex: "667eea").opacity(0.2) : Color.black.opacity(0.05),
                radius: introduceFieldFocused_lite ? 15 : 10,
                x: 0,
                y: 6
            )
            .onChange(of: userIntroduce_lite) { _, newValue_lite in
                // 限制简介最多100个字符
                if newValue_lite.count > 100 {
                    userIntroduce_lite = String(newValue_lite.prefix(100))
                }
            }
        }
    }
    
    // MARK: - 保存按钮
    
    /// 保存按钮
    private var saveButton_lite: some View {
        VStack(spacing: 12.h_lite) {
            Button {
                handleSaveButtonTap_lite()
            } label: {
                HStack(spacing: 10.w_lite) {
                    if isSaving_lite {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: hasChanges_lite ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 22.sp_lite, weight: .bold))
                    }
                    
                    Text(isSaving_lite ? "Saving..." : "Save Changes")
                        .font(.system(size: 18.sp_lite, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18.h_lite)
                .background(
                    ZStack {
                        LinearGradient(
                            colors: canSave_lite ?
                                [Color(hex: "667eea"), Color(hex: "764ba2")] :
                                [Color(hex: "ADB5BD"), Color(hex: "6C757D")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        if canSave_lite {
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        }
                    }
                )
                .cornerRadius(20.w_lite)
                .shadow(
                    color: canSave_lite ? Color(hex: "667eea").opacity(0.4) : Color.clear,
                    radius: canSave_lite ? 20 : 0,
                    x: 0,
                    y: canSave_lite ? 10 : 0
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20.w_lite)
                        .stroke(Color.white.opacity(canSave_lite ? 0.5 : 0), lineWidth: 2)
                )
            }
            .buttonStyle(ScaleButtonStyle_lite())
        }
        .padding(.top, 12.h_lite)
    }
    
    // MARK: - 辅助方法
    
    /// 是否有修改
    private var hasChanges_lite: Bool {
        return hasChangedAvatar_lite ||
               userName_lite != originalUserName_lite ||
               userIntroduce_lite != originalUserIntroduce_lite
    }
    
    /// 是否可以保存
    private var canSave_lite: Bool {
        guard userVM_lite.isLoggedIn_lite else { return false }
        guard !userName_lite.isEmpty else { return false }
        return hasChanges_lite
    }
    
    /// 加载用户数据
    private func loadUserData_lite() {
        let currentUser_lite = userVM_lite.getCurrentUser_lite()
        userName_lite = currentUser_lite.userName_lite ?? ""
        userIntroduce_lite = currentUser_lite.userIntroduce_lite ?? ""
        
        // 保存原始数据
        originalUserName_lite = userName_lite
        originalUserIntroduce_lite = userIntroduce_lite
    }
    
    /// 处理保存按钮点击（按优先级判断）
    private func handleSaveButtonTap_lite() {
        // 第一优先级：判断是否正在保存
        guard !isSaving_lite else {
            print("⏳ 正在保存中，忽略点击")
            return
        }
        
        // 第二优先级：判断是否登录
        guard userVM_lite.isLoggedIn_lite else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                router_lite.toLogin_liteui()
            }
            return
        }
        
        // 第三优先级：判断数据是否有修改
        guard hasChanges_lite else {
            Utils_lite.showInfo_lite(message_lite: "No changes to save")
            return
        }
        
        // 第四优先级：验证数据有效性
        if userName_lite.isEmpty {
            Utils_lite.showWarning_lite(message_lite: "Username cannot be empty")
            return
        }
        
        // 所有条件满足，执行保存
        print("✅ 所有条件满足，开始保存修改")
        saveChanges_lite()
    }
    
    /// 保存修改（只处理实际保存逻辑）
    private func saveChanges_lite() {
        isSaving_lite = true
        
        // 模拟保存延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 更新用户名（如果有修改）
            if userName_lite != originalUserName_lite {
                print("📝 更新用户名: '\(originalUserName_lite)' → '\(userName_lite)'")
                userVM_lite.updateName_lite(userName_lite: userName_lite)
            } else {
                userVM_lite.updateName_lite(userName_lite: originalUserName_lite)
            }
            
            // 更新简介（如果有修改）
            if userIntroduce_lite != originalUserIntroduce_lite {
                print("📝 更新简介: '\(originalUserIntroduce_lite)' → '\(userIntroduce_lite)'")
                userVM_lite.updateIntroduce_lite(introduce_lite: userIntroduce_lite)
            } else {
                userVM_lite.updateIntroduce_lite(introduce_lite: originalUserIntroduce_lite)
            }
            
            // 更新头像（如果有修改）
            if hasChangedAvatar_lite, let selectedImage_lite = selectedImage_lite {
                print("📝 更新头像")
                if let savedName_lite = saveAvatarToDocuments_lite(image_lite: selectedImage_lite) {
                    userVM_lite.updateHead_lite(headUrl_lite: savedName_lite)
                } else {
                    print("⚠️ 头像保存失败，保持原头像")
                    userVM_lite.updateHead_lite(headUrl_lite: userVM_lite.getCurrentUser_lite().userHead_lite ?? "")
                }
            } else {
                userVM_lite.updateHead_lite(headUrl_lite: userVM_lite.getCurrentUser_lite().userHead_lite ?? "")
            }
            
            isSaving_lite = false
            router_lite.pop_lite()
        }
    }
    
    /// 保存头像到文档目录
    /// - Parameter image_lite: 要保存的图片
    /// - Returns: 保存后的文件名，失败返回 nil
    private func saveAvatarToDocuments_lite(image_lite: UIImage) -> String? {
        guard let data_lite = image_lite.jpegData(compressionQuality: 0.8) else {
            print("❌ 图片转换为数据失败")
            return nil
        }
        
        let fileManager_lite = FileManager.default
        guard let documentsDirectory_lite = fileManager_lite.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            print("❌ 无法获取文档目录")
            return nil
        }
        
        // 生成唯一文件名
        let fileName_lite = "avatar_\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
        let fileURL_lite = documentsDirectory_lite.appendingPathComponent(fileName_lite)
        
        do {
            try data_lite.write(to: fileURL_lite)
            print("✅ 头像保存成功：\(fileName_lite)")
            return fileName_lite
        } catch {
            print("❌ 头像保存失败：\(error.localizedDescription)")
            return nil
        }
    }
}
