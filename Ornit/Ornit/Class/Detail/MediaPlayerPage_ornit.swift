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
///   - 媒体路径与 MediaDisplayView_Ornit 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Ornit:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Ornit:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Ornit: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Ornit: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Ornit: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Ornit: MediaType_Ornit = .none_Ornit

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Ornit = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Ornit: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Ornit: AVPlayer?
    private var playerLayer_Ornit: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Ornit: Any?
    /// 是否处于播放状态
    private var isPlaying_Ornit = false

    // MARK: - UI：黑色背景

    private let backgroundView_Ornit: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Ornit: UIScrollView = {
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

    private let imageView_Ornit: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Ornit: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Ornit: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Ornit = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Ornit), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Ornit), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Ornit: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Ornit: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Ornit: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Ornit: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Ornit: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Ornit: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Ornit = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Ornit), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Ornit: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Ornit: UILabel = {
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
        buildUI_Ornit()
        buildConstraints_Ornit()
        bindGestures_Ornit()
        loadMedia_Ornit()
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
        cleanupPlayer_Ornit()
    }

    deinit {
        cleanupPlayer_Ornit()
    }

    // MARK: - UI 搭建

    private func buildUI_Ornit() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Ornit)

        // 图片容器
        view.addSubview(scrollView_Ornit)
        scrollView_Ornit.addSubview(imageView_Ornit)
        scrollView_Ornit.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Ornit)
        videoContainerView_Ornit.addSubview(playPauseButton_Ornit)
        videoContainerView_Ornit.addSubview(progressBg_Ornit)
        progressBg_Ornit.addSubview(progressFill_Ornit)

        // 通用
        view.addSubview(loadingIndicator_Ornit)
        view.addSubview(topBar_Ornit)
        topBar_Ornit.addSubview(closeButton_Ornit)
        topBar_Ornit.addSubview(mediaTypeLabel_Ornit)
        view.addSubview(bottomHint_Ornit)
    }

    private func buildConstraints_Ornit() {
        backgroundView_Ornit.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Ornit.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Ornit.frame = view.bounds

        videoContainerView_Ornit.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Ornit.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Ornit.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Ornit.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Ornit = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Ornit.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Ornit.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Ornit.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Ornit.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Ornit.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Ornit.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Ornit?.frame = videoContainerView_Ornit.bounds
        updateImageLayout_Ornit()
    }

    // MARK: - 手势

    private func bindGestures_Ornit() {
        // 双击缩放（图片）
        let doubleTap_Ornit = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Ornit(_:)))
        doubleTap_Ornit.numberOfTapsRequired = 2
        scrollView_Ornit.addGestureRecognizer(doubleTap_Ornit)

        // 单击关闭 / 视频播放切换
        let singleTap_Ornit = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Ornit))
        singleTap_Ornit.numberOfTapsRequired = 1
        singleTap_Ornit.require(toFail: doubleTap_Ornit)
        scrollView_Ornit.addGestureRecognizer(singleTap_Ornit)

        // 视频区单击切换播放/暂停
        let videoTap_Ornit = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Ornit))
        videoContainerView_Ornit.addGestureRecognizer(videoTap_Ornit)

        // 下滑关闭
        let pan_Ornit = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Ornit(_:)))
        pan_Ornit.delegate = self
        view.addGestureRecognizer(pan_Ornit)

        // 播放/暂停按钮
        playPauseButton_Ornit.addTarget(self, action: #selector(togglePlayPause_Ornit), for: .touchUpInside)
        closeButton_Ornit.addTarget(self, action: #selector(closeTapped_Ornit), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Ornit 和 isVideo_Ornit 加载媒体
    private func loadMedia_Ornit() {
        guard let path_Ornit = mediaPath_Ornit, !path_Ornit.isEmpty else { showEmpty_Ornit(); return }
        loadingIndicator_Ornit.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Ornit, let url_Ornit = resolveVideoURL_Ornit(path_Ornit) {
            setupVideoPlayer_Ornit(url_Ornit: url_Ornit)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Ornit = resolveVideoURL_Ornit(path_Ornit) {
            setupVideoPlayer_Ornit(url_Ornit: url_Ornit)
            return
        }

        // 图片加载流程
        resolvedType_Ornit = .image_Ornit
        loadImage_Ornit(path_Ornit: path_Ornit)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Ornit: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Ornit(_ path_Ornit: String) -> URL? {
        // Bundle 资源
        if let url_Ornit = MediaDisplayView_Ornit.bundleVideoURL_Ornit(named: path_Ornit) {
            return url_Ornit
        }
        // Documents 目录视频文件
        let docs_Ornit = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Ornit in ["mp4", "mov", "m4v"] {
            let url_Ornit = docs_Ornit.appendingPathComponent("\(path_Ornit).\(ext_Ornit)")
            if FileManager.default.fileExists(atPath: url_Ornit.path) { return url_Ornit }
        }
        // 已带扩展名的文档目录文件
        let direct_Ornit = docs_Ornit.appendingPathComponent(path_Ornit)
        if FileManager.default.fileExists(atPath: direct_Ornit.path) { return direct_Ornit }
        // 网络视频 URL
        if (path_Ornit.hasPrefix("http://") || path_Ornit.hasPrefix("https://")),
           let url_Ornit = URL(string: path_Ornit) {
            let ext_Ornit = (path_Ornit as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Ornit) { return url_Ornit }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Ornit 策略对齐）
    /// - Parameter path_Ornit: 媒体路径
    private func loadImage_Ornit(path_Ornit: String) {
        // SF Symbols
        if let img_Ornit = UIImage(systemName: path_Ornit) { applyImage_Ornit(img_Ornit); return }
        // Assets
        if let img_Ornit = UIImage(named: path_Ornit) { applyImage_Ornit(img_Ornit); return }
        // 网络
        if path_Ornit.hasPrefix("http://") || path_Ornit.hasPrefix("https://") {
            guard let url_Ornit = URL(string: path_Ornit) else { showEmpty_Ornit(); return }
            imageView_Ornit.kf.setImage(with: url_Ornit, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Ornit.stopAnimating()
                if case .success(let v_Ornit) = result { self?.onImageLoaded_Ornit(v_Ornit.image) }
                else { self?.showEmpty_Ornit() }
            }
            return
        }
        // Documents 文件名
        let docs_Ornit = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Ornit = docs_Ornit.appendingPathComponent(path_Ornit)
        if let img_Ornit = UIImage(contentsOfFile: docURL_Ornit.path) { applyImage_Ornit(img_Ornit); return }
        // 完整路径
        if let img_Ornit = UIImage(contentsOfFile: path_Ornit) { applyImage_Ornit(img_Ornit); return }
        showEmpty_Ornit()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Ornit: 视频文件 URL
    private func setupVideoPlayer_Ornit(url_Ornit: URL) {
        resolvedType_Ornit = .video_Ornit

        // 切换到视频容器
        scrollView_Ornit.isHidden         = true
        videoContainerView_Ornit.isHidden = false
        progressBg_Ornit.isHidden         = false

        mediaTypeLabel_Ornit.text = "Video"

        let player_Ornit  = AVPlayer(url: url_Ornit)
        self.player_Ornit = player_Ornit
        let layer_Ornit   = AVPlayerLayer(player: player_Ornit)
        layer_Ornit.videoGravity  = .resizeAspect
        layer_Ornit.frame         = videoContainerView_Ornit.bounds
        layer_Ornit.backgroundColor = UIColor.black.cgColor
        videoContainerView_Ornit.layer.insertSublayer(layer_Ornit, at: 0)
        playerLayer_Ornit = layer_Ornit

        // 视频就绪后淡入播放按钮
        player_Ornit.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Ornit = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Ornit = player_Ornit.addPeriodicTimeObserver(
            forInterval: interval_Ornit,
            queue: .main
        ) { [weak self] time_Ornit in
            self?.updateProgress_Ornit(currentTime_Ornit: time_Ornit)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Ornit),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Ornit.currentItem
        )

        loadingIndicator_Ornit.stopAnimating()
        player_Ornit.play()
        isPlaying_Ornit = true
        playPauseButton_Ornit.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Ornit.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Ornit: AVPlayer 当前时间
    private func updateProgress_Ornit(currentTime_Ornit: CMTime) {
        guard let duration_Ornit = player_Ornit?.currentItem?.duration,
              duration_Ornit.isNumeric, duration_Ornit.seconds > 0 else { return }
        let progress_Ornit = CGFloat(currentTime_Ornit.seconds / duration_Ornit.seconds)
        let totalW_Ornit   = progressBg_Ornit.bounds.width
        progressWidthCon_Ornit?.update(offset: totalW_Ornit * min(max(progress_Ornit, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Ornit() {
        player_Ornit?.seek(to: .zero)
        isPlaying_Ornit = false
        playPauseButton_Ornit.isSelected = false
        progressWidthCon_Ornit?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Ornit() {
        if let token_Ornit = timeObserverToken_Ornit {
            player_Ornit?.removeTimeObserver(token_Ornit)
            timeObserverToken_Ornit = nil
        }
        player_Ornit?.removeObserver(self, forKeyPath: "status")
        player_Ornit?.pause()
        player_Ornit = nil
        playerLayer_Ornit?.removeFromSuperlayer()
        playerLayer_Ornit = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Ornit = object as? AVPlayer,
              player_Ornit.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Ornit() }
    }

    // MARK: - 图片辅助

    private func applyImage_Ornit(_ image_Ornit: UIImage) {
        loadingIndicator_Ornit.stopAnimating()
        imageView_Ornit.image = image_Ornit
        imageSize_Ornit       = image_Ornit.size
        mediaTypeLabel_Ornit.text = "Photo"
        updateImageLayout_Ornit()
    }

    private func onImageLoaded_Ornit(_ image_Ornit: UIImage) {
        imageSize_Ornit = image_Ornit.size
        mediaTypeLabel_Ornit.text = "Photo"
        updateImageLayout_Ornit()
    }

    private func showEmpty_Ornit() {
        loadingIndicator_Ornit.stopAnimating()
        imageView_Ornit.image       = UIImage(systemName: "photo.slash")
        imageView_Ornit.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Ornit.contentMode = .center
    }

    private func updateImageLayout_Ornit() {
        guard imageSize_Ornit != .zero else {
            imageView_Ornit.frame = view.bounds
            scrollView_Ornit.contentSize = view.bounds.size
            return
        }
        let screenW_Ornit = view.bounds.width
        let screenH_Ornit = view.bounds.height
        let ratio_Ornit   = imageSize_Ornit.height / imageSize_Ornit.width
        let imgH_Ornit    = screenW_Ornit * ratio_Ornit
        let y_Ornit       = max(0, (screenH_Ornit - imgH_Ornit) / 2)
        imageView_Ornit.frame        = CGRect(x: 0, y: y_Ornit, width: screenW_Ornit, height: imgH_Ornit)
        scrollView_Ornit.contentSize = CGSize(width: screenW_Ornit,
                                              height: max(imgH_Ornit + y_Ornit * 2, screenH_Ornit))
        scrollView_Ornit.zoomScale   = 1.0
        centerImageIfNeeded_Ornit()
    }

    private func centerImageIfNeeded_Ornit() {
        let offX_Ornit = max(0, (scrollView_Ornit.bounds.width  - scrollView_Ornit.contentSize.width)  / 2)
        let offY_Ornit = max(0, (scrollView_Ornit.bounds.height - scrollView_Ornit.contentSize.height) / 2)
        imageView_Ornit.center = CGPoint(
            x: scrollView_Ornit.contentSize.width  / 2 + offX_Ornit,
            y: scrollView_Ornit.contentSize.height / 2 + offY_Ornit
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Ornit(_ gesture_Ornit: UITapGestureRecognizer) {
        guard resolvedType_Ornit == .image_Ornit else { return }
        if scrollView_Ornit.zoomScale > 1.0 {
            scrollView_Ornit.setZoomScale(1.0, animated: true)
        } else {
            let pt_Ornit    = gesture_Ornit.location(in: imageView_Ornit)
            let rect_Ornit  = zoomRect_Ornit(scale_Ornit: 2.5, center_Ornit: pt_Ornit)
            scrollView_Ornit.zoom(to: rect_Ornit, animated: true)
        }
    }

    @objc private func handleSingleTap_Ornit() {
        guard resolvedType_Ornit != .video_Ornit,
              scrollView_Ornit.zoomScale <= 1.01 else { return }
        dismissPage_Ornit(velocity_Ornit: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Ornit() {
        togglePlayPause_Ornit()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Ornit() {
        guard let player_Ornit = player_Ornit else { return }
        if isPlaying_Ornit {
            player_Ornit.pause()
            isPlaying_Ornit = false
            playPauseButton_Ornit.isSelected = false
        } else {
            player_Ornit.play()
            isPlaying_Ornit = true
            playPauseButton_Ornit.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Ornit.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Ornit else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Ornit.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Ornit() {
        dismissPage_Ornit(velocity_Ornit: 0)
    }

    @objc private func handlePan_Ornit(_ gesture_Ornit: UIPanGestureRecognizer) {
        guard scrollView_Ornit.zoomScale <= 1.01 else { return }
        let translation_Ornit = gesture_Ornit.translation(in: view)
        let velocity_Ornit    = gesture_Ornit.velocity(in: view).y
        switch gesture_Ornit.state {
        case .changed:
            let progress_Ornit         = max(0, translation_Ornit.y / view.bounds.height)
            backgroundView_Ornit.alpha = max(0, 1 - progress_Ornit * 1.5)
            topBar_Ornit.alpha         = max(0, 1 - progress_Ornit * 2)
            bottomHint_Ornit.alpha     = max(0, 1 - progress_Ornit * 2)
            let activeView_Ornit: UIView = resolvedType_Ornit == .video_Ornit
                ? videoContainerView_Ornit : scrollView_Ornit
            activeView_Ornit.transform = CGAffineTransform(
                translationX: translation_Ornit.x * 0.3,
                y: max(0, translation_Ornit.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Ornit = translation_Ornit.y > view.bounds.height * 0.25 || velocity_Ornit > 900
            if shouldDismiss_Ornit {
                dismissPage_Ornit(velocity_Ornit: velocity_Ornit)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Ornit.transform         = .identity
                    self.videoContainerView_Ornit.transform = .identity
                    self.backgroundView_Ornit.alpha  = 1
                    self.topBar_Ornit.alpha           = 1
                    self.bottomHint_Ornit.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Ornit: 下拉速度（影响动画时长）
    private func dismissPage_Ornit(velocity_Ornit: CGFloat) {
        guard !isDismissing_Ornit else { return }
        isDismissing_Ornit = true
        player_Ornit?.pause()
        let duration_Ornit = velocity_Ornit > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Ornit, animations: {
            self.view.alpha = 0
            let activeView_Ornit: UIView = self.resolvedType_Ornit == .video_Ornit
                ? self.videoContainerView_Ornit : self.scrollView_Ornit
            activeView_Ornit.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Ornit(scale_Ornit: CGFloat, center_Ornit: CGPoint) -> CGRect {
        let w_Ornit = scrollView_Ornit.bounds.width  / scale_Ornit
        let h_Ornit = scrollView_Ornit.bounds.height / scale_Ornit
        return CGRect(x: center_Ornit.x - w_Ornit / 2,
                      y: center_Ornit.y - h_Ornit / 2,
                      width: w_Ornit, height: h_Ornit)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Ornit: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Ornit }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Ornit() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Ornit: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Ornit = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Ornit.zoomScale <= 1.01 else { return false }
        let vel_Ornit = pan_Ornit.velocity(in: view)
        return abs(vel_Ornit.y) > abs(vel_Ornit.x) && vel_Ornit.y > 0
    }
}
