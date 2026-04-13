import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：柔和渐变、温暖包容、富有疗愈感
struct ColorConfig_Clara {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色 - 薰衣草紫
    static let primaryGradientStart_Clara = UIColor(hexstring_Clara: "#B794F6")
    
    /// 主渐变色 - 天空蓝
    static let primaryGradientEnd_Clara = UIColor(hexstring_Clara: "#90CDF4")
    
    /// 辅助渐变色 - 玫瑰粉
    static let secondaryGradientStart_Clara = UIColor(hexstring_Clara: "#FBB6CE")
    
    /// 辅助渐变色 - 珊瑚橙
    static let secondaryGradientEnd_Clara = UIColor(hexstring_Clara: "#FED7AA")
    
    // MARK: - 背景色
    
    /// 主背景色 - 极浅灰
    static let backgroundPrimary_Clara = UIColor(hexstring_Clara: "#F7FAFC")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Clara = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Clara = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深灰
    static let textPrimary_Clara = UIColor(hexstring_Clara: "#2D3748")
    
    /// 次文本色 - 中灰
    static let textSecondary_Clara = UIColor(hexstring_Clara: "#718096")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Clara = UIColor(hexstring_Clara: "#A0AEC0")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Clara = UIColor(hexstring_Clara: "#E2E8F0")
    
    /// 边框颜色
    static let border_Clara = UIColor(hexstring_Clara: "#CBD5E0")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Clara = UIColor(hexstring_Clara: "#000000", alpha_Clara: 0.1)
    
    // MARK: - 春季色系
    
    /// 樱花粉 - 春季主色调
    static let springCherryBlossom_Clara = UIColor(hexstring_Clara: "#FFB7C5")
    
    /// 嫩绿 - 春季生机色
    static let springFreshGreen_Clara = UIColor(hexstring_Clara: "#98D8AA")
    
    /// 薄雾蓝 - 春季清透色
    static let springMistBlue_Clara = UIColor(hexstring_Clara: "#B4D4EE")
    
    /// 奶油白 - 春季底色
    static let springCreamWhite_Clara = UIColor(hexstring_Clara: "#FFF8F0")
    
    /// 暖杏色 - 春季点缀色
    static let springWarmApricot_Clara = UIColor(hexstring_Clara: "#FAD4A6")
    
    /// 淡紫罗兰 - 春季浪漫色
    static let springLavender_Clara = UIColor(hexstring_Clara: "#D4B4EE")
}

// MARK: - UIColor扩展 - 便捷访问

extension UIColor {
    
    /// 创建渐变图层（主渐变）
    /// 功能：创建薰衣草紫到天空蓝的渐变图层
    /// 参数：
    /// - frame_Clara: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createPrimaryGradientLayer_Clara(frame_Clara: CGRect) -> CAGradientLayer {
        let gradientLayer_Clara = CAGradientLayer()
        gradientLayer_Clara.frame = frame_Clara
        gradientLayer_Clara.colors = [
            ColorConfig_Clara.primaryGradientStart_Clara.cgColor,
            ColorConfig_Clara.primaryGradientEnd_Clara.cgColor
        ]
        gradientLayer_Clara.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Clara.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Clara
    }
    
    /// 创建渐变图层（辅助渐变）
    /// 功能：创建玫瑰粉到珊瑚橙的渐变图层
    /// 参数：
    /// - frame_Clara: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createSecondaryGradientLayer_Clara(frame_Clara: CGRect) -> CAGradientLayer {
        let gradientLayer_Clara = CAGradientLayer()
        gradientLayer_Clara.frame = frame_Clara
        gradientLayer_Clara.colors = [
            ColorConfig_Clara.secondaryGradientStart_Clara.cgColor,
            ColorConfig_Clara.secondaryGradientEnd_Clara.cgColor
        ]
        gradientLayer_Clara.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Clara.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Clara
    }
    
    /// 创建春季渐变图层（樱花粉→薄雾蓝）
    /// 功能：创建春季主题渐变背景
    /// 参数：
    /// - frame_Clara: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 春季渐变图层
    static func createSpringGradientLayer_Clara(frame_Clara: CGRect) -> CAGradientLayer {
        let gradientLayer_Clara = CAGradientLayer()
        gradientLayer_Clara.frame = frame_Clara
        gradientLayer_Clara.colors = [
            ColorConfig_Clara.springCherryBlossom_Clara.cgColor,
            ColorConfig_Clara.springMistBlue_Clara.cgColor
        ]
        gradientLayer_Clara.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Clara.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Clara
    }
    
    /// 创建春季暖色渐变图层（奶油白→暖杏）
    /// 功能：创建春季卡片背景渐变
    /// 参数：
    /// - frame_Clara: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 春季暖色渐变图层
    static func createSpringWarmGradientLayer_Clara(frame_Clara: CGRect) -> CAGradientLayer {
        let gradientLayer_Clara = CAGradientLayer()
        gradientLayer_Clara.frame = frame_Clara
        gradientLayer_Clara.colors = [
            ColorConfig_Clara.springCreamWhite_Clara.cgColor,
            ColorConfig_Clara.springWarmApricot_Clara.cgColor
        ]
        gradientLayer_Clara.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Clara.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Clara
    }

    // MARK: - Aurora Mesh Gradient 背景

    /// 网状渐变背景图片缓存（按尺寸缓存，兼容横竖屏切换）
    private static var meshGradientCache_Clara: [String: UIImage] = [:]

    /// 创建 Aurora 风格多焦点网状渐变背景图片
    /// 功能：以 UIGraphicsImageRenderer 绘制 5 个径向色晕叠加，
    ///        形成类似极光/流光的多彩网状背景；结果按尺寸缓存以避免重复绘制
    /// 参数：
    /// - size: 渲染尺寸，通常传入 view.bounds.size
    /// 返回值：UIImage - 渲染完成的网状渐变背景图片
    static func createMeshGradientImage_Clara(size: CGSize) -> UIImage {
        let key = "\(Int(size.width))x\(Int(size.height))"
        if let cached = meshGradientCache_Clara[key] { return cached }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cgCtx = ctx.cgContext
            let w = size.width
            let h = size.height

            // 底色：极浅薰衣草白，作为色晕叠加的基底
            UIColor(red: 0.972, green: 0.967, blue: 1.000, alpha: 1.0).setFill()
            UIRectFill(CGRect(origin: .zero, size: size))

            /// 绘制单个径向色晕
            /// 参数：cx/cy - 中心坐标比例；radius - 半径（像素）；r/g/b - RGB；alpha - 最大不透明度
            func drawSpot(cx: CGFloat, cy: CGFloat, radius: CGFloat,
                          r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
                let center = CGPoint(x: cx * w, y: cy * h)
                let colors = [
                    UIColor(red: r, green: g, blue: b, alpha: alpha).cgColor,
                    UIColor(red: r, green: g, blue: b, alpha: 0).cgColor
                ] as CFArray
                guard let gradient = CGGradient(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: colors,
                    locations: [0, 1] as [CGFloat]
                ) else { return }
                cgCtx.drawRadialGradient(
                    gradient,
                    startCenter: center, startRadius: 0,
                    endCenter: center, endRadius: radius,
                    options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
                )
            }

            // ① 左上 - 深紫主调 #7C3AED（主色，面积最大）
            drawSpot(cx: 0.04, cy: 0.04, radius: w * 0.85,
                     r: 0.486, g: 0.227, b: 0.929, alpha: 0.40)

            // ② 右上 - 深天蓝 #0284C7（冷色对比）
            drawSpot(cx: 0.96, cy: 0.07, radius: w * 0.75,
                     r: 0.008, g: 0.518, b: 0.780, alpha: 0.34)

            // ③ 右侧中部 - 玫瑰粉 #DB2777（暖色点睛）
            drawSpot(cx: 0.92, cy: 0.60, radius: w * 0.65,
                     r: 0.859, g: 0.153, b: 0.467, alpha: 0.26)

            // ④ 左下 - 暖橙 #EA580C（接地气的暖调）
            drawSpot(cx: 0.04, cy: 0.93, radius: w * 0.75,
                     r: 0.918, g: 0.345, b: 0.047, alpha: 0.20)

            // ⑤ 中央偏上 - 柔紫连接色 #A78BFA（过渡融合）
            drawSpot(cx: 0.46, cy: 0.36, radius: w * 0.58,
                     r: 0.655, g: 0.545, b: 0.980, alpha: 0.15)
        }

        meshGradientCache_Clara[key] = image
        return image
    }
}

// MARK: - UIView Aurora 背景工具扩展

extension UIView {

    /// 网状背景视图的唯一标识
    private static let meshBgTag_Clara = 8_837_291

    /// 为视图应用 Aurora 网状渐变背景
    /// 功能：在视图最底层插入承载网状渐变图片的 UIImageView，
    ///        视图本身及主要容器视图需同步设置 backgroundColor = .clear
    func applyThemeBackground_Clara() {
        backgroundColor = .clear
        isOpaque = false
        // 移除旧背景视图，避免重复叠加
        subviews.filter { $0.tag == UIView.meshBgTag_Clara }.forEach { $0.removeFromSuperview() }
        let size = bounds.isEmpty ? UIScreen.main.bounds.size : bounds.size
        let bgView = UIImageView(image: UIColor.createMeshGradientImage_Clara(size: size))
        bgView.tag = UIView.meshBgTag_Clara
        bgView.contentMode = .scaleToFill
        bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bgView.frame = CGRect(origin: .zero, size: size)
        insertSubview(bgView, at: 0)
    }

    /// 更新网状背景视图的尺寸与图片（在 viewDidLayoutSubviews 中调用）
    /// 功能：当视图尺寸确定或改变时（如首次 layout、横竖屏切换），同步刷新背景
    func updateThemeBackgroundFrame_Clara() {
        guard let bgView = subviews.first(where: { $0.tag == UIView.meshBgTag_Clara }) as? UIImageView,
              !bounds.isEmpty else { return }
        if bgView.bounds.size != bounds.size {
            bgView.frame = bounds
            bgView.image = UIColor.createMeshGradientImage_Clara(size: bounds.size)
        }
    }
}
