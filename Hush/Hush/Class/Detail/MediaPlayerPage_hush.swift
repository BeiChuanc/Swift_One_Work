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
///   - 媒体路径与 MediaDisplayView_Hush 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Hush:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Hush:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Hush: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Hush: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Hush: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Hush: MediaType_Hush = .none_Hush

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Hush = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Hush: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Hush: AVPlayer?
    private var playerLayer_Hush: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Hush: Any?
    /// 是否处于播放状态
    private var isPlaying_Hush = false

    // MARK: - UI：黑色背景

    private let backgroundView_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Hush: UIScrollView = {
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

    private let imageView_Hush: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Hush: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Hush = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Hush), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Hush), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Hush: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Hush: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Hush: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Hush: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Hush: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Hush = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Hush), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Hush: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Hush: UILabel = {
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
        buildUI_Hush()
        buildConstraints_Hush()
        bindGestures_Hush()
        loadMedia_Hush()
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
        cleanupPlayer_Hush()
    }

    deinit {
        cleanupPlayer_Hush()
    }

    // MARK: - UI 搭建

    private func buildUI_Hush() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Hush)

        // 图片容器
        view.addSubview(scrollView_Hush)
        scrollView_Hush.addSubview(imageView_Hush)
        scrollView_Hush.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Hush)
        videoContainerView_Hush.addSubview(playPauseButton_Hush)
        videoContainerView_Hush.addSubview(progressBg_Hush)
        progressBg_Hush.addSubview(progressFill_Hush)

        // 通用
        view.addSubview(loadingIndicator_Hush)
        view.addSubview(topBar_Hush)
        topBar_Hush.addSubview(closeButton_Hush)
        topBar_Hush.addSubview(mediaTypeLabel_Hush)
        view.addSubview(bottomHint_Hush)
    }

    private func buildConstraints_Hush() {
        backgroundView_Hush.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Hush.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Hush.frame = view.bounds

        videoContainerView_Hush.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Hush.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Hush.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Hush.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Hush = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Hush.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Hush.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Hush.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Hush.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Hush.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Hush.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Hush?.frame = videoContainerView_Hush.bounds
        updateImageLayout_Hush()
    }

    // MARK: - 手势

    private func bindGestures_Hush() {
        // 双击缩放（图片）
        let doubleTap_Hush = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Hush(_:)))
        doubleTap_Hush.numberOfTapsRequired = 2
        scrollView_Hush.addGestureRecognizer(doubleTap_Hush)

        // 单击关闭 / 视频播放切换
        let singleTap_Hush = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Hush))
        singleTap_Hush.numberOfTapsRequired = 1
        singleTap_Hush.require(toFail: doubleTap_Hush)
        scrollView_Hush.addGestureRecognizer(singleTap_Hush)

        // 视频区单击切换播放/暂停
        let videoTap_Hush = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Hush))
        videoContainerView_Hush.addGestureRecognizer(videoTap_Hush)

        // 下滑关闭
        let pan_Hush = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Hush(_:)))
        pan_Hush.delegate = self
        view.addGestureRecognizer(pan_Hush)

        // 播放/暂停按钮
        playPauseButton_Hush.addTarget(self, action: #selector(togglePlayPause_Hush), for: .touchUpInside)
        closeButton_Hush.addTarget(self, action: #selector(closeTapped_Hush), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Hush 和 isVideo_Hush 加载媒体
    private func loadMedia_Hush() {
        guard let path_Hush = mediaPath_Hush, !path_Hush.isEmpty else { showEmpty_Hush(); return }
        loadingIndicator_Hush.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Hush, let url_Hush = resolveVideoURL_Hush(path_Hush) {
            setupVideoPlayer_Hush(url_Hush: url_Hush)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Hush = resolveVideoURL_Hush(path_Hush) {
            setupVideoPlayer_Hush(url_Hush: url_Hush)
            return
        }

        // 图片加载流程
        resolvedType_Hush = .image_Hush
        loadImage_Hush(path_Hush: path_Hush)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Hush: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Hush(_ path_Hush: String) -> URL? {
        // Bundle 资源
        if let url_Hush = MediaDisplayView_Hush.bundleVideoURL_Hush(named: path_Hush) {
            return url_Hush
        }
        // Documents 目录视频文件
        let docs_Hush = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Hush in ["mp4", "mov", "m4v"] {
            let url_Hush = docs_Hush.appendingPathComponent("\(path_Hush).\(ext_Hush)")
            if FileManager.default.fileExists(atPath: url_Hush.path) { return url_Hush }
        }
        // 已带扩展名的文档目录文件
        let direct_Hush = docs_Hush.appendingPathComponent(path_Hush)
        if FileManager.default.fileExists(atPath: direct_Hush.path) { return direct_Hush }
        // 网络视频 URL
        if (path_Hush.hasPrefix("http://") || path_Hush.hasPrefix("https://")),
           let url_Hush = URL(string: path_Hush) {
            let ext_Hush = (path_Hush as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Hush) { return url_Hush }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Hush 策略对齐）
    /// - Parameter path_Hush: 媒体路径
    private func loadImage_Hush(path_Hush: String) {
        // SF Symbols
        if let img_Hush = UIImage(systemName: path_Hush) { applyImage_Hush(img_Hush); return }
        // Assets
        if let img_Hush = UIImage(named: path_Hush) { applyImage_Hush(img_Hush); return }
        // 网络
        if path_Hush.hasPrefix("http://") || path_Hush.hasPrefix("https://") {
            guard let url_Hush = URL(string: path_Hush) else { showEmpty_Hush(); return }
            imageView_Hush.kf.setImage(with: url_Hush, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Hush.stopAnimating()
                if case .success(let v_Hush) = result { self?.onImageLoaded_Hush(v_Hush.image) }
                else { self?.showEmpty_Hush() }
            }
            return
        }
        // Documents 文件名
        let docs_Hush = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Hush = docs_Hush.appendingPathComponent(path_Hush)
        if let img_Hush = UIImage(contentsOfFile: docURL_Hush.path) { applyImage_Hush(img_Hush); return }
        // 完整路径
        if let img_Hush = UIImage(contentsOfFile: path_Hush) { applyImage_Hush(img_Hush); return }
        showEmpty_Hush()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Hush: 视频文件 URL
    private func setupVideoPlayer_Hush(url_Hush: URL) {
        resolvedType_Hush = .video_Hush

        // 切换到视频容器
        scrollView_Hush.isHidden         = true
        videoContainerView_Hush.isHidden = false
        progressBg_Hush.isHidden         = false

        mediaTypeLabel_Hush.text = "Video"

        let player_Hush  = AVPlayer(url: url_Hush)
        self.player_Hush = player_Hush
        let layer_Hush   = AVPlayerLayer(player: player_Hush)
        layer_Hush.videoGravity  = .resizeAspect
        layer_Hush.frame         = videoContainerView_Hush.bounds
        layer_Hush.backgroundColor = UIColor.black.cgColor
        videoContainerView_Hush.layer.insertSublayer(layer_Hush, at: 0)
        playerLayer_Hush = layer_Hush

        // 视频就绪后淡入播放按钮
        player_Hush.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Hush = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Hush = player_Hush.addPeriodicTimeObserver(
            forInterval: interval_Hush,
            queue: .main
        ) { [weak self] time_Hush in
            self?.updateProgress_Hush(currentTime_Hush: time_Hush)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Hush),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Hush.currentItem
        )

        loadingIndicator_Hush.stopAnimating()
        player_Hush.play()
        isPlaying_Hush = true
        playPauseButton_Hush.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Hush.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Hush: AVPlayer 当前时间
    private func updateProgress_Hush(currentTime_Hush: CMTime) {
        guard let duration_Hush = player_Hush?.currentItem?.duration,
              duration_Hush.isNumeric, duration_Hush.seconds > 0 else { return }
        let progress_Hush = CGFloat(currentTime_Hush.seconds / duration_Hush.seconds)
        let totalW_Hush   = progressBg_Hush.bounds.width
        progressWidthCon_Hush?.update(offset: totalW_Hush * min(max(progress_Hush, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Hush() {
        player_Hush?.seek(to: .zero)
        isPlaying_Hush = false
        playPauseButton_Hush.isSelected = false
        progressWidthCon_Hush?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Hush() {
        if let token_Hush = timeObserverToken_Hush {
            player_Hush?.removeTimeObserver(token_Hush)
            timeObserverToken_Hush = nil
        }
        player_Hush?.removeObserver(self, forKeyPath: "status")
        player_Hush?.pause()
        player_Hush = nil
        playerLayer_Hush?.removeFromSuperlayer()
        playerLayer_Hush = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Hush = object as? AVPlayer,
              player_Hush.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Hush() }
    }

    // MARK: - 图片辅助

    private func applyImage_Hush(_ image_Hush: UIImage) {
        loadingIndicator_Hush.stopAnimating()
        imageView_Hush.image = image_Hush
        imageSize_Hush       = image_Hush.size
        mediaTypeLabel_Hush.text = "Photo"
        updateImageLayout_Hush()
    }

    private func onImageLoaded_Hush(_ image_Hush: UIImage) {
        imageSize_Hush = image_Hush.size
        mediaTypeLabel_Hush.text = "Photo"
        updateImageLayout_Hush()
    }

    private func showEmpty_Hush() {
        loadingIndicator_Hush.stopAnimating()
        imageView_Hush.image       = UIImage(systemName: "photo.slash")
        imageView_Hush.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Hush.contentMode = .center
    }

    private func updateImageLayout_Hush() {
        guard imageSize_Hush != .zero else {
            imageView_Hush.frame = view.bounds
            scrollView_Hush.contentSize = view.bounds.size
            return
        }
        let screenW_Hush = view.bounds.width
        let screenH_Hush = view.bounds.height
        let ratio_Hush   = imageSize_Hush.height / imageSize_Hush.width
        let imgH_Hush    = screenW_Hush * ratio_Hush
        let y_Hush       = max(0, (screenH_Hush - imgH_Hush) / 2)
        imageView_Hush.frame        = CGRect(x: 0, y: y_Hush, width: screenW_Hush, height: imgH_Hush)
        scrollView_Hush.contentSize = CGSize(width: screenW_Hush,
                                              height: max(imgH_Hush + y_Hush * 2, screenH_Hush))
        scrollView_Hush.zoomScale   = 1.0
        centerImageIfNeeded_Hush()
    }

    private func centerImageIfNeeded_Hush() {
        let offX_Hush = max(0, (scrollView_Hush.bounds.width  - scrollView_Hush.contentSize.width)  / 2)
        let offY_Hush = max(0, (scrollView_Hush.bounds.height - scrollView_Hush.contentSize.height) / 2)
        imageView_Hush.center = CGPoint(
            x: scrollView_Hush.contentSize.width  / 2 + offX_Hush,
            y: scrollView_Hush.contentSize.height / 2 + offY_Hush
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Hush(_ gesture_Hush: UITapGestureRecognizer) {
        guard resolvedType_Hush == .image_Hush else { return }
        if scrollView_Hush.zoomScale > 1.0 {
            scrollView_Hush.setZoomScale(1.0, animated: true)
        } else {
            let pt_Hush    = gesture_Hush.location(in: imageView_Hush)
            let rect_Hush  = zoomRect_Hush(scale_Hush: 2.5, center_Hush: pt_Hush)
            scrollView_Hush.zoom(to: rect_Hush, animated: true)
        }
    }

    @objc private func handleSingleTap_Hush() {
        guard resolvedType_Hush != .video_Hush,
              scrollView_Hush.zoomScale <= 1.01 else { return }
        dismissPage_Hush(velocity_Hush: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Hush() {
        togglePlayPause_Hush()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Hush() {
        guard let player_Hush = player_Hush else { return }
        if isPlaying_Hush {
            player_Hush.pause()
            isPlaying_Hush = false
            playPauseButton_Hush.isSelected = false
        } else {
            player_Hush.play()
            isPlaying_Hush = true
            playPauseButton_Hush.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Hush.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Hush else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Hush.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Hush() {
        dismissPage_Hush(velocity_Hush: 0)
    }

    @objc private func handlePan_Hush(_ gesture_Hush: UIPanGestureRecognizer) {
        guard scrollView_Hush.zoomScale <= 1.01 else { return }
        let translation_Hush = gesture_Hush.translation(in: view)
        let velocity_Hush    = gesture_Hush.velocity(in: view).y
        switch gesture_Hush.state {
        case .changed:
            let progress_Hush         = max(0, translation_Hush.y / view.bounds.height)
            backgroundView_Hush.alpha = max(0, 1 - progress_Hush * 1.5)
            topBar_Hush.alpha         = max(0, 1 - progress_Hush * 2)
            bottomHint_Hush.alpha     = max(0, 1 - progress_Hush * 2)
            let activeView_Hush: UIView = resolvedType_Hush == .video_Hush
                ? videoContainerView_Hush : scrollView_Hush
            activeView_Hush.transform = CGAffineTransform(
                translationX: translation_Hush.x * 0.3,
                y: max(0, translation_Hush.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Hush = translation_Hush.y > view.bounds.height * 0.25 || velocity_Hush > 900
            if shouldDismiss_Hush {
                dismissPage_Hush(velocity_Hush: velocity_Hush)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Hush.transform         = .identity
                    self.videoContainerView_Hush.transform = .identity
                    self.backgroundView_Hush.alpha  = 1
                    self.topBar_Hush.alpha           = 1
                    self.bottomHint_Hush.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Hush: 下拉速度（影响动画时长）
    private func dismissPage_Hush(velocity_Hush: CGFloat) {
        guard !isDismissing_Hush else { return }
        isDismissing_Hush = true
        player_Hush?.pause()
        let duration_Hush = velocity_Hush > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Hush, animations: {
            self.view.alpha = 0
            let activeView_Hush: UIView = self.resolvedType_Hush == .video_Hush
                ? self.videoContainerView_Hush : self.scrollView_Hush
            activeView_Hush.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Hush(scale_Hush: CGFloat, center_Hush: CGPoint) -> CGRect {
        let w_Hush = scrollView_Hush.bounds.width  / scale_Hush
        let h_Hush = scrollView_Hush.bounds.height / scale_Hush
        return CGRect(x: center_Hush.x - w_Hush / 2,
                      y: center_Hush.y - h_Hush / 2,
                      width: w_Hush, height: h_Hush)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Hush: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Hush }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Hush() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Hush: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Hush = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Hush.zoomScale <= 1.01 else { return false }
        let vel_Hush = pan_Hush.velocity(in: view)
        return abs(vel_Hush.y) > abs(vel_Hush.x) && vel_Hush.y > 0
    }
}
