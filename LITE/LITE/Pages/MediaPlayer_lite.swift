import SwiftUI

// MARK: - 媒体播放器页面
// 核心作用：播放视频或音频媒体
// 设计思路：简化实现，仅保留数据导入和页面标识

/// 媒体播放器页面
struct MediaPlayer_lite: View {
    
    /// 媒体URL
    let mediaUrl_lite: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Media Player")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customNavigationBar_lite(
            title_lite: "Media Player",
            showBackButton_lite: false, rightButton_lite:  {
                NavIconButton_lite(
                    iconName_lite: "xmark",
                    onTapped_lite: {
                        Router_lite.shared_lite.dismissFullScreen_lite()
                    }
                )
            })
    }
}
