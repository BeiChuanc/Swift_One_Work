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
///   - 媒体路径与 MediaDisplayView_Retrs 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Retrs:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Retrs:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Retrs: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Retrs: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Retrs: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Retrs: MediaType_Retrs = .none_Retrs

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Retrs = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Retrs: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Retrs: AVPlayer?
    private var playerLayer_Retrs: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Retrs: Any?
    /// 是否处于播放状态
    private var isPlaying_Retrs = false

    // MARK: - UI：黑色背景

    private let backgroundView_Retrs: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Retrs: UIScrollView = {
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

    private let imageView_Retrs: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Retrs: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Retrs: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Retrs = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Retrs), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Retrs), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Retrs: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Retrs: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Retrs: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Retrs: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Retrs: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Retrs: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Retrs = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Retrs), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Retrs: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Retrs: UILabel = {
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
        buildUI_Retrs()
        buildConstraints_Retrs()
        bindGestures_Retrs()
        loadMedia_Retrs()
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
        cleanupPlayer_Retrs()
    }

    deinit {
        cleanupPlayer_Retrs()
    }

    // MARK: - UI 搭建

    private func buildUI_Retrs() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Retrs)

        // 图片容器
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(imageView_Retrs)
        scrollView_Retrs.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Retrs)
        videoContainerView_Retrs.addSubview(playPauseButton_Retrs)
        videoContainerView_Retrs.addSubview(progressBg_Retrs)
        progressBg_Retrs.addSubview(progressFill_Retrs)

        // 通用
        view.addSubview(loadingIndicator_Retrs)
        view.addSubview(topBar_Retrs)
        topBar_Retrs.addSubview(closeButton_Retrs)
        topBar_Retrs.addSubview(mediaTypeLabel_Retrs)
        view.addSubview(bottomHint_Retrs)
    }

    private func buildConstraints_Retrs() {
        backgroundView_Retrs.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Retrs.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Retrs.frame = view.bounds

        videoContainerView_Retrs.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Retrs.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Retrs.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Retrs.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Retrs = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Retrs.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Retrs.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Retrs.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Retrs.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Retrs.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Retrs.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Retrs?.frame = videoContainerView_Retrs.bounds
        updateImageLayout_Retrs()
    }

    // MARK: - 手势

    private func bindGestures_Retrs() {
        // 双击缩放（图片）
        let doubleTap_Retrs = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Retrs(_:)))
        doubleTap_Retrs.numberOfTapsRequired = 2
        scrollView_Retrs.addGestureRecognizer(doubleTap_Retrs)

        // 单击关闭 / 视频播放切换
        let singleTap_Retrs = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Retrs))
        singleTap_Retrs.numberOfTapsRequired = 1
        singleTap_Retrs.require(toFail: doubleTap_Retrs)
        scrollView_Retrs.addGestureRecognizer(singleTap_Retrs)

        // 视频区单击切换播放/暂停
        let videoTap_Retrs = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Retrs))
        videoContainerView_Retrs.addGestureRecognizer(videoTap_Retrs)

        // 下滑关闭
        let pan_Retrs = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Retrs(_:)))
        pan_Retrs.delegate = self
        view.addGestureRecognizer(pan_Retrs)

        // 播放/暂停按钮
        playPauseButton_Retrs.addTarget(self, action: #selector(togglePlayPause_Retrs), for: .touchUpInside)
        closeButton_Retrs.addTarget(self, action: #selector(closeTapped_Retrs), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Retrs 和 isVideo_Retrs 加载媒体
    private func loadMedia_Retrs() {
        guard let path_Retrs = mediaPath_Retrs, !path_Retrs.isEmpty else { showEmpty_Retrs(); return }
        loadingIndicator_Retrs.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Retrs, let url_Retrs = resolveVideoURL_Retrs(path_Retrs) {
            setupVideoPlayer_Retrs(url_Retrs: url_Retrs)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Retrs = resolveVideoURL_Retrs(path_Retrs) {
            setupVideoPlayer_Retrs(url_Retrs: url_Retrs)
            return
        }

        // 图片加载流程
        resolvedType_Retrs = .image_Retrs
        loadImage_Retrs(path_Retrs: path_Retrs)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Retrs: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Retrs(_ path_Retrs: String) -> URL? {
        // Bundle 资源
        if let url_Retrs = MediaDisplayView_Retrs.bundleVideoURL_Retrs(named: path_Retrs) {
            return url_Retrs
        }
        // Documents 目录视频文件
        let docs_Retrs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Retrs in ["mp4", "mov", "m4v"] {
            let url_Retrs = docs_Retrs.appendingPathComponent("\(path_Retrs).\(ext_Retrs)")
            if FileManager.default.fileExists(atPath: url_Retrs.path) { return url_Retrs }
        }
        // 已带扩展名的文档目录文件
        let direct_Retrs = docs_Retrs.appendingPathComponent(path_Retrs)
        if FileManager.default.fileExists(atPath: direct_Retrs.path) { return direct_Retrs }
        // 网络视频 URL
        if (path_Retrs.hasPrefix("http://") || path_Retrs.hasPrefix("https://")),
           let url_Retrs = URL(string: path_Retrs) {
            let ext_Retrs = (path_Retrs as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Retrs) { return url_Retrs }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Retrs 策略对齐）
    /// - Parameter path_Retrs: 媒体路径
    private func loadImage_Retrs(path_Retrs: String) {
        // SF Symbols
        if let img_Retrs = UIImage(systemName: path_Retrs) { applyImage_Retrs(img_Retrs); return }
        // Assets
        if let img_Retrs = UIImage(named: path_Retrs) { applyImage_Retrs(img_Retrs); return }
        // 网络
        if path_Retrs.hasPrefix("http://") || path_Retrs.hasPrefix("https://") {
            guard let url_Retrs = URL(string: path_Retrs) else { showEmpty_Retrs(); return }
            imageView_Retrs.kf.setImage(with: url_Retrs, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Retrs.stopAnimating()
                if case .success(let v_Retrs) = result { self?.onImageLoaded_Retrs(v_Retrs.image) }
                else { self?.showEmpty_Retrs() }
            }
            return
        }
        // Documents 文件名
        let docs_Retrs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Retrs = docs_Retrs.appendingPathComponent(path_Retrs)
        if let img_Retrs = UIImage(contentsOfFile: docURL_Retrs.path) { applyImage_Retrs(img_Retrs); return }
        // 完整路径
        if let img_Retrs = UIImage(contentsOfFile: path_Retrs) { applyImage_Retrs(img_Retrs); return }
        showEmpty_Retrs()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Retrs: 视频文件 URL
    private func setupVideoPlayer_Retrs(url_Retrs: URL) {
        resolvedType_Retrs = .video_Retrs

        // 切换到视频容器
        scrollView_Retrs.isHidden         = true
        videoContainerView_Retrs.isHidden = false
        progressBg_Retrs.isHidden         = false

        mediaTypeLabel_Retrs.text = "Video"

        let player_Retrs  = AVPlayer(url: url_Retrs)
        self.player_Retrs = player_Retrs
        let layer_Retrs   = AVPlayerLayer(player: player_Retrs)
        layer_Retrs.videoGravity  = .resizeAspect
        layer_Retrs.frame         = videoContainerView_Retrs.bounds
        layer_Retrs.backgroundColor = UIColor.black.cgColor
        videoContainerView_Retrs.layer.insertSublayer(layer_Retrs, at: 0)
        playerLayer_Retrs = layer_Retrs

        // 视频就绪后淡入播放按钮
        player_Retrs.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Retrs = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Retrs = player_Retrs.addPeriodicTimeObserver(
            forInterval: interval_Retrs,
            queue: .main
        ) { [weak self] time_Retrs in
            self?.updateProgress_Retrs(currentTime_Retrs: time_Retrs)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Retrs),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Retrs.currentItem
        )

        loadingIndicator_Retrs.stopAnimating()
        player_Retrs.play()
        isPlaying_Retrs = true
        playPauseButton_Retrs.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Retrs.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Retrs: AVPlayer 当前时间
    private func updateProgress_Retrs(currentTime_Retrs: CMTime) {
        guard let duration_Retrs = player_Retrs?.currentItem?.duration,
              duration_Retrs.isNumeric, duration_Retrs.seconds > 0 else { return }
        let progress_Retrs = CGFloat(currentTime_Retrs.seconds / duration_Retrs.seconds)
        let totalW_Retrs   = progressBg_Retrs.bounds.width
        progressWidthCon_Retrs?.update(offset: totalW_Retrs * min(max(progress_Retrs, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Retrs() {
        player_Retrs?.seek(to: .zero)
        isPlaying_Retrs = false
        playPauseButton_Retrs.isSelected = false
        progressWidthCon_Retrs?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Retrs() {
        if let token_Retrs = timeObserverToken_Retrs {
            player_Retrs?.removeTimeObserver(token_Retrs)
            timeObserverToken_Retrs = nil
        }
        player_Retrs?.removeObserver(self, forKeyPath: "status")
        player_Retrs?.pause()
        player_Retrs = nil
        playerLayer_Retrs?.removeFromSuperlayer()
        playerLayer_Retrs = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Retrs = object as? AVPlayer,
              player_Retrs.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Retrs() }
    }

    // MARK: - 图片辅助

    private func applyImage_Retrs(_ image_Retrs: UIImage) {
        loadingIndicator_Retrs.stopAnimating()
        imageView_Retrs.image = image_Retrs
        imageSize_Retrs       = image_Retrs.size
        mediaTypeLabel_Retrs.text = "Photo"
        updateImageLayout_Retrs()
    }

    private func onImageLoaded_Retrs(_ image_Retrs: UIImage) {
        imageSize_Retrs = image_Retrs.size
        mediaTypeLabel_Retrs.text = "Photo"
        updateImageLayout_Retrs()
    }

    private func showEmpty_Retrs() {
        loadingIndicator_Retrs.stopAnimating()
        imageView_Retrs.image       = UIImage(systemName: "photo.slash")
        imageView_Retrs.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Retrs.contentMode = .center
    }

    private func updateImageLayout_Retrs() {
        guard imageSize_Retrs != .zero else {
            imageView_Retrs.frame = view.bounds
            scrollView_Retrs.contentSize = view.bounds.size
            return
        }
        let screenW_Retrs = view.bounds.width
        let screenH_Retrs = view.bounds.height
        let ratio_Retrs   = imageSize_Retrs.height / imageSize_Retrs.width
        let imgH_Retrs    = screenW_Retrs * ratio_Retrs
        let y_Retrs       = max(0, (screenH_Retrs - imgH_Retrs) / 2)
        imageView_Retrs.frame        = CGRect(x: 0, y: y_Retrs, width: screenW_Retrs, height: imgH_Retrs)
        scrollView_Retrs.contentSize = CGSize(width: screenW_Retrs,
                                              height: max(imgH_Retrs + y_Retrs * 2, screenH_Retrs))
        scrollView_Retrs.zoomScale   = 1.0
        centerImageIfNeeded_Retrs()
    }

    private func centerImageIfNeeded_Retrs() {
        let offX_Retrs = max(0, (scrollView_Retrs.bounds.width  - scrollView_Retrs.contentSize.width)  / 2)
        let offY_Retrs = max(0, (scrollView_Retrs.bounds.height - scrollView_Retrs.contentSize.height) / 2)
        imageView_Retrs.center = CGPoint(
            x: scrollView_Retrs.contentSize.width  / 2 + offX_Retrs,
            y: scrollView_Retrs.contentSize.height / 2 + offY_Retrs
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Retrs(_ gesture_Retrs: UITapGestureRecognizer) {
        guard resolvedType_Retrs == .image_Retrs else { return }
        if scrollView_Retrs.zoomScale > 1.0 {
            scrollView_Retrs.setZoomScale(1.0, animated: true)
        } else {
            let pt_Retrs    = gesture_Retrs.location(in: imageView_Retrs)
            let rect_Retrs  = zoomRect_Retrs(scale_Retrs: 2.5, center_Retrs: pt_Retrs)
            scrollView_Retrs.zoom(to: rect_Retrs, animated: true)
        }
    }

    @objc private func handleSingleTap_Retrs() {
        guard resolvedType_Retrs != .video_Retrs,
              scrollView_Retrs.zoomScale <= 1.01 else { return }
        dismissPage_Retrs(velocity_Retrs: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Retrs() {
        togglePlayPause_Retrs()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Retrs() {
        guard let player_Retrs = player_Retrs else { return }
        if isPlaying_Retrs {
            player_Retrs.pause()
            isPlaying_Retrs = false
            playPauseButton_Retrs.isSelected = false
        } else {
            player_Retrs.play()
            isPlaying_Retrs = true
            playPauseButton_Retrs.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Retrs.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Retrs else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Retrs.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Retrs() {
        dismissPage_Retrs(velocity_Retrs: 0)
    }

    @objc private func handlePan_Retrs(_ gesture_Retrs: UIPanGestureRecognizer) {
        guard scrollView_Retrs.zoomScale <= 1.01 else { return }
        let translation_Retrs = gesture_Retrs.translation(in: view)
        let velocity_Retrs    = gesture_Retrs.velocity(in: view).y
        switch gesture_Retrs.state {
        case .changed:
            let progress_Retrs         = max(0, translation_Retrs.y / view.bounds.height)
            backgroundView_Retrs.alpha = max(0, 1 - progress_Retrs * 1.5)
            topBar_Retrs.alpha         = max(0, 1 - progress_Retrs * 2)
            bottomHint_Retrs.alpha     = max(0, 1 - progress_Retrs * 2)
            let activeView_Retrs: UIView = resolvedType_Retrs == .video_Retrs
                ? videoContainerView_Retrs : scrollView_Retrs
            activeView_Retrs.transform = CGAffineTransform(
                translationX: translation_Retrs.x * 0.3,
                y: max(0, translation_Retrs.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Retrs = translation_Retrs.y > view.bounds.height * 0.25 || velocity_Retrs > 900
            if shouldDismiss_Retrs {
                dismissPage_Retrs(velocity_Retrs: velocity_Retrs)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Retrs.transform         = .identity
                    self.videoContainerView_Retrs.transform = .identity
                    self.backgroundView_Retrs.alpha  = 1
                    self.topBar_Retrs.alpha           = 1
                    self.bottomHint_Retrs.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Retrs: 下拉速度（影响动画时长）
    private func dismissPage_Retrs(velocity_Retrs: CGFloat) {
        guard !isDismissing_Retrs else { return }
        isDismissing_Retrs = true
        player_Retrs?.pause()
        let duration_Retrs = velocity_Retrs > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Retrs, animations: {
            self.view.alpha = 0
            let activeView_Retrs: UIView = self.resolvedType_Retrs == .video_Retrs
                ? self.videoContainerView_Retrs : self.scrollView_Retrs
            activeView_Retrs.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Retrs(scale_Retrs: CGFloat, center_Retrs: CGPoint) -> CGRect {
        let w_Retrs = scrollView_Retrs.bounds.width  / scale_Retrs
        let h_Retrs = scrollView_Retrs.bounds.height / scale_Retrs
        return CGRect(x: center_Retrs.x - w_Retrs / 2,
                      y: center_Retrs.y - h_Retrs / 2,
                      width: w_Retrs, height: h_Retrs)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Retrs: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Retrs }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Retrs() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Retrs: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Retrs = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Retrs.zoomScale <= 1.01 else { return false }
        let vel_Retrs = pan_Retrs.velocity(in: view)
        return abs(vel_Retrs.y) > abs(vel_Retrs.x) && vel_Retrs.y > 0
    }
}
