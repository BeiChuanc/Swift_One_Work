import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 媒体全屏展示助手

/// 媒体全屏展示助手类
/// 功能：为媒体视图添加点击手势，支持全屏展示图片和视频
/// 支持媒体类型：系统图标、Assets图片、网络图片、本地文件图片和视频
class MediaFullScreenHelper_Glasspaint {
    
    // MARK: - 公共方法
    
    /// 为媒体视图添加全屏展示功能
    /// - Parameters:
    ///   - mediaView_glasspaint: 需要添加全屏功能的媒体视图
    ///   - mediaPath_glasspaint: 媒体路径
    ///   - isVideo_glasspaint: 是否为视频
    ///   - from_glasspaint: 来源视图控制器
    static func enableFullScreenDisplay_Glasspaint(
        for mediaView_glasspaint: UIView,
        mediaPath_glasspaint: String?,
        isVideo_glasspaint: Bool = false,
        from from_glasspaint: UIViewController
    ) {
        // 确保视图可以接收触摸事件
        mediaView_glasspaint.isUserInteractionEnabled = true
        
        // 移除旧的手势
        mediaView_glasspaint.gestureRecognizers?.forEach { mediaView_glasspaint.removeGestureRecognizer($0) }
        
        // 添加点击手势
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleMediaTap_Glasspaint(_:)))
        mediaView_glasspaint.addGestureRecognizer(tapGesture_glasspaint)
        
        // 将媒体信息存储在视图的关联对象中
        objc_setAssociatedObject(mediaView_glasspaint, &AssociatedKeys_Glasspaint.mediaPathKey_glasspaint, mediaPath_glasspaint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(mediaView_glasspaint, &AssociatedKeys_Glasspaint.isVideoKey_glasspaint, isVideo_glasspaint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(mediaView_glasspaint, &AssociatedKeys_Glasspaint.fromViewControllerKey_glasspaint, from_glasspaint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// 直接展示全屏媒体
    /// - Parameters:
    ///   - mediaPath_glasspaint: 媒体路径
    ///   - isVideo_glasspaint: 是否为视频
    ///   - from_glasspaint: 来源视图控制器
    static func showFullScreen_Glasspaint(
        mediaPath_glasspaint: String?,
        isVideo_glasspaint: Bool = false,
        from from_glasspaint: UIViewController
    ) {
        guard let path_glasspaint = mediaPath_glasspaint, !path_glasspaint.isEmpty else {
            print("⚠️ 媒体路径为空，无法展示全屏")
            return
        }
        
        let fullScreenVC_glasspaint = FullScreenMediaViewController_Glasspaint()
        fullScreenVC_glasspaint.mediaPath_Glasspaint = path_glasspaint
        fullScreenVC_glasspaint.isVideo_Glasspaint = isVideo_glasspaint
        fullScreenVC_glasspaint.modalPresentationStyle = .fullScreen
        fullScreenVC_glasspaint.modalTransitionStyle = .crossDissolve
        
        Navigation_Glasspaint.present_Glasspaint(
            viewController: fullScreenVC_glasspaint,
            animated: true,
            from: from_glasspaint
        )
    }
    
    // MARK: - 私有方法
    
    /// 处理媒体点击事件
    @objc private static func handleMediaTap_Glasspaint(_ gesture: UITapGestureRecognizer) {
        guard let mediaView_glasspaint = gesture.view,
              let mediaPath_glasspaint = objc_getAssociatedObject(mediaView_glasspaint, &AssociatedKeys_Glasspaint.mediaPathKey_glasspaint) as? String,
              let isVideo_glasspaint = objc_getAssociatedObject(mediaView_glasspaint, &AssociatedKeys_Glasspaint.isVideoKey_glasspaint) as? Bool,
              let fromVC_glasspaint = objc_getAssociatedObject(mediaView_glasspaint, &AssociatedKeys_Glasspaint.fromViewControllerKey_glasspaint) as? UIViewController else {
            print("⚠️ 无法获取媒体信息")
            return
        }
        
        // 添加点击动画效果
        UIView.animate(withDuration: 0.1, animations: {
            mediaView_glasspaint.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                mediaView_glasspaint.transform = .identity
            }
        }
        
        // 展示全屏媒体
        showFullScreen_Glasspaint(
            mediaPath_glasspaint: mediaPath_glasspaint,
            isVideo_glasspaint: isVideo_glasspaint,
            from: fromVC_glasspaint
        )
    }
}

// MARK: - 关联对象键

/// 关联对象键
private struct AssociatedKeys_Glasspaint {
    static var mediaPathKey_glasspaint = "mediaPathKey_glasspaint"
    static var isVideoKey_glasspaint = "isVideoKey_glasspaint"
    static var fromViewControllerKey_glasspaint = "fromViewControllerKey_glasspaint"
}

// MARK: - 全屏媒体展示视图控制器

/// 全屏媒体展示视图控制器
/// 功能：以原生全屏方式展示图片或视频，支持缩放、拖拽关闭
/// 特性：真正的全屏显示、双击缩放、捏合缩放、单击关闭、下拉关闭
/// 实现：使用专门的全屏ImageView实现scaleAspectFit模式，确保图片完整展示
class FullScreenMediaViewController_Glasspaint: UIViewController {
    
    // MARK: - 数据属性
    
    /// 媒体路径
    var mediaPath_Glasspaint: String?
    
    /// 是否为视频
    var isVideo_Glasspaint: Bool = false
    
    // MARK: - UI组件
    
    /// 滚动视图（用于缩放）
    private let scrollView_Glasspaint: UIScrollView = {
        let scrollView_glasspaint = UIScrollView()
        scrollView_glasspaint.backgroundColor = .black
        scrollView_glasspaint.minimumZoomScale = 1.0
        scrollView_glasspaint.maximumZoomScale = 3.0
        scrollView_glasspaint.showsVerticalScrollIndicator = false
        scrollView_glasspaint.showsHorizontalScrollIndicator = false
        return scrollView_glasspaint
    }()
    
    /// 媒体展示容器
    private let mediaContainerView_Glasspaint = UIView()
    
    /// 全屏图片视图
    /// 使用scaleAspectFit模式：保持图片比例完整显示，不裁剪，适配屏幕尺寸
    private let fullScreenImageView_Glasspaint: UIImageView = {
        let imageView_glasspaint = UIImageView()
        imageView_glasspaint.contentMode = .scaleAspectFit
        imageView_glasspaint.backgroundColor = .black
        imageView_glasspaint.clipsToBounds = true
        return imageView_glasspaint
    }()
    
    /// 视频播放图标
    private let playIconView_Glasspaint: UIView = {
        let view_glasspaint = UIView()
        view_glasspaint.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_glasspaint.layer.cornerRadius = 40
        view_glasspaint.isHidden = true
        return view_glasspaint
    }()
    
    private let playIconImageView_Glasspaint: UIImageView = {
        let imageView_glasspaint = UIImageView()
        imageView_glasspaint.image = UIImage(systemName: "play.fill")
        imageView_glasspaint.tintColor = .white
        imageView_glasspaint.contentMode = .scaleAspectFit
        return imageView_glasspaint
    }()
    
    /// 关闭按钮
    private let closeButton_Glasspaint: UIButton = {
        let button_glasspaint = UIButton(type: .system)
        let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        button_glasspaint.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config_glasspaint), for: .normal)
        button_glasspaint.tintColor = .white
        button_glasspaint.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button_glasspaint.layer.cornerRadius = 22
        button_glasspaint.clipsToBounds = true
        return button_glasspaint
    }()
    
    // MARK: - 属性
    
    /// 初始触摸位置
    private var initialTouchPoint_Glasspaint: CGPoint = .zero
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        setupGestures_Glasspaint()
        loadMedia_Glasspaint()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = .black
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.delegate = self
        
        // 媒体容器
        scrollView_Glasspaint.addSubview(mediaContainerView_Glasspaint)
        mediaContainerView_Glasspaint.addSubview(fullScreenImageView_Glasspaint)
        
        // 视频播放图标
        view.addSubview(playIconView_Glasspaint)
        playIconView_Glasspaint.addSubview(playIconImageView_Glasspaint)
        
        // 关闭按钮
        view.addSubview(closeButton_Glasspaint)
        closeButton_Glasspaint.addTarget(self, action: #selector(handleCloseTap_Glasspaint), for: .touchUpInside)
        
        setupConstraints_Glasspaint()
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mediaContainerView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(view)
        }
        
        // 全屏图片视图填满整个容器
        fullScreenImageView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 视频播放图标
        playIconView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        playIconImageView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        closeButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(44)
        }
    }
    
    /// 设置手势
    private func setupGestures_Glasspaint() {
        // 双击缩放手势
        let doubleTapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Glasspaint(_:)))
        doubleTapGesture_glasspaint.numberOfTapsRequired = 2
        scrollView_Glasspaint.addGestureRecognizer(doubleTapGesture_glasspaint)
        
        // 单击关闭手势
        let singleTapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Glasspaint))
        singleTapGesture_glasspaint.numberOfTapsRequired = 1
        singleTapGesture_glasspaint.require(toFail: doubleTapGesture_glasspaint)
        scrollView_Glasspaint.addGestureRecognizer(singleTapGesture_glasspaint)
        
        // 拖拽关闭手势
        let panGesture_glasspaint = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture_Glasspaint(_:)))
        panGesture_glasspaint.delegate = self
        view.addGestureRecognizer(panGesture_glasspaint)
    }
    
    // MARK: - 数据加载
    
    /// 加载媒体
    private func loadMedia_Glasspaint() {
        guard let path_glasspaint = mediaPath_Glasspaint else {
            print("⚠️ 媒体路径为空")
            return
        }
        
        // 显示视频播放图标
        playIconView_Glasspaint.isHidden = !isVideo_Glasspaint
        
        // 加载图片
        loadImage_Glasspaint(path_glasspaint: path_glasspaint)
    }
    
    /// 加载图片到全屏视图
    private func loadImage_Glasspaint(path_glasspaint: String) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_glasspaint = UIImage(systemName: path_glasspaint) {
            // 系统图标添加渐变背景
            let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 120, weight: .light)
            fullScreenImageView_Glasspaint.image = UIImage(systemName: path_glasspaint, withConfiguration: config_glasspaint)
            fullScreenImageView_Glasspaint.tintColor = .white
            fullScreenImageView_Glasspaint.contentMode = .scaleAspectFit
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_glasspaint = UIImage(named: path_glasspaint) {
            fullScreenImageView_Glasspaint.image = assetImage_glasspaint
            fullScreenImageView_Glasspaint.contentMode = .scaleAspectFit
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_glasspaint.hasPrefix("http://") || path_glasspaint.hasPrefix("https://") {
            if let url_glasspaint = URL(string: path_glasspaint) {
                fullScreenImageView_Glasspaint.kf.setImage(
                    with: url_glasspaint,
                    options: [.transition(.fade(0.3))]
                )
                fullScreenImageView_Glasspaint.contentMode = .scaleAspectFit
            }
            return
        }
        
        // 4. 尝试从文档目录加载
        let documentsPath_glasspaint = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_glasspaint = documentsPath_glasspaint.appendingPathComponent(path_glasspaint)
        
        if let documentImage_glasspaint = UIImage(contentsOfFile: fileURL_glasspaint.path) {
            fullScreenImageView_Glasspaint.image = documentImage_glasspaint
            fullScreenImageView_Glasspaint.contentMode = .scaleAspectFit
            print("✅ 从文档目录加载全屏媒体: \(path_glasspaint)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_glasspaint = UIImage(contentsOfFile: path_glasspaint) {
            fullScreenImageView_Glasspaint.image = localImage_glasspaint
            fullScreenImageView_Glasspaint.contentMode = .scaleAspectFit
            return
        }
        
        print("⚠️ 无法加载全屏媒体: \(path_glasspaint)")
    }
    
    // MARK: - 事件处理
    
    /// 处理关闭按钮点击
    @objc private func handleCloseTap_Glasspaint() {
        Navigation_Glasspaint.dismiss_Glasspaint(animated: true, from: self)
    }
    
    /// 处理单击
    @objc private func handleSingleTap_Glasspaint() {
        // 单击关闭
        handleCloseTap_Glasspaint()
    }
    
    /// 处理双击缩放
    @objc private func handleDoubleTap_Glasspaint(_ gesture: UITapGestureRecognizer) {
        if scrollView_Glasspaint.zoomScale > scrollView_Glasspaint.minimumZoomScale {
            // 已放大，缩小到原始大小
            scrollView_Glasspaint.setZoomScale(scrollView_Glasspaint.minimumZoomScale, animated: true)
        } else {
            // 未放大，放大到2倍
            let location_glasspaint = gesture.location(in: fullScreenImageView_Glasspaint)
            let zoomRect_glasspaint = zoomRectForScale_Glasspaint(scale_glasspaint: 2.0, center_glasspaint: location_glasspaint)
            scrollView_Glasspaint.zoom(to: zoomRect_glasspaint, animated: true)
        }
    }
    
    /// 处理拖拽手势
    @objc private func handlePanGesture_Glasspaint(_ gesture: UIPanGestureRecognizer) {
        // 只有在未缩放状态下才允许拖拽关闭
        guard scrollView_Glasspaint.zoomScale == scrollView_Glasspaint.minimumZoomScale else {
            return
        }
        
        let translation_glasspaint = gesture.translation(in: view)
        let velocity_glasspaint = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began:
            initialTouchPoint_Glasspaint = translation_glasspaint
            
        case .changed:
            // 只允许向下拖拽
            if translation_glasspaint.y > 0 {
                view.transform = CGAffineTransform(translationX: 0, y: translation_glasspaint.y)
                
                // 根据拖拽距离调整透明度
                let progress_glasspaint = min(translation_glasspaint.y / 300.0, 1.0)
                view.alpha = 1.0 - progress_glasspaint * 0.5
            }
            
        case .ended, .cancelled:
            // 如果拖拽距离或速度足够大，关闭视图
            if translation_glasspaint.y > 150 || velocity_glasspaint.y > 1000 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
                    self.view.alpha = 0
                }) { _ in
                    self.handleCloseTap_Glasspaint()
                }
            } else {
                // 恢复到原位
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                    self.view.alpha = 1.0
                }
            }
            
        default:
            break
        }
    }
    
    /// 计算缩放矩形
    private func zoomRectForScale_Glasspaint(scale_glasspaint: CGFloat, center_glasspaint: CGPoint) -> CGRect {
        var zoomRect_glasspaint = CGRect.zero
        zoomRect_glasspaint.size.width = fullScreenImageView_Glasspaint.frame.size.width / scale_glasspaint
        zoomRect_glasspaint.size.height = fullScreenImageView_Glasspaint.frame.size.height / scale_glasspaint
        zoomRect_glasspaint.origin.x = center_glasspaint.x - (zoomRect_glasspaint.size.width / 2.0)
        zoomRect_glasspaint.origin.y = center_glasspaint.y - (zoomRect_glasspaint.size.height / 2.0)
        return zoomRect_glasspaint
    }
}

// MARK: - UIScrollViewDelegate

extension FullScreenMediaViewController_Glasspaint: UIScrollViewDelegate {
    
    /// 返回需要缩放的视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mediaContainerView_Glasspaint
    }
    
    /// 缩放结束后居中显示
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX_glasspaint = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY_glasspaint = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        mediaContainerView_Glasspaint.center = CGPoint(
            x: scrollView.contentSize.width * 0.5 + offsetX_glasspaint,
            y: scrollView.contentSize.height * 0.5 + offsetY_glasspaint
        )
    }
}

// MARK: - UIGestureRecognizerDelegate

extension FullScreenMediaViewController_Glasspaint: UIGestureRecognizerDelegate {
    
    /// 允许同时识别多个手势
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
