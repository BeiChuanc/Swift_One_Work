import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: - 全屏媒体浏览页

/// 全屏媒体浏览页
/// 核心作用：
///   - 图片模式：以沉浸式黑底全屏展示，支持双指缩放、双击放大/还原、下滑关闭
///   - 视频模式：通过 AVPlayer 播放 Bundle / Documents / 网络视频，支持播放/暂停、进度条、下滑关闭
/// 设计思路：
///   - 媒体路径与 MediaDisplayView_Clara 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Clara:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Clara:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Clara: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Clara: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Clara: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Clara: MediaType_Clara = .none_Clara

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Clara = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Clara: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Clara: AVPlayer?
    private var playerLayer_Clara: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Clara: Any?
    /// 是否处于播放状态
    private var isPlaying_Clara = false

    // MARK: - UI：黑色背景

    private let backgroundView_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Clara: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator   = false
        sv.showsHorizontalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.bouncesZoom      = true
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 4.0
        sv.backgroundColor  = .clear
        return sv
    }()

    private let imageView_Clara: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Clara: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Clara = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Clara), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Clara), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Clara: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Clara: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Clara: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Clara: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Clara: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Clara = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Clara), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Clara: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Clara: UILabel = {
        let l = UILabel()
        l.text          = "Swipe down to close"
        l.font          = .systemFont(ofSize: 11, weight: .regular)
        l.textColor     = UIColor.white.withAlphaComponent(0.45)
        l.textAlignment = .center
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI_Clara()
        buildConstraints_Clara()
        bindGestures_Clara()
        loadMedia_Clara()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 进场前预设透明，由 viewDidAppear 统一淡入，避免与系统转场动画叠加导致闪烁
        view.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) { self.view.alpha = 1 }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupPlayer_Clara()
    }

    deinit {
        cleanupPlayer_Clara()
    }

    // MARK: - UI 搭建

    private func buildUI_Clara() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Clara)

        // 图片容器
        view.addSubview(scrollView_Clara)
        scrollView_Clara.addSubview(imageView_Clara)
        scrollView_Clara.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Clara)
        videoContainerView_Clara.addSubview(playPauseButton_Clara)
        videoContainerView_Clara.addSubview(progressBg_Clara)
        progressBg_Clara.addSubview(progressFill_Clara)

        // 通用
        view.addSubview(loadingIndicator_Clara)
        view.addSubview(topBar_Clara)
        topBar_Clara.addSubview(closeButton_Clara)
        topBar_Clara.addSubview(mediaTypeLabel_Clara)
        view.addSubview(bottomHint_Clara)
    }

    private func buildConstraints_Clara() {
        backgroundView_Clara.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Clara.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Clara.frame = view.bounds

        videoContainerView_Clara.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Clara.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Clara.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Clara.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Clara = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Clara.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Clara.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Clara.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Clara.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Clara.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Clara.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Clara?.frame = videoContainerView_Clara.bounds
        updateImageLayout_Clara()
    }

    // MARK: - 手势

    private func bindGestures_Clara() {
        // 双击缩放（图片）
        let doubleTap_Clara = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Clara(_:)))
        doubleTap_Clara.numberOfTapsRequired = 2
        scrollView_Clara.addGestureRecognizer(doubleTap_Clara)

        // 单击关闭 / 视频播放切换
        let singleTap_Clara = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Clara))
        singleTap_Clara.numberOfTapsRequired = 1
        singleTap_Clara.require(toFail: doubleTap_Clara)
        scrollView_Clara.addGestureRecognizer(singleTap_Clara)

        // 视频区单击切换播放/暂停
        let videoTap_Clara = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Clara))
        videoContainerView_Clara.addGestureRecognizer(videoTap_Clara)

        // 下滑关闭
        let pan_Clara = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Clara(_:)))
        pan_Clara.delegate = self
        view.addGestureRecognizer(pan_Clara)

        // 播放/暂停按钮
        playPauseButton_Clara.addTarget(self, action: #selector(togglePlayPause_Clara), for: .touchUpInside)
        closeButton_Clara.addTarget(self, action: #selector(closeTapped_Clara), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Clara 和 isVideo_Clara 加载媒体
    private func loadMedia_Clara() {
        guard let path_Clara = mediaPath_Clara, !path_Clara.isEmpty else { showEmpty_Clara(); return }
        loadingIndicator_Clara.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Clara, let url_Clara = resolveVideoURL_Clara(path_Clara) {
            setupVideoPlayer_Clara(url_Clara: url_Clara)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Clara = resolveVideoURL_Clara(path_Clara) {
            setupVideoPlayer_Clara(url_Clara: url_Clara)
            return
        }

        // 图片加载流程
        resolvedType_Clara = .image_Clara
        loadImage_Clara(path_Clara: path_Clara)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Clara: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Clara(_ path_Clara: String) -> URL? {
        // Bundle 资源
        if let url_Clara = MediaDisplayView_Clara.bundleVideoURL_Clara(named: path_Clara) {
            return url_Clara
        }
        // Documents 目录视频文件
        let docs_Clara = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Clara in ["mp4", "mov", "m4v"] {
            let url_Clara = docs_Clara.appendingPathComponent("\(path_Clara).\(ext_Clara)")
            if FileManager.default.fileExists(atPath: url_Clara.path) { return url_Clara }
        }
        // 已带扩展名的文档目录文件
        let direct_Clara = docs_Clara.appendingPathComponent(path_Clara)
        if FileManager.default.fileExists(atPath: direct_Clara.path) { return direct_Clara }
        // 网络视频 URL
        if (path_Clara.hasPrefix("http://") || path_Clara.hasPrefix("https://")),
           let url_Clara = URL(string: path_Clara) {
            let ext_Clara = (path_Clara as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Clara) { return url_Clara }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Clara 策略对齐）
    /// - Parameter path_Clara: 媒体路径
    private func loadImage_Clara(path_Clara: String) {
        // SF Symbols
        if let img_Clara = UIImage(systemName: path_Clara) { applyImage_Clara(img_Clara); return }
        // Assets
        if let img_Clara = UIImage(named: path_Clara) { applyImage_Clara(img_Clara); return }
        // 网络
        if path_Clara.hasPrefix("http://") || path_Clara.hasPrefix("https://") {
            guard let url_Clara = URL(string: path_Clara) else { showEmpty_Clara(); return }
            imageView_Clara.kf.setImage(with: url_Clara, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Clara.stopAnimating()
                if case .success(let v_Clara) = result { self?.onImageLoaded_Clara(v_Clara.image) }
                else { self?.showEmpty_Clara() }
            }
            return
        }
        // Documents 文件名
        let docs_Clara = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Clara = docs_Clara.appendingPathComponent(path_Clara)
        if let img_Clara = UIImage(contentsOfFile: docURL_Clara.path) { applyImage_Clara(img_Clara); return }
        // 完整路径
        if let img_Clara = UIImage(contentsOfFile: path_Clara) { applyImage_Clara(img_Clara); return }
        showEmpty_Clara()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Clara: 视频文件 URL
    private func setupVideoPlayer_Clara(url_Clara: URL) {
        resolvedType_Clara = .video_Clara

        // 切换到视频容器
        scrollView_Clara.isHidden         = true
        videoContainerView_Clara.isHidden = false
        progressBg_Clara.isHidden         = false

        mediaTypeLabel_Clara.text = "Video"

        let player_Clara  = AVPlayer(url: url_Clara)
        self.player_Clara = player_Clara
        let layer_Clara   = AVPlayerLayer(player: player_Clara)
        layer_Clara.videoGravity  = .resizeAspect
        layer_Clara.frame         = videoContainerView_Clara.bounds
        layer_Clara.backgroundColor = UIColor.black.cgColor
        videoContainerView_Clara.layer.insertSublayer(layer_Clara, at: 0)
        playerLayer_Clara = layer_Clara

        // 视频就绪后淡入播放按钮
        player_Clara.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Clara = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Clara = player_Clara.addPeriodicTimeObserver(
            forInterval: interval_Clara,
            queue: .main
        ) { [weak self] time_Clara in
            self?.updateProgress_Clara(currentTime_Clara: time_Clara)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Clara),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Clara.currentItem
        )

        loadingIndicator_Clara.stopAnimating()
        player_Clara.play()
        isPlaying_Clara = true
        playPauseButton_Clara.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Clara.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Clara: AVPlayer 当前时间
    private func updateProgress_Clara(currentTime_Clara: CMTime) {
        guard let duration_Clara = player_Clara?.currentItem?.duration,
              duration_Clara.isNumeric, duration_Clara.seconds > 0 else { return }
        let progress_Clara = CGFloat(currentTime_Clara.seconds / duration_Clara.seconds)
        let totalW_Clara   = progressBg_Clara.bounds.width
        progressWidthCon_Clara?.update(offset: totalW_Clara * min(max(progress_Clara, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Clara() {
        player_Clara?.seek(to: .zero)
        isPlaying_Clara = false
        playPauseButton_Clara.isSelected = false
        progressWidthCon_Clara?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Clara() {
        if let token_Clara = timeObserverToken_Clara {
            player_Clara?.removeTimeObserver(token_Clara)
            timeObserverToken_Clara = nil
        }
        player_Clara?.removeObserver(self, forKeyPath: "status")
        player_Clara?.pause()
        player_Clara = nil
        playerLayer_Clara?.removeFromSuperlayer()
        playerLayer_Clara = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Clara = object as? AVPlayer,
              player_Clara.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Clara() }
    }

    // MARK: - 图片辅助

    private func applyImage_Clara(_ image_Clara: UIImage) {
        loadingIndicator_Clara.stopAnimating()
        imageView_Clara.image = image_Clara
        imageSize_Clara       = image_Clara.size
        mediaTypeLabel_Clara.text = "Photo"
        updateImageLayout_Clara()
    }

    private func onImageLoaded_Clara(_ image_Clara: UIImage) {
        imageSize_Clara = image_Clara.size
        mediaTypeLabel_Clara.text = "Photo"
        updateImageLayout_Clara()
    }

    private func showEmpty_Clara() {
        loadingIndicator_Clara.stopAnimating()
        imageView_Clara.image       = UIImage(systemName: "photo.slash")
        imageView_Clara.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Clara.contentMode = .center
    }

    private func updateImageLayout_Clara() {
        guard imageSize_Clara != .zero else {
            imageView_Clara.frame = view.bounds
            scrollView_Clara.contentSize = view.bounds.size
            return
        }
        let screenW_Clara = view.bounds.width
        let screenH_Clara = view.bounds.height
        let ratio_Clara   = imageSize_Clara.height / imageSize_Clara.width
        let imgH_Clara    = screenW_Clara * ratio_Clara
        let y_Clara       = max(0, (screenH_Clara - imgH_Clara) / 2)
        imageView_Clara.frame        = CGRect(x: 0, y: y_Clara, width: screenW_Clara, height: imgH_Clara)
        scrollView_Clara.contentSize = CGSize(width: screenW_Clara,
                                              height: max(imgH_Clara + y_Clara * 2, screenH_Clara))
        scrollView_Clara.zoomScale   = 1.0
        centerImageIfNeeded_Clara()
    }

    private func centerImageIfNeeded_Clara() {
        let offX_Clara = max(0, (scrollView_Clara.bounds.width  - scrollView_Clara.contentSize.width)  / 2)
        let offY_Clara = max(0, (scrollView_Clara.bounds.height - scrollView_Clara.contentSize.height) / 2)
        imageView_Clara.center = CGPoint(
            x: scrollView_Clara.contentSize.width  / 2 + offX_Clara,
            y: scrollView_Clara.contentSize.height / 2 + offY_Clara
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Clara(_ gesture_Clara: UITapGestureRecognizer) {
        guard resolvedType_Clara == .image_Clara else { return }
        if scrollView_Clara.zoomScale > 1.0 {
            scrollView_Clara.setZoomScale(1.0, animated: true)
        } else {
            let pt_Clara    = gesture_Clara.location(in: imageView_Clara)
            let rect_Clara  = zoomRect_Clara(scale_Clara: 2.5, center_Clara: pt_Clara)
            scrollView_Clara.zoom(to: rect_Clara, animated: true)
        }
    }

    @objc private func handleSingleTap_Clara() {
        guard resolvedType_Clara != .video_Clara,
              scrollView_Clara.zoomScale <= 1.01 else { return }
        dismissPage_Clara(velocity_Clara: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Clara() {
        togglePlayPause_Clara()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Clara() {
        guard let player_Clara = player_Clara else { return }
        if isPlaying_Clara {
            player_Clara.pause()
            isPlaying_Clara = false
            playPauseButton_Clara.isSelected = false
        } else {
            player_Clara.play()
            isPlaying_Clara = true
            playPauseButton_Clara.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Clara.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Clara else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Clara.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Clara() {
        dismissPage_Clara(velocity_Clara: 0)
    }

    @objc private func handlePan_Clara(_ gesture_Clara: UIPanGestureRecognizer) {
        guard scrollView_Clara.zoomScale <= 1.01 else { return }
        let translation_Clara = gesture_Clara.translation(in: view)
        let velocity_Clara    = gesture_Clara.velocity(in: view).y
        switch gesture_Clara.state {
        case .changed:
            let progress_Clara         = max(0, translation_Clara.y / view.bounds.height)
            backgroundView_Clara.alpha = max(0, 1 - progress_Clara * 1.5)
            topBar_Clara.alpha         = max(0, 1 - progress_Clara * 2)
            bottomHint_Clara.alpha     = max(0, 1 - progress_Clara * 2)
            let activeView_Clara: UIView = resolvedType_Clara == .video_Clara
                ? videoContainerView_Clara : scrollView_Clara
            activeView_Clara.transform = CGAffineTransform(
                translationX: translation_Clara.x * 0.3,
                y: max(0, translation_Clara.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Clara = translation_Clara.y > view.bounds.height * 0.25 || velocity_Clara > 900
            if shouldDismiss_Clara {
                dismissPage_Clara(velocity_Clara: velocity_Clara)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Clara.transform         = .identity
                    self.videoContainerView_Clara.transform = .identity
                    self.backgroundView_Clara.alpha  = 1
                    self.topBar_Clara.alpha           = 1
                    self.bottomHint_Clara.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Clara: 下拉速度（影响动画时长）
    private func dismissPage_Clara(velocity_Clara: CGFloat) {
        guard !isDismissing_Clara else { return }
        isDismissing_Clara = true
        player_Clara?.pause()
        let duration_Clara = velocity_Clara > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Clara, animations: {
            self.view.alpha = 0
            let activeView_Clara: UIView = self.resolvedType_Clara == .video_Clara
                ? self.videoContainerView_Clara : self.scrollView_Clara
            activeView_Clara.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Clara(scale_Clara: CGFloat, center_Clara: CGPoint) -> CGRect {
        let w_Clara = scrollView_Clara.bounds.width  / scale_Clara
        let h_Clara = scrollView_Clara.bounds.height / scale_Clara
        return CGRect(x: center_Clara.x - w_Clara / 2,
                      y: center_Clara.y - h_Clara / 2,
                      width: w_Clara, height: h_Clara)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Clara: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Clara }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Clara() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Clara: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Clara = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Clara.zoomScale <= 1.01 else { return false }
        let vel_Clara = pan_Clara.velocity(in: view)
        return abs(vel_Clara.y) > abs(vel_Clara.x) && vel_Clara.y > 0
    }
}
