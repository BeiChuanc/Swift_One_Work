import SwiftUI

// MARK: - 闪屏页面视图

/// 闪屏页面视图
struct SplashView_blisslink: View {
    
    // MARK: - 配置
    
    /// 闪屏图片名称（在 Assets 中）
    private let imageName_blisslink = "launch"
    
    /// 闪屏持续时间（秒）
    private let duration_blisslink: Double = 1.5
    
    // MARK: - 状态
    
    @State private var isActive_blisslink = false
    
    // MARK: - 视图主体
    
    var body: some View {
        if isActive_blisslink {
            ContentView()
        } else {
            splashContent_blisslink
                .onAppear(perform: startTimer_blisslink)
        }
    }
    
    // MARK: - 闪屏内容
    
    /// 闪屏内容视图
    private var splashContent_blisslink: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if let uiImage_blisslink = UIImage(named: imageName_blisslink) {
                // 显示自定义闪屏图片
                Image(uiImage: uiImage_blisslink)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                // 占位图（当找不到图片时显示）
                placeholderView_blisslink
            }
        }
    }
    
    /// 占位视图
    private var placeholderView_blisslink: some View {
        VStack(spacing: 20) {
            Image(systemName: "app.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Base SwiftUI")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - 方法
    
    /// 启动定时器
    private func startTimer_blisslink() {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration_blisslink) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isActive_blisslink = true
            }
        }
    }
}
