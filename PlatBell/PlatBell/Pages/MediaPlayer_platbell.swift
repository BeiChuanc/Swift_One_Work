import SwiftUI

// MARK: - 媒体播放器页面
// 核心作用：播放视频或音频媒体
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 媒体播放器页面
struct MediaPlayer_platbell: View {
    
    /// 媒体URL
    let mediaUrl_platbell: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Media Player")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_platbell(
            title_platbell: "Media Player",
            showBackButton_platbell: false, rightButton_platbell:  {
                NavIconButton_platbell(
                    iconName_platbell: "xmark",
                    onTapped_platbell: {
                        Router_platbell.shared_platbell.dismissFullScreen_platbell()
                    }
                )
            })
    }
}
