import SwiftUI

// MARK: - 媒体播放器页面
// 核心作用：播放视频或音频媒体
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 媒体播放器页面
struct MediaPlayer_baseswift: View {
    
    /// 媒体URL
    let mediaUrl_baseswiftui: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Media Player")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_baseswiftui(
            title_baseswiftui: "Media Player",
            showBackButton_baseswiftui: false
        ) {
            NavIconButton_baseswiftui(
                iconName_baseswiftui: "xmark",
                onTapped_baseswiftui: {
                    Router_baseswiftui.shared_baseswiftui.dismissFullScreen_baseswiftui()
                }
            )
        }
    }
}
