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
///   - 媒体路径与 MediaDisplayView_Sprig 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Sprig:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Sprig:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Sprig: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Sprig: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Sprig: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Sprig: MediaType_Sprig = .none_Sprig

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Sprig = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Sprig: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Sprig: AVPlayer?
    private var playerLayer_Sprig: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Sprig: Any?
    /// 是否处于播放状态
    private var isPlaying_Sprig = false

    // MARK: - UI：黑色背景

    private let backgroundView_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Sprig: UIScrollView = {
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

    private let imageView_Sprig: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Sprig: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Sprig = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Sprig), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Sprig), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Sprig: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Sprig: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Sprig: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Sprig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Sprig), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Sprig: UILabel = {
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
        buildUI_Sprig()
        buildConstraints_Sprig()
        bindGestures_Sprig()
        loadMedia_Sprig()
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
        cleanupPlayer_Sprig()
    }

    deinit {
        cleanupPlayer_Sprig()
    }

    // MARK: - UI 搭建

    private func buildUI_Sprig() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Sprig)

        // 图片容器
        view.addSubview(scrollView_Sprig)
        scrollView_Sprig.addSubview(imageView_Sprig)
        scrollView_Sprig.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Sprig)
        videoContainerView_Sprig.addSubview(playPauseButton_Sprig)
        videoContainerView_Sprig.addSubview(progressBg_Sprig)
        progressBg_Sprig.addSubview(progressFill_Sprig)

        // 通用
        view.addSubview(loadingIndicator_Sprig)
        view.addSubview(topBar_Sprig)
        topBar_Sprig.addSubview(closeButton_Sprig)
        topBar_Sprig.addSubview(mediaTypeLabel_Sprig)
        view.addSubview(bottomHint_Sprig)
    }

    private func buildConstraints_Sprig() {
        backgroundView_Sprig.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Sprig.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Sprig.frame = view.bounds

        videoContainerView_Sprig.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Sprig.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Sprig.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Sprig.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Sprig = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Sprig.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Sprig.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Sprig.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Sprig.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Sprig.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Sprig.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Sprig?.frame = videoContainerView_Sprig.bounds
        updateImageLayout_Sprig()
    }

    // MARK: - 手势

    private func bindGestures_Sprig() {
        // 双击缩放（图片）
        let doubleTap_Sprig = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Sprig(_:)))
        doubleTap_Sprig.numberOfTapsRequired = 2
        scrollView_Sprig.addGestureRecognizer(doubleTap_Sprig)

        // 单击关闭 / 视频播放切换
        let singleTap_Sprig = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Sprig))
        singleTap_Sprig.numberOfTapsRequired = 1
        singleTap_Sprig.require(toFail: doubleTap_Sprig)
        scrollView_Sprig.addGestureRecognizer(singleTap_Sprig)

        // 视频区单击切换播放/暂停
        let videoTap_Sprig = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Sprig))
        videoContainerView_Sprig.addGestureRecognizer(videoTap_Sprig)

        // 下滑关闭
        let pan_Sprig = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Sprig(_:)))
        pan_Sprig.delegate = self
        view.addGestureRecognizer(pan_Sprig)

        // 播放/暂停按钮
        playPauseButton_Sprig.addTarget(self, action: #selector(togglePlayPause_Sprig), for: .touchUpInside)
        closeButton_Sprig.addTarget(self, action: #selector(closeTapped_Sprig), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Sprig 和 isVideo_Sprig 加载媒体
    private func loadMedia_Sprig() {
        guard let path_Sprig = mediaPath_Sprig, !path_Sprig.isEmpty else { showEmpty_Sprig(); return }
        loadingIndicator_Sprig.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Sprig, let url_Sprig = resolveVideoURL_Sprig(path_Sprig) {
            setupVideoPlayer_Sprig(url_Sprig: url_Sprig)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Sprig = resolveVideoURL_Sprig(path_Sprig) {
            setupVideoPlayer_Sprig(url_Sprig: url_Sprig)
            return
        }

        // 图片加载流程
        resolvedType_Sprig = .image_Sprig
        loadImage_Sprig(path_Sprig: path_Sprig)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Sprig: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Sprig(_ path_Sprig: String) -> URL? {
        // Bundle 资源
        if let url_Sprig = MediaDisplayView_Sprig.bundleVideoURL_Sprig(named: path_Sprig) {
            return url_Sprig
        }
        // Documents 目录视频文件
        let docs_Sprig = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Sprig in ["mp4", "mov", "m4v"] {
            let url_Sprig = docs_Sprig.appendingPathComponent("\(path_Sprig).\(ext_Sprig)")
            if FileManager.default.fileExists(atPath: url_Sprig.path) { return url_Sprig }
        }
        // 已带扩展名的文档目录文件
        let direct_Sprig = docs_Sprig.appendingPathComponent(path_Sprig)
        if FileManager.default.fileExists(atPath: direct_Sprig.path) { return direct_Sprig }
        // 网络视频 URL
        if (path_Sprig.hasPrefix("http://") || path_Sprig.hasPrefix("https://")),
           let url_Sprig = URL(string: path_Sprig) {
            let ext_Sprig = (path_Sprig as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Sprig) { return url_Sprig }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Sprig 策略对齐）
    /// - Parameter path_Sprig: 媒体路径
    private func loadImage_Sprig(path_Sprig: String) {
        // SF Symbols
        if let img_Sprig = UIImage(systemName: path_Sprig) { applyImage_Sprig(img_Sprig); return }
        // Assets
        if let img_Sprig = UIImage(named: path_Sprig) { applyImage_Sprig(img_Sprig); return }
        // 网络
        if path_Sprig.hasPrefix("http://") || path_Sprig.hasPrefix("https://") {
            guard let url_Sprig = URL(string: path_Sprig) else { showEmpty_Sprig(); return }
            imageView_Sprig.kf.setImage(with: url_Sprig, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Sprig.stopAnimating()
                if case .success(let v_Sprig) = result { self?.onImageLoaded_Sprig(v_Sprig.image) }
                else { self?.showEmpty_Sprig() }
            }
            return
        }
        // Documents 文件名
        let docs_Sprig = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Sprig = docs_Sprig.appendingPathComponent(path_Sprig)
        if let img_Sprig = UIImage(contentsOfFile: docURL_Sprig.path) { applyImage_Sprig(img_Sprig); return }
        // 完整路径
        if let img_Sprig = UIImage(contentsOfFile: path_Sprig) { applyImage_Sprig(img_Sprig); return }
        showEmpty_Sprig()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Sprig: 视频文件 URL
    private func setupVideoPlayer_Sprig(url_Sprig: URL) {
        resolvedType_Sprig = .video_Sprig

        // 切换到视频容器
        scrollView_Sprig.isHidden         = true
        videoContainerView_Sprig.isHidden = false
        progressBg_Sprig.isHidden         = false

        mediaTypeLabel_Sprig.text = "Video"

        let player_Sprig  = AVPlayer(url: url_Sprig)
        self.player_Sprig = player_Sprig
        let layer_Sprig   = AVPlayerLayer(player: player_Sprig)
        layer_Sprig.videoGravity  = .resizeAspect
        layer_Sprig.frame         = videoContainerView_Sprig.bounds
        layer_Sprig.backgroundColor = UIColor.black.cgColor
        videoContainerView_Sprig.layer.insertSublayer(layer_Sprig, at: 0)
        playerLayer_Sprig = layer_Sprig

        // 视频就绪后淡入播放按钮
        player_Sprig.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Sprig = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Sprig = player_Sprig.addPeriodicTimeObserver(
            forInterval: interval_Sprig,
            queue: .main
        ) { [weak self] time_Sprig in
            self?.updateProgress_Sprig(currentTime_Sprig: time_Sprig)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Sprig),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Sprig.currentItem
        )

        loadingIndicator_Sprig.stopAnimating()
        player_Sprig.play()
        isPlaying_Sprig = true
        playPauseButton_Sprig.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Sprig.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Sprig: AVPlayer 当前时间
    private func updateProgress_Sprig(currentTime_Sprig: CMTime) {
        guard let duration_Sprig = player_Sprig?.currentItem?.duration,
              duration_Sprig.isNumeric, duration_Sprig.seconds > 0 else { return }
        let progress_Sprig = CGFloat(currentTime_Sprig.seconds / duration_Sprig.seconds)
        let totalW_Sprig   = progressBg_Sprig.bounds.width
        progressWidthCon_Sprig?.update(offset: totalW_Sprig * min(max(progress_Sprig, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Sprig() {
        player_Sprig?.seek(to: .zero)
        isPlaying_Sprig = false
        playPauseButton_Sprig.isSelected = false
        progressWidthCon_Sprig?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Sprig() {
        if let token_Sprig = timeObserverToken_Sprig {
            player_Sprig?.removeTimeObserver(token_Sprig)
            timeObserverToken_Sprig = nil
        }
        player_Sprig?.removeObserver(self, forKeyPath: "status")
        player_Sprig?.pause()
        player_Sprig = nil
        playerLayer_Sprig?.removeFromSuperlayer()
        playerLayer_Sprig = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Sprig = object as? AVPlayer,
              player_Sprig.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Sprig() }
    }

    // MARK: - 图片辅助

    private func applyImage_Sprig(_ image_Sprig: UIImage) {
        loadingIndicator_Sprig.stopAnimating()
        imageView_Sprig.image = image_Sprig
        imageSize_Sprig       = image_Sprig.size
        mediaTypeLabel_Sprig.text = "Photo"
        updateImageLayout_Sprig()
    }

    private func onImageLoaded_Sprig(_ image_Sprig: UIImage) {
        imageSize_Sprig = image_Sprig.size
        mediaTypeLabel_Sprig.text = "Photo"
        updateImageLayout_Sprig()
    }

    private func showEmpty_Sprig() {
        loadingIndicator_Sprig.stopAnimating()
        imageView_Sprig.image       = UIImage(systemName: "photo.slash")
        imageView_Sprig.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Sprig.contentMode = .center
    }

    private func updateImageLayout_Sprig() {
        guard imageSize_Sprig != .zero else {
            imageView_Sprig.frame = view.bounds
            scrollView_Sprig.contentSize = view.bounds.size
            return
        }
        let screenW_Sprig = view.bounds.width
        let screenH_Sprig = view.bounds.height
        let ratio_Sprig   = imageSize_Sprig.height / imageSize_Sprig.width
        let imgH_Sprig    = screenW_Sprig * ratio_Sprig
        let y_Sprig       = max(0, (screenH_Sprig - imgH_Sprig) / 2)
        imageView_Sprig.frame        = CGRect(x: 0, y: y_Sprig, width: screenW_Sprig, height: imgH_Sprig)
        scrollView_Sprig.contentSize = CGSize(width: screenW_Sprig,
                                              height: max(imgH_Sprig + y_Sprig * 2, screenH_Sprig))
        scrollView_Sprig.zoomScale   = 1.0
        centerImageIfNeeded_Sprig()
    }

    private func centerImageIfNeeded_Sprig() {
        let offX_Sprig = max(0, (scrollView_Sprig.bounds.width  - scrollView_Sprig.contentSize.width)  / 2)
        let offY_Sprig = max(0, (scrollView_Sprig.bounds.height - scrollView_Sprig.contentSize.height) / 2)
        imageView_Sprig.center = CGPoint(
            x: scrollView_Sprig.contentSize.width  / 2 + offX_Sprig,
            y: scrollView_Sprig.contentSize.height / 2 + offY_Sprig
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Sprig(_ gesture_Sprig: UITapGestureRecognizer) {
        guard resolvedType_Sprig == .image_Sprig else { return }
        if scrollView_Sprig.zoomScale > 1.0 {
            scrollView_Sprig.setZoomScale(1.0, animated: true)
        } else {
            let pt_Sprig    = gesture_Sprig.location(in: imageView_Sprig)
            let rect_Sprig  = zoomRect_Sprig(scale_Sprig: 2.5, center_Sprig: pt_Sprig)
            scrollView_Sprig.zoom(to: rect_Sprig, animated: true)
        }
    }

    @objc private func handleSingleTap_Sprig() {
        guard resolvedType_Sprig != .video_Sprig,
              scrollView_Sprig.zoomScale <= 1.01 else { return }
        dismissPage_Sprig(velocity_Sprig: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Sprig() {
        togglePlayPause_Sprig()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Sprig() {
        guard let player_Sprig = player_Sprig else { return }
        if isPlaying_Sprig {
            player_Sprig.pause()
            isPlaying_Sprig = false
            playPauseButton_Sprig.isSelected = false
        } else {
            player_Sprig.play()
            isPlaying_Sprig = true
            playPauseButton_Sprig.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Sprig.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Sprig else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Sprig.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Sprig() {
        dismissPage_Sprig(velocity_Sprig: 0)
    }

    @objc private func handlePan_Sprig(_ gesture_Sprig: UIPanGestureRecognizer) {
        guard scrollView_Sprig.zoomScale <= 1.01 else { return }
        let translation_Sprig = gesture_Sprig.translation(in: view)
        let velocity_Sprig    = gesture_Sprig.velocity(in: view).y
        switch gesture_Sprig.state {
        case .changed:
            let progress_Sprig         = max(0, translation_Sprig.y / view.bounds.height)
            backgroundView_Sprig.alpha = max(0, 1 - progress_Sprig * 1.5)
            topBar_Sprig.alpha         = max(0, 1 - progress_Sprig * 2)
            bottomHint_Sprig.alpha     = max(0, 1 - progress_Sprig * 2)
            let activeView_Sprig: UIView = resolvedType_Sprig == .video_Sprig
                ? videoContainerView_Sprig : scrollView_Sprig
            activeView_Sprig.transform = CGAffineTransform(
                translationX: translation_Sprig.x * 0.3,
                y: max(0, translation_Sprig.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Sprig = translation_Sprig.y > view.bounds.height * 0.25 || velocity_Sprig > 900
            if shouldDismiss_Sprig {
                dismissPage_Sprig(velocity_Sprig: velocity_Sprig)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Sprig.transform         = .identity
                    self.videoContainerView_Sprig.transform = .identity
                    self.backgroundView_Sprig.alpha  = 1
                    self.topBar_Sprig.alpha           = 1
                    self.bottomHint_Sprig.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Sprig: 下拉速度（影响动画时长）
    private func dismissPage_Sprig(velocity_Sprig: CGFloat) {
        guard !isDismissing_Sprig else { return }
        isDismissing_Sprig = true
        player_Sprig?.pause()
        let duration_Sprig = velocity_Sprig > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Sprig, animations: {
            self.view.alpha = 0
            let activeView_Sprig: UIView = self.resolvedType_Sprig == .video_Sprig
                ? self.videoContainerView_Sprig : self.scrollView_Sprig
            activeView_Sprig.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Sprig(scale_Sprig: CGFloat, center_Sprig: CGPoint) -> CGRect {
        let w_Sprig = scrollView_Sprig.bounds.width  / scale_Sprig
        let h_Sprig = scrollView_Sprig.bounds.height / scale_Sprig
        return CGRect(x: center_Sprig.x - w_Sprig / 2,
                      y: center_Sprig.y - h_Sprig / 2,
                      width: w_Sprig, height: h_Sprig)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Sprig: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Sprig }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Sprig() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Sprig: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Sprig = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Sprig.zoomScale <= 1.01 else { return false }
        let vel_Sprig = pan_Sprig.velocity(in: view)
        return abs(vel_Sprig.y) > abs(vel_Sprig.x) && vel_Sprig.y > 0
    }
}
