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
///   - 媒体路径与 MediaDisplayView_Somnia 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Somnia:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Somnia:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Somnia: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Somnia: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Somnia: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Somnia: MediaType_Somnia = .none_Somnia

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Somnia = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Somnia: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Somnia: AVPlayer?
    private var playerLayer_Somnia: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Somnia: Any?
    /// 是否处于播放状态
    private var isPlaying_Somnia = false

    // MARK: - UI：黑色背景

    private let backgroundView_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Somnia: UIScrollView = {
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

    private let imageView_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Somnia: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Somnia = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Somnia), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Somnia), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Somnia: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Somnia: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Somnia: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Somnia = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Somnia), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Somnia: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Somnia: UILabel = {
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
        buildUI_Somnia()
        buildConstraints_Somnia()
        bindGestures_Somnia()
        loadMedia_Somnia()
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
        cleanupPlayer_Somnia()
    }

    deinit {
        cleanupPlayer_Somnia()
    }

    // MARK: - UI 搭建

    private func buildUI_Somnia() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Somnia)

        // 图片容器
        view.addSubview(scrollView_Somnia)
        scrollView_Somnia.addSubview(imageView_Somnia)
        scrollView_Somnia.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Somnia)
        videoContainerView_Somnia.addSubview(playPauseButton_Somnia)
        videoContainerView_Somnia.addSubview(progressBg_Somnia)
        progressBg_Somnia.addSubview(progressFill_Somnia)

        // 通用
        view.addSubview(loadingIndicator_Somnia)
        view.addSubview(topBar_Somnia)
        topBar_Somnia.addSubview(closeButton_Somnia)
        topBar_Somnia.addSubview(mediaTypeLabel_Somnia)
        view.addSubview(bottomHint_Somnia)
    }

    private func buildConstraints_Somnia() {
        backgroundView_Somnia.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Somnia.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Somnia.frame = view.bounds

        videoContainerView_Somnia.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Somnia.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Somnia.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Somnia.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Somnia = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Somnia.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Somnia.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Somnia.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Somnia.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Somnia.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Somnia.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Somnia?.frame = videoContainerView_Somnia.bounds
        updateImageLayout_Somnia()
    }

    // MARK: - 手势

    private func bindGestures_Somnia() {
        // 双击缩放（图片）
        let doubleTap_Somnia = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Somnia(_:)))
        doubleTap_Somnia.numberOfTapsRequired = 2
        scrollView_Somnia.addGestureRecognizer(doubleTap_Somnia)

        // 单击关闭 / 视频播放切换
        let singleTap_Somnia = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Somnia))
        singleTap_Somnia.numberOfTapsRequired = 1
        singleTap_Somnia.require(toFail: doubleTap_Somnia)
        scrollView_Somnia.addGestureRecognizer(singleTap_Somnia)

        // 视频区单击切换播放/暂停
        let videoTap_Somnia = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Somnia))
        videoContainerView_Somnia.addGestureRecognizer(videoTap_Somnia)

        // 下滑关闭
        let pan_Somnia = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Somnia(_:)))
        pan_Somnia.delegate = self
        view.addGestureRecognizer(pan_Somnia)

        // 播放/暂停按钮
        playPauseButton_Somnia.addTarget(self, action: #selector(togglePlayPause_Somnia), for: .touchUpInside)
        closeButton_Somnia.addTarget(self, action: #selector(closeTapped_Somnia), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Somnia 和 isVideo_Somnia 加载媒体
    private func loadMedia_Somnia() {
        guard let path_Somnia = mediaPath_Somnia, !path_Somnia.isEmpty else { showEmpty_Somnia(); return }
        loadingIndicator_Somnia.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Somnia, let url_Somnia = resolveVideoURL_Somnia(path_Somnia) {
            setupVideoPlayer_Somnia(url_Somnia: url_Somnia)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Somnia = resolveVideoURL_Somnia(path_Somnia) {
            setupVideoPlayer_Somnia(url_Somnia: url_Somnia)
            return
        }

        // 图片加载流程
        resolvedType_Somnia = .image_Somnia
        loadImage_Somnia(path_Somnia: path_Somnia)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Somnia: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Somnia(_ path_Somnia: String) -> URL? {
        // Bundle 资源
        if let url_Somnia = MediaDisplayView_Somnia.bundleVideoURL_Somnia(named: path_Somnia) {
            return url_Somnia
        }
        // Documents 目录视频文件
        let docs_Somnia = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Somnia in ["mp4", "mov", "m4v"] {
            let url_Somnia = docs_Somnia.appendingPathComponent("\(path_Somnia).\(ext_Somnia)")
            if FileManager.default.fileExists(atPath: url_Somnia.path) { return url_Somnia }
        }
        // 已带扩展名的文档目录文件
        let direct_Somnia = docs_Somnia.appendingPathComponent(path_Somnia)
        if FileManager.default.fileExists(atPath: direct_Somnia.path) { return direct_Somnia }
        // 网络视频 URL
        if (path_Somnia.hasPrefix("http://") || path_Somnia.hasPrefix("https://")),
           let url_Somnia = URL(string: path_Somnia) {
            let ext_Somnia = (path_Somnia as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Somnia) { return url_Somnia }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Somnia 策略对齐）
    /// - Parameter path_Somnia: 媒体路径
    private func loadImage_Somnia(path_Somnia: String) {
        // SF Symbols
        if let img_Somnia = UIImage(systemName: path_Somnia) { applyImage_Somnia(img_Somnia); return }
        // Assets
        if let img_Somnia = UIImage(named: path_Somnia) { applyImage_Somnia(img_Somnia); return }
        // 网络
        if path_Somnia.hasPrefix("http://") || path_Somnia.hasPrefix("https://") {
            guard let url_Somnia = URL(string: path_Somnia) else { showEmpty_Somnia(); return }
            imageView_Somnia.kf.setImage(with: url_Somnia, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Somnia.stopAnimating()
                if case .success(let v_Somnia) = result { self?.onImageLoaded_Somnia(v_Somnia.image) }
                else { self?.showEmpty_Somnia() }
            }
            return
        }
        // Documents 文件名
        let docs_Somnia = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Somnia = docs_Somnia.appendingPathComponent(path_Somnia)
        if let img_Somnia = UIImage(contentsOfFile: docURL_Somnia.path) { applyImage_Somnia(img_Somnia); return }
        // 完整路径
        if let img_Somnia = UIImage(contentsOfFile: path_Somnia) { applyImage_Somnia(img_Somnia); return }
        showEmpty_Somnia()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Somnia: 视频文件 URL
    private func setupVideoPlayer_Somnia(url_Somnia: URL) {
        resolvedType_Somnia = .video_Somnia

        // 切换到视频容器
        scrollView_Somnia.isHidden         = true
        videoContainerView_Somnia.isHidden = false
        progressBg_Somnia.isHidden         = false

        mediaTypeLabel_Somnia.text = "Video"

        let player_Somnia  = AVPlayer(url: url_Somnia)
        self.player_Somnia = player_Somnia
        let layer_Somnia   = AVPlayerLayer(player: player_Somnia)
        layer_Somnia.videoGravity  = .resizeAspect
        layer_Somnia.frame         = videoContainerView_Somnia.bounds
        layer_Somnia.backgroundColor = UIColor.black.cgColor
        videoContainerView_Somnia.layer.insertSublayer(layer_Somnia, at: 0)
        playerLayer_Somnia = layer_Somnia

        // 视频就绪后淡入播放按钮
        player_Somnia.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Somnia = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Somnia = player_Somnia.addPeriodicTimeObserver(
            forInterval: interval_Somnia,
            queue: .main
        ) { [weak self] time_Somnia in
            self?.updateProgress_Somnia(currentTime_Somnia: time_Somnia)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Somnia),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Somnia.currentItem
        )

        loadingIndicator_Somnia.stopAnimating()
        player_Somnia.play()
        isPlaying_Somnia = true
        playPauseButton_Somnia.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Somnia.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Somnia: AVPlayer 当前时间
    private func updateProgress_Somnia(currentTime_Somnia: CMTime) {
        guard let duration_Somnia = player_Somnia?.currentItem?.duration,
              duration_Somnia.isNumeric, duration_Somnia.seconds > 0 else { return }
        let progress_Somnia = CGFloat(currentTime_Somnia.seconds / duration_Somnia.seconds)
        let totalW_Somnia   = progressBg_Somnia.bounds.width
        progressWidthCon_Somnia?.update(offset: totalW_Somnia * min(max(progress_Somnia, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Somnia() {
        player_Somnia?.seek(to: .zero)
        isPlaying_Somnia = false
        playPauseButton_Somnia.isSelected = false
        progressWidthCon_Somnia?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Somnia() {
        if let token_Somnia = timeObserverToken_Somnia {
            player_Somnia?.removeTimeObserver(token_Somnia)
            timeObserverToken_Somnia = nil
        }
        player_Somnia?.removeObserver(self, forKeyPath: "status")
        player_Somnia?.pause()
        player_Somnia = nil
        playerLayer_Somnia?.removeFromSuperlayer()
        playerLayer_Somnia = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Somnia = object as? AVPlayer,
              player_Somnia.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Somnia() }
    }

    // MARK: - 图片辅助

    private func applyImage_Somnia(_ image_Somnia: UIImage) {
        loadingIndicator_Somnia.stopAnimating()
        imageView_Somnia.image = image_Somnia
        imageSize_Somnia       = image_Somnia.size
        mediaTypeLabel_Somnia.text = "Photo"
        updateImageLayout_Somnia()
    }

    private func onImageLoaded_Somnia(_ image_Somnia: UIImage) {
        imageSize_Somnia = image_Somnia.size
        mediaTypeLabel_Somnia.text = "Photo"
        updateImageLayout_Somnia()
    }

    private func showEmpty_Somnia() {
        loadingIndicator_Somnia.stopAnimating()
        imageView_Somnia.image       = UIImage(systemName: "photo.slash")
        imageView_Somnia.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Somnia.contentMode = .center
    }

    private func updateImageLayout_Somnia() {
        guard imageSize_Somnia != .zero else {
            imageView_Somnia.frame = view.bounds
            scrollView_Somnia.contentSize = view.bounds.size
            return
        }
        let screenW_Somnia = view.bounds.width
        let screenH_Somnia = view.bounds.height
        let ratio_Somnia   = imageSize_Somnia.height / imageSize_Somnia.width
        let imgH_Somnia    = screenW_Somnia * ratio_Somnia
        let y_Somnia       = max(0, (screenH_Somnia - imgH_Somnia) / 2)
        imageView_Somnia.frame        = CGRect(x: 0, y: y_Somnia, width: screenW_Somnia, height: imgH_Somnia)
        scrollView_Somnia.contentSize = CGSize(width: screenW_Somnia,
                                              height: max(imgH_Somnia + y_Somnia * 2, screenH_Somnia))
        scrollView_Somnia.zoomScale   = 1.0
        centerImageIfNeeded_Somnia()
    }

    private func centerImageIfNeeded_Somnia() {
        let offX_Somnia = max(0, (scrollView_Somnia.bounds.width  - scrollView_Somnia.contentSize.width)  / 2)
        let offY_Somnia = max(0, (scrollView_Somnia.bounds.height - scrollView_Somnia.contentSize.height) / 2)
        imageView_Somnia.center = CGPoint(
            x: scrollView_Somnia.contentSize.width  / 2 + offX_Somnia,
            y: scrollView_Somnia.contentSize.height / 2 + offY_Somnia
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Somnia(_ gesture_Somnia: UITapGestureRecognizer) {
        guard resolvedType_Somnia == .image_Somnia else { return }
        if scrollView_Somnia.zoomScale > 1.0 {
            scrollView_Somnia.setZoomScale(1.0, animated: true)
        } else {
            let pt_Somnia    = gesture_Somnia.location(in: imageView_Somnia)
            let rect_Somnia  = zoomRect_Somnia(scale_Somnia: 2.5, center_Somnia: pt_Somnia)
            scrollView_Somnia.zoom(to: rect_Somnia, animated: true)
        }
    }

    @objc private func handleSingleTap_Somnia() {
        guard resolvedType_Somnia != .video_Somnia,
              scrollView_Somnia.zoomScale <= 1.01 else { return }
        dismissPage_Somnia(velocity_Somnia: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Somnia() {
        togglePlayPause_Somnia()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Somnia() {
        guard let player_Somnia = player_Somnia else { return }
        if isPlaying_Somnia {
            player_Somnia.pause()
            isPlaying_Somnia = false
            playPauseButton_Somnia.isSelected = false
        } else {
            player_Somnia.play()
            isPlaying_Somnia = true
            playPauseButton_Somnia.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Somnia.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Somnia else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Somnia.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Somnia() {
        dismissPage_Somnia(velocity_Somnia: 0)
    }

    @objc private func handlePan_Somnia(_ gesture_Somnia: UIPanGestureRecognizer) {
        guard scrollView_Somnia.zoomScale <= 1.01 else { return }
        let translation_Somnia = gesture_Somnia.translation(in: view)
        let velocity_Somnia    = gesture_Somnia.velocity(in: view).y
        switch gesture_Somnia.state {
        case .changed:
            let progress_Somnia         = max(0, translation_Somnia.y / view.bounds.height)
            backgroundView_Somnia.alpha = max(0, 1 - progress_Somnia * 1.5)
            topBar_Somnia.alpha         = max(0, 1 - progress_Somnia * 2)
            bottomHint_Somnia.alpha     = max(0, 1 - progress_Somnia * 2)
            let activeView_Somnia: UIView = resolvedType_Somnia == .video_Somnia
                ? videoContainerView_Somnia : scrollView_Somnia
            activeView_Somnia.transform = CGAffineTransform(
                translationX: translation_Somnia.x * 0.3,
                y: max(0, translation_Somnia.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Somnia = translation_Somnia.y > view.bounds.height * 0.25 || velocity_Somnia > 900
            if shouldDismiss_Somnia {
                dismissPage_Somnia(velocity_Somnia: velocity_Somnia)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Somnia.transform         = .identity
                    self.videoContainerView_Somnia.transform = .identity
                    self.backgroundView_Somnia.alpha  = 1
                    self.topBar_Somnia.alpha           = 1
                    self.bottomHint_Somnia.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Somnia: 下拉速度（影响动画时长）
    private func dismissPage_Somnia(velocity_Somnia: CGFloat) {
        guard !isDismissing_Somnia else { return }
        isDismissing_Somnia = true
        player_Somnia?.pause()
        let duration_Somnia = velocity_Somnia > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Somnia, animations: {
            self.view.alpha = 0
            let activeView_Somnia: UIView = self.resolvedType_Somnia == .video_Somnia
                ? self.videoContainerView_Somnia : self.scrollView_Somnia
            activeView_Somnia.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Somnia(scale_Somnia: CGFloat, center_Somnia: CGPoint) -> CGRect {
        let w_Somnia = scrollView_Somnia.bounds.width  / scale_Somnia
        let h_Somnia = scrollView_Somnia.bounds.height / scale_Somnia
        return CGRect(x: center_Somnia.x - w_Somnia / 2,
                      y: center_Somnia.y - h_Somnia / 2,
                      width: w_Somnia, height: h_Somnia)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Somnia: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Somnia }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Somnia() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Somnia: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Somnia = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Somnia.zoomScale <= 1.01 else { return false }
        let vel_Somnia = pan_Somnia.velocity(in: view)
        return abs(vel_Somnia.y) > abs(vel_Somnia.x) && vel_Somnia.y > 0
    }
}
