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
///   - 媒体路径与 MediaDisplayView_Pane 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Pane:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Pane:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Pane: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Pane: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Pane: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Pane: MediaType_Pane = .none_Pane

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Pane = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Pane: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Pane: AVPlayer?
    private var playerLayer_Pane: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Pane: Any?
    /// 是否处于播放状态
    private var isPlaying_Pane = false

    // MARK: - UI：黑色背景

    private let backgroundView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Pane: UIScrollView = {
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

    private let imageView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_pane), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_pane), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Pane: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Pane: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_pane), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Pane: UILabel = {
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
        buildUI_Pane()
        buildConstraints_Pane()
        bindGestures_Pane()
        loadMedia_Pane()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.alpha = 0
        UIView.animate(withDuration: 0.25) { self.view.alpha = 1 }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupPlayer_Pane()
    }

    deinit {
        cleanupPlayer_Pane()
    }

    // MARK: - UI 搭建

    private func buildUI_Pane() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Pane)

        // 图片容器
        view.addSubview(scrollView_Pane)
        scrollView_Pane.addSubview(imageView_Pane)
        scrollView_Pane.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Pane)
        videoContainerView_Pane.addSubview(playPauseButton_Pane)
        videoContainerView_Pane.addSubview(progressBg_Pane)
        progressBg_Pane.addSubview(progressFill_Pane)

        // 通用
        view.addSubview(loadingIndicator_Pane)
        view.addSubview(topBar_Pane)
        topBar_Pane.addSubview(closeButton_Pane)
        topBar_Pane.addSubview(mediaTypeLabel_Pane)
        view.addSubview(bottomHint_Pane)
    }

    private func buildConstraints_Pane() {
        backgroundView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Pane.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Pane.frame = view.bounds

        videoContainerView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Pane.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Pane.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Pane.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Pane = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Pane.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Pane.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Pane?.frame = videoContainerView_Pane.bounds
        updateImageLayout_Pane()
    }

    // MARK: - 手势

    private func bindGestures_Pane() {
        // 双击缩放（图片）
        let doubleTap_pane = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Pane(_:)))
        doubleTap_pane.numberOfTapsRequired = 2
        scrollView_Pane.addGestureRecognizer(doubleTap_pane)

        // 单击关闭 / 视频播放切换
        let singleTap_pane = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Pane))
        singleTap_pane.numberOfTapsRequired = 1
        singleTap_pane.require(toFail: doubleTap_pane)
        scrollView_Pane.addGestureRecognizer(singleTap_pane)

        // 视频区单击切换播放/暂停
        let videoTap_pane = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Pane))
        videoContainerView_Pane.addGestureRecognizer(videoTap_pane)

        // 下滑关闭
        let pan_pane = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Pane(_:)))
        pan_pane.delegate = self
        view.addGestureRecognizer(pan_pane)

        // 播放/暂停按钮
        playPauseButton_Pane.addTarget(self, action: #selector(togglePlayPause_Pane), for: .touchUpInside)
        closeButton_Pane.addTarget(self, action: #selector(closeTapped_Pane), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Pane 和 isVideo_Pane 加载媒体
    private func loadMedia_Pane() {
        guard let path_pane = mediaPath_Pane, !path_pane.isEmpty else { showEmpty_Pane(); return }
        loadingIndicator_Pane.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Pane, let url_pane = resolveVideoURL_Pane(path_pane) {
            setupVideoPlayer_Pane(url_pane: url_pane)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_pane = resolveVideoURL_Pane(path_pane) {
            setupVideoPlayer_Pane(url_pane: url_pane)
            return
        }

        // 图片加载流程
        resolvedType_Pane = .image_Pane
        loadImage_Pane(path_pane: path_pane)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_pane: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Pane(_ path_pane: String) -> URL? {
        // Bundle 资源
        if let url_pane = MediaDisplayView_Pane.bundleVideoURL_Pane(named: path_pane) {
            return url_pane
        }
        // Documents 目录视频文件
        let docs_pane = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_pane in ["mp4", "mov", "m4v"] {
            let url_pane = docs_pane.appendingPathComponent("\(path_pane).\(ext_pane)")
            if FileManager.default.fileExists(atPath: url_pane.path) { return url_pane }
        }
        // 已带扩展名的文档目录文件
        let direct_pane = docs_pane.appendingPathComponent(path_pane)
        if FileManager.default.fileExists(atPath: direct_pane.path) { return direct_pane }
        // 网络视频 URL
        if (path_pane.hasPrefix("http://") || path_pane.hasPrefix("https://")),
           let url_pane = URL(string: path_pane) {
            let ext_pane = (path_pane as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_pane) { return url_pane }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Pane 策略对齐）
    /// - Parameter path_pane: 媒体路径
    private func loadImage_Pane(path_pane: String) {
        // SF Symbols
        if let img_pane = UIImage(systemName: path_pane) { applyImage_Pane(img_pane); return }
        // Assets
        if let img_pane = UIImage(named: path_pane) { applyImage_Pane(img_pane); return }
        // 网络
        if path_pane.hasPrefix("http://") || path_pane.hasPrefix("https://") {
            guard let url_pane = URL(string: path_pane) else { showEmpty_Pane(); return }
            imageView_Pane.kf.setImage(with: url_pane, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Pane.stopAnimating()
                if case .success(let v_pane) = result { self?.onImageLoaded_Pane(v_pane.image) }
                else { self?.showEmpty_Pane() }
            }
            return
        }
        // Documents 文件名
        let docs_pane = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_pane = docs_pane.appendingPathComponent(path_pane)
        if let img_pane = UIImage(contentsOfFile: docURL_pane.path) { applyImage_Pane(img_pane); return }
        // 完整路径
        if let img_pane = UIImage(contentsOfFile: path_pane) { applyImage_Pane(img_pane); return }
        showEmpty_Pane()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_pane: 视频文件 URL
    private func setupVideoPlayer_Pane(url_pane: URL) {
        resolvedType_Pane = .video_Pane

        // 切换到视频容器
        scrollView_Pane.isHidden         = true
        videoContainerView_Pane.isHidden = false
        progressBg_Pane.isHidden         = false

        mediaTypeLabel_Pane.text = "Video"

        let player_pane  = AVPlayer(url: url_pane)
        self.player_Pane = player_pane
        let layer_pane   = AVPlayerLayer(player: player_pane)
        layer_pane.videoGravity  = .resizeAspect
        layer_pane.frame         = videoContainerView_Pane.bounds
        layer_pane.backgroundColor = UIColor.black.cgColor
        videoContainerView_Pane.layer.insertSublayer(layer_pane, at: 0)
        playerLayer_Pane = layer_pane

        // 视频就绪后淡入播放按钮
        player_pane.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_pane = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Pane = player_pane.addPeriodicTimeObserver(
            forInterval: interval_pane,
            queue: .main
        ) { [weak self] time_pane in
            self?.updateProgress_Pane(currentTime_pane: time_pane)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Pane),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_pane.currentItem
        )

        loadingIndicator_Pane.stopAnimating()
        player_pane.play()
        isPlaying_Pane = true
        playPauseButton_Pane.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Pane.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_pane: AVPlayer 当前时间
    private func updateProgress_Pane(currentTime_pane: CMTime) {
        guard let duration_pane = player_Pane?.currentItem?.duration,
              duration_pane.isNumeric, duration_pane.seconds > 0 else { return }
        let progress_pane = CGFloat(currentTime_pane.seconds / duration_pane.seconds)
        let totalW_pane   = progressBg_Pane.bounds.width
        progressWidthCon_Pane?.update(offset: totalW_pane * min(max(progress_pane, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Pane() {
        player_Pane?.seek(to: .zero)
        isPlaying_Pane = false
        playPauseButton_Pane.isSelected = false
        progressWidthCon_Pane?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Pane() {
        if let token_pane = timeObserverToken_Pane {
            player_Pane?.removeTimeObserver(token_pane)
            timeObserverToken_Pane = nil
        }
        player_Pane?.removeObserver(self, forKeyPath: "status")
        player_Pane?.pause()
        player_Pane = nil
        playerLayer_Pane?.removeFromSuperlayer()
        playerLayer_Pane = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_pane = object as? AVPlayer,
              player_pane.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Pane() }
    }

    // MARK: - 图片辅助

    private func applyImage_Pane(_ image_pane: UIImage) {
        loadingIndicator_Pane.stopAnimating()
        imageView_Pane.image = image_pane
        imageSize_Pane       = image_pane.size
        mediaTypeLabel_Pane.text = "Photo"
        updateImageLayout_Pane()
    }

    private func onImageLoaded_Pane(_ image_pane: UIImage) {
        imageSize_Pane = image_pane.size
        mediaTypeLabel_Pane.text = "Photo"
        updateImageLayout_Pane()
    }

    private func showEmpty_Pane() {
        loadingIndicator_Pane.stopAnimating()
        imageView_Pane.image       = UIImage(systemName: "photo.slash")
        imageView_Pane.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Pane.contentMode = .center
    }

    private func updateImageLayout_Pane() {
        guard imageSize_Pane != .zero else {
            imageView_Pane.frame = view.bounds
            scrollView_Pane.contentSize = view.bounds.size
            return
        }
        let screenW_pane = view.bounds.width
        let screenH_pane = view.bounds.height
        let ratio_pane   = imageSize_Pane.height / imageSize_Pane.width
        let imgH_pane    = screenW_pane * ratio_pane
        let y_pane       = max(0, (screenH_pane - imgH_pane) / 2)
        imageView_Pane.frame        = CGRect(x: 0, y: y_pane, width: screenW_pane, height: imgH_pane)
        scrollView_Pane.contentSize = CGSize(width: screenW_pane,
                                              height: max(imgH_pane + y_pane * 2, screenH_pane))
        scrollView_Pane.zoomScale   = 1.0
        centerImageIfNeeded_Pane()
    }

    private func centerImageIfNeeded_Pane() {
        let offX_pane = max(0, (scrollView_Pane.bounds.width  - scrollView_Pane.contentSize.width)  / 2)
        let offY_pane = max(0, (scrollView_Pane.bounds.height - scrollView_Pane.contentSize.height) / 2)
        imageView_Pane.center = CGPoint(
            x: scrollView_Pane.contentSize.width  / 2 + offX_pane,
            y: scrollView_Pane.contentSize.height / 2 + offY_pane
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Pane(_ gesture_pane: UITapGestureRecognizer) {
        guard resolvedType_Pane == .image_Pane else { return }
        if scrollView_Pane.zoomScale > 1.0 {
            scrollView_Pane.setZoomScale(1.0, animated: true)
        } else {
            let pt_pane    = gesture_pane.location(in: imageView_Pane)
            let rect_pane  = zoomRect_Pane(scale_pane: 2.5, center_pane: pt_pane)
            scrollView_Pane.zoom(to: rect_pane, animated: true)
        }
    }

    @objc private func handleSingleTap_Pane() {
        guard resolvedType_Pane != .video_Pane,
              scrollView_Pane.zoomScale <= 1.01 else { return }
        dismissPage_Pane(velocity_pane: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Pane() {
        togglePlayPause_Pane()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Pane() {
        guard let player_pane = player_Pane else { return }
        if isPlaying_Pane {
            player_pane.pause()
            isPlaying_Pane = false
            playPauseButton_Pane.isSelected = false
        } else {
            player_pane.play()
            isPlaying_Pane = true
            playPauseButton_Pane.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Pane.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Pane else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Pane.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Pane() {
        dismissPage_Pane(velocity_pane: 0)
    }

    @objc private func handlePan_Pane(_ gesture_pane: UIPanGestureRecognizer) {
        guard scrollView_Pane.zoomScale <= 1.01 else { return }
        let translation_pane = gesture_pane.translation(in: view)
        let velocity_pane    = gesture_pane.velocity(in: view).y
        switch gesture_pane.state {
        case .changed:
            let progress_pane         = max(0, translation_pane.y / view.bounds.height)
            backgroundView_Pane.alpha = max(0, 1 - progress_pane * 1.5)
            topBar_Pane.alpha         = max(0, 1 - progress_pane * 2)
            bottomHint_Pane.alpha     = max(0, 1 - progress_pane * 2)
            let activeView_pane: UIView = resolvedType_Pane == .video_Pane
                ? videoContainerView_Pane : scrollView_Pane
            activeView_pane.transform = CGAffineTransform(
                translationX: translation_pane.x * 0.3,
                y: max(0, translation_pane.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_pane = translation_pane.y > view.bounds.height * 0.25 || velocity_pane > 900
            if shouldDismiss_pane {
                dismissPage_Pane(velocity_pane: velocity_pane)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Pane.transform         = .identity
                    self.videoContainerView_Pane.transform = .identity
                    self.backgroundView_Pane.alpha  = 1
                    self.topBar_Pane.alpha           = 1
                    self.bottomHint_Pane.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_pane: 下拉速度（影响动画时长）
    private func dismissPage_Pane(velocity_pane: CGFloat) {
        guard !isDismissing_Pane else { return }
        isDismissing_Pane = true
        player_Pane?.pause()
        let duration_pane = velocity_pane > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_pane, animations: {
            self.view.alpha = 0
            let activeView_pane: UIView = self.resolvedType_Pane == .video_Pane
                ? self.videoContainerView_Pane : self.scrollView_Pane
            activeView_pane.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Pane(scale_pane: CGFloat, center_pane: CGPoint) -> CGRect {
        let w_pane = scrollView_Pane.bounds.width  / scale_pane
        let h_pane = scrollView_Pane.bounds.height / scale_pane
        return CGRect(x: center_pane.x - w_pane / 2,
                      y: center_pane.y - h_pane / 2,
                      width: w_pane, height: h_pane)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Pane: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Pane }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Pane() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Pane: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_pane = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Pane.zoomScale <= 1.01 else { return false }
        let vel_pane = pan_pane.velocity(in: view)
        return abs(vel_pane.y) > abs(vel_pane.x) && vel_pane.y > 0
    }
}
