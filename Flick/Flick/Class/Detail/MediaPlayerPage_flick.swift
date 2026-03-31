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
///   - 媒体路径与 MediaDisplayView_Flick 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Flick:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Flick:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Flick: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Flick: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Flick: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Flick: MediaType_Flick = .none_Flick

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Flick = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Flick: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Flick: AVPlayer?
    private var playerLayer_Flick: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Flick: Any?
    /// 是否处于播放状态
    private var isPlaying_Flick = false

    // MARK: - UI：黑色背景

    private let backgroundView_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Flick: UIScrollView = {
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

    private let imageView_Flick: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Flick: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Flick = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Flick), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Flick), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Flick: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Flick: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Flick: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Flick: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Flick: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Flick = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Flick), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Flick: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Flick: UILabel = {
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
        buildUI_Flick()
        buildConstraints_Flick()
        bindGestures_Flick()
        loadMedia_Flick()
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
        cleanupPlayer_Flick()
    }

    deinit {
        cleanupPlayer_Flick()
    }

    // MARK: - UI 搭建

    private func buildUI_Flick() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Flick)

        // 图片容器
        view.addSubview(scrollView_Flick)
        scrollView_Flick.addSubview(imageView_Flick)
        scrollView_Flick.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Flick)
        videoContainerView_Flick.addSubview(playPauseButton_Flick)
        videoContainerView_Flick.addSubview(progressBg_Flick)
        progressBg_Flick.addSubview(progressFill_Flick)

        // 通用
        view.addSubview(loadingIndicator_Flick)
        view.addSubview(topBar_Flick)
        topBar_Flick.addSubview(closeButton_Flick)
        topBar_Flick.addSubview(mediaTypeLabel_Flick)
        view.addSubview(bottomHint_Flick)
    }

    private func buildConstraints_Flick() {
        backgroundView_Flick.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Flick.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Flick.frame = view.bounds

        videoContainerView_Flick.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Flick.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Flick.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Flick.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Flick = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Flick.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Flick.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Flick.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Flick.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Flick.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Flick.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Flick?.frame = videoContainerView_Flick.bounds
        updateImageLayout_Flick()
    }

    // MARK: - 手势

    private func bindGestures_Flick() {
        // 双击缩放（图片）
        let doubleTap_Flick = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Flick(_:)))
        doubleTap_Flick.numberOfTapsRequired = 2
        scrollView_Flick.addGestureRecognizer(doubleTap_Flick)

        // 单击关闭 / 视频播放切换
        let singleTap_Flick = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Flick))
        singleTap_Flick.numberOfTapsRequired = 1
        singleTap_Flick.require(toFail: doubleTap_Flick)
        scrollView_Flick.addGestureRecognizer(singleTap_Flick)

        // 视频区单击切换播放/暂停
        let videoTap_Flick = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Flick))
        videoContainerView_Flick.addGestureRecognizer(videoTap_Flick)

        // 下滑关闭
        let pan_Flick = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Flick(_:)))
        pan_Flick.delegate = self
        view.addGestureRecognizer(pan_Flick)

        // 播放/暂停按钮
        playPauseButton_Flick.addTarget(self, action: #selector(togglePlayPause_Flick), for: .touchUpInside)
        closeButton_Flick.addTarget(self, action: #selector(closeTapped_Flick), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Flick 和 isVideo_Flick 加载媒体
    private func loadMedia_Flick() {
        guard let path_Flick = mediaPath_Flick, !path_Flick.isEmpty else { showEmpty_Flick(); return }
        loadingIndicator_Flick.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Flick, let url_Flick = resolveVideoURL_Flick(path_Flick) {
            setupVideoPlayer_Flick(url_Flick: url_Flick)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Flick = resolveVideoURL_Flick(path_Flick) {
            setupVideoPlayer_Flick(url_Flick: url_Flick)
            return
        }

        // 图片加载流程
        resolvedType_Flick = .image_Flick
        loadImage_Flick(path_Flick: path_Flick)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Flick: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Flick(_ path_Flick: String) -> URL? {
        // Bundle 资源
        if let url_Flick = MediaDisplayView_Flick.bundleVideoURL_Flick(named: path_Flick) {
            return url_Flick
        }
        // Documents 目录视频文件
        let docs_Flick = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Flick in ["mp4", "mov", "m4v"] {
            let url_Flick = docs_Flick.appendingPathComponent("\(path_Flick).\(ext_Flick)")
            if FileManager.default.fileExists(atPath: url_Flick.path) { return url_Flick }
        }
        // 已带扩展名的文档目录文件
        let direct_Flick = docs_Flick.appendingPathComponent(path_Flick)
        if FileManager.default.fileExists(atPath: direct_Flick.path) { return direct_Flick }
        // 网络视频 URL
        if (path_Flick.hasPrefix("http://") || path_Flick.hasPrefix("https://")),
           let url_Flick = URL(string: path_Flick) {
            let ext_Flick = (path_Flick as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Flick) { return url_Flick }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Flick 策略对齐）
    /// - Parameter path_Flick: 媒体路径
    private func loadImage_Flick(path_Flick: String) {
        // SF Symbols
        if let img_Flick = UIImage(systemName: path_Flick) { applyImage_Flick(img_Flick); return }
        // Assets
        if let img_Flick = UIImage(named: path_Flick) { applyImage_Flick(img_Flick); return }
        // 网络
        if path_Flick.hasPrefix("http://") || path_Flick.hasPrefix("https://") {
            guard let url_Flick = URL(string: path_Flick) else { showEmpty_Flick(); return }
            imageView_Flick.kf.setImage(with: url_Flick, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Flick.stopAnimating()
                if case .success(let v_Flick) = result { self?.onImageLoaded_Flick(v_Flick.image) }
                else { self?.showEmpty_Flick() }
            }
            return
        }
        // Documents 文件名
        let docs_Flick = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Flick = docs_Flick.appendingPathComponent(path_Flick)
        if let img_Flick = UIImage(contentsOfFile: docURL_Flick.path) { applyImage_Flick(img_Flick); return }
        // 完整路径
        if let img_Flick = UIImage(contentsOfFile: path_Flick) { applyImage_Flick(img_Flick); return }
        showEmpty_Flick()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Flick: 视频文件 URL
    private func setupVideoPlayer_Flick(url_Flick: URL) {
        resolvedType_Flick = .video_Flick

        // 切换到视频容器
        scrollView_Flick.isHidden         = true
        videoContainerView_Flick.isHidden = false
        progressBg_Flick.isHidden         = false

        mediaTypeLabel_Flick.text = "Video"

        let player_Flick  = AVPlayer(url: url_Flick)
        self.player_Flick = player_Flick
        let layer_Flick   = AVPlayerLayer(player: player_Flick)
        layer_Flick.videoGravity  = .resizeAspect
        layer_Flick.frame         = videoContainerView_Flick.bounds
        layer_Flick.backgroundColor = UIColor.black.cgColor
        videoContainerView_Flick.layer.insertSublayer(layer_Flick, at: 0)
        playerLayer_Flick = layer_Flick

        // 视频就绪后淡入播放按钮
        player_Flick.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Flick = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Flick = player_Flick.addPeriodicTimeObserver(
            forInterval: interval_Flick,
            queue: .main
        ) { [weak self] time_Flick in
            self?.updateProgress_Flick(currentTime_Flick: time_Flick)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Flick),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Flick.currentItem
        )

        loadingIndicator_Flick.stopAnimating()
        player_Flick.play()
        isPlaying_Flick = true
        playPauseButton_Flick.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Flick.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Flick: AVPlayer 当前时间
    private func updateProgress_Flick(currentTime_Flick: CMTime) {
        guard let duration_Flick = player_Flick?.currentItem?.duration,
              duration_Flick.isNumeric, duration_Flick.seconds > 0 else { return }
        let progress_Flick = CGFloat(currentTime_Flick.seconds / duration_Flick.seconds)
        let totalW_Flick   = progressBg_Flick.bounds.width
        progressWidthCon_Flick?.update(offset: totalW_Flick * min(max(progress_Flick, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Flick() {
        player_Flick?.seek(to: .zero)
        isPlaying_Flick = false
        playPauseButton_Flick.isSelected = false
        progressWidthCon_Flick?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Flick() {
        if let token_Flick = timeObserverToken_Flick {
            player_Flick?.removeTimeObserver(token_Flick)
            timeObserverToken_Flick = nil
        }
        player_Flick?.removeObserver(self, forKeyPath: "status")
        player_Flick?.pause()
        player_Flick = nil
        playerLayer_Flick?.removeFromSuperlayer()
        playerLayer_Flick = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Flick = object as? AVPlayer,
              player_Flick.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Flick() }
    }

    // MARK: - 图片辅助

    private func applyImage_Flick(_ image_Flick: UIImage) {
        loadingIndicator_Flick.stopAnimating()
        imageView_Flick.image = image_Flick
        imageSize_Flick       = image_Flick.size
        mediaTypeLabel_Flick.text = "Photo"
        updateImageLayout_Flick()
    }

    private func onImageLoaded_Flick(_ image_Flick: UIImage) {
        imageSize_Flick = image_Flick.size
        mediaTypeLabel_Flick.text = "Photo"
        updateImageLayout_Flick()
    }

    private func showEmpty_Flick() {
        loadingIndicator_Flick.stopAnimating()
        imageView_Flick.image       = UIImage(systemName: "photo.slash")
        imageView_Flick.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Flick.contentMode = .center
    }

    private func updateImageLayout_Flick() {
        guard imageSize_Flick != .zero else {
            imageView_Flick.frame = view.bounds
            scrollView_Flick.contentSize = view.bounds.size
            return
        }
        let screenW_Flick = view.bounds.width
        let screenH_Flick = view.bounds.height
        let ratio_Flick   = imageSize_Flick.height / imageSize_Flick.width
        let imgH_Flick    = screenW_Flick * ratio_Flick
        let y_Flick       = max(0, (screenH_Flick - imgH_Flick) / 2)
        imageView_Flick.frame        = CGRect(x: 0, y: y_Flick, width: screenW_Flick, height: imgH_Flick)
        scrollView_Flick.contentSize = CGSize(width: screenW_Flick,
                                              height: max(imgH_Flick + y_Flick * 2, screenH_Flick))
        scrollView_Flick.zoomScale   = 1.0
        centerImageIfNeeded_Flick()
    }

    private func centerImageIfNeeded_Flick() {
        let offX_Flick = max(0, (scrollView_Flick.bounds.width  - scrollView_Flick.contentSize.width)  / 2)
        let offY_Flick = max(0, (scrollView_Flick.bounds.height - scrollView_Flick.contentSize.height) / 2)
        imageView_Flick.center = CGPoint(
            x: scrollView_Flick.contentSize.width  / 2 + offX_Flick,
            y: scrollView_Flick.contentSize.height / 2 + offY_Flick
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Flick(_ gesture_Flick: UITapGestureRecognizer) {
        guard resolvedType_Flick == .image_Flick else { return }
        if scrollView_Flick.zoomScale > 1.0 {
            scrollView_Flick.setZoomScale(1.0, animated: true)
        } else {
            let pt_Flick    = gesture_Flick.location(in: imageView_Flick)
            let rect_Flick  = zoomRect_Flick(scale_Flick: 2.5, center_Flick: pt_Flick)
            scrollView_Flick.zoom(to: rect_Flick, animated: true)
        }
    }

    @objc private func handleSingleTap_Flick() {
        guard resolvedType_Flick != .video_Flick,
              scrollView_Flick.zoomScale <= 1.01 else { return }
        dismissPage_Flick(velocity_Flick: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Flick() {
        togglePlayPause_Flick()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Flick() {
        guard let player_Flick = player_Flick else { return }
        if isPlaying_Flick {
            player_Flick.pause()
            isPlaying_Flick = false
            playPauseButton_Flick.isSelected = false
        } else {
            player_Flick.play()
            isPlaying_Flick = true
            playPauseButton_Flick.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Flick.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Flick else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Flick.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Flick() {
        dismissPage_Flick(velocity_Flick: 0)
    }

    @objc private func handlePan_Flick(_ gesture_Flick: UIPanGestureRecognizer) {
        guard scrollView_Flick.zoomScale <= 1.01 else { return }
        let translation_Flick = gesture_Flick.translation(in: view)
        let velocity_Flick    = gesture_Flick.velocity(in: view).y
        switch gesture_Flick.state {
        case .changed:
            let progress_Flick         = max(0, translation_Flick.y / view.bounds.height)
            backgroundView_Flick.alpha = max(0, 1 - progress_Flick * 1.5)
            topBar_Flick.alpha         = max(0, 1 - progress_Flick * 2)
            bottomHint_Flick.alpha     = max(0, 1 - progress_Flick * 2)
            let activeView_Flick: UIView = resolvedType_Flick == .video_Flick
                ? videoContainerView_Flick : scrollView_Flick
            activeView_Flick.transform = CGAffineTransform(
                translationX: translation_Flick.x * 0.3,
                y: max(0, translation_Flick.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Flick = translation_Flick.y > view.bounds.height * 0.25 || velocity_Flick > 900
            if shouldDismiss_Flick {
                dismissPage_Flick(velocity_Flick: velocity_Flick)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Flick.transform         = .identity
                    self.videoContainerView_Flick.transform = .identity
                    self.backgroundView_Flick.alpha  = 1
                    self.topBar_Flick.alpha           = 1
                    self.bottomHint_Flick.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Flick: 下拉速度（影响动画时长）
    private func dismissPage_Flick(velocity_Flick: CGFloat) {
        guard !isDismissing_Flick else { return }
        isDismissing_Flick = true
        player_Flick?.pause()
        let duration_Flick = velocity_Flick > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Flick, animations: {
            self.view.alpha = 0
            let activeView_Flick: UIView = self.resolvedType_Flick == .video_Flick
                ? self.videoContainerView_Flick : self.scrollView_Flick
            activeView_Flick.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Flick(scale_Flick: CGFloat, center_Flick: CGPoint) -> CGRect {
        let w_Flick = scrollView_Flick.bounds.width  / scale_Flick
        let h_Flick = scrollView_Flick.bounds.height / scale_Flick
        return CGRect(x: center_Flick.x - w_Flick / 2,
                      y: center_Flick.y - h_Flick / 2,
                      width: w_Flick, height: h_Flick)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Flick: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Flick }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Flick() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Flick: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Flick = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Flick.zoomScale <= 1.01 else { return false }
        let vel_Flick = pan_Flick.velocity(in: view)
        return abs(vel_Flick.y) > abs(vel_Flick.x) && vel_Flick.y > 0
    }
}
