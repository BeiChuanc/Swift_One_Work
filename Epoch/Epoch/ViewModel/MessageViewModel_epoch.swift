import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Epoch {
    /// 个人聊天
    case personal_epoch
    /// 群聊
    case group_epoch
    /// AI聊天
    case ai_epoch
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Epoch {
    
    /// 单例
    static let shared_Epoch = MessageViewModel_Epoch()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Epoch = Notification.Name("MessageStateDidChange_Epoch")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Epoch: [Int: [MessageModel_Epoch]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Epoch: [Int: GroupChatInfo_Epoch] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Epoch: [MessageModel_Epoch] = []

    /// 聊天服务URL（加密）
    private static let chatService_Epoch: [Int] = [
        939, 959, 959, 947, 956, 965, 1008, 1008, 930, 947, 938, 1009, 952, 938, 956, 942, 930, 938, 938, 1009, 940, 944, 950, 1008, 952, 938, 956, 942, 930, 938, 1008, 953, 1010, 1008, 940, 939, 930, 959
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Epoch() {
        userMesMap_Epoch = [:]
        aiChats_Epoch = []
        notifyStateChange_Epoch()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Epoch() -> [Int: GroupChatInfo_Epoch] {
        return groupChats_Epoch
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Epoch(userId_epoch: Int) -> [MessageModel_Epoch] {
        return userMesMap_Epoch[userId_epoch] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Epoch() -> [PrewUserModel_Epoch] {
        let sortedIds_epoch = userMesMap_Epoch.keys.sorted { left_epoch, right_epoch in
            let leftValue_epoch = userMesMap_Epoch[left_epoch]?.last?.messageId_Epoch ?? 0
            let rightValue_epoch = userMesMap_Epoch[right_epoch]?.last?.messageId_Epoch ?? 0
            return leftValue_epoch > rightValue_epoch
        }
        let users_epoch = LocalData_Epoch.shared_Epoch.userList_Epoch.filter { user in
            guard let userId = user.userId_Epoch else { return false }
            return sortedIds_epoch.contains(userId)
        }
        return users_epoch.sorted { left_epoch, right_epoch in
            let leftId_epoch = left_epoch.userId_Epoch ?? 0
            let rightId_epoch = right_epoch.userId_Epoch ?? 0
            return sortedIds_epoch.firstIndex(of: leftId_epoch) ?? 0 < sortedIds_epoch.firstIndex(of: rightId_epoch) ?? 0
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Epoch() -> [MessageModel_Epoch] {
        return aiChats_Epoch
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Epoch(groupId_epoch: Int) -> [MessageModel_Epoch] {
        return groupChats_Epoch[groupId_epoch]?.messages_epoch ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Epoch(userId_epoch: Int) -> MessageModel_Epoch? {
        return userMesMap_Epoch[userId_epoch]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Epoch(message_epoch: String, chatType_epoch: ChatType_Epoch, id_epoch: Int) {
        let normalizedMessage_epoch = message_epoch.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedMessage_epoch.isEmpty else { return }

        let currentTime_epoch = getCurrentTime_Epoch()
        
        let chatMessage_epoch = MessageModel_Epoch(
            messageId_epoch: Int(Date().timeIntervalSince1970 * 1000),
            content_epoch: normalizedMessage_epoch,
            userHead_epoch: "current_user_head", // 这里应该从UserViewModel获取
            isMine_epoch: true,
            time_epoch: currentTime_epoch
        )
        
        switch chatType_epoch {
        case .personal_epoch:
            startConversationIfNeeded_Epoch(userId_epoch: id_epoch)
            userMesMap_Epoch[id_epoch]?.append(chatMessage_epoch)
            
        case .group_epoch:
            if var groupInfo_epoch = groupChats_Epoch[id_epoch] {
                groupInfo_epoch.messages_epoch.append(chatMessage_epoch)
                groupChats_Epoch[id_epoch] = groupInfo_epoch
            } else {
                groupChats_Epoch[id_epoch] = GroupChatInfo_Epoch(
                    gid_epoch: id_epoch,
                    intro_epoch: "",
                    cover_epoch: "",
                    join_epoch: "",
                    messages_epoch: [chatMessage_epoch]
                )
            }
            
        case .ai_epoch:
            aiChats_Epoch.append(chatMessage_epoch)
            handleMessage_Epoch(message_epoch: chatMessage_epoch, id_epoch: id_epoch, chatType_epoch: chatType_epoch)
        }
        
        notifyStateChange_Epoch()
    }

    /// 确保聊天会话已存在（仅初始化空列表，不插入欢迎消息）
    /// - Parameter userId_epoch: 对方用户ID
    func startConversationIfNeeded_Epoch(userId_epoch: Int) {
        guard userMesMap_Epoch[userId_epoch] == nil else { return }
        userMesMap_Epoch[userId_epoch] = []
    }
    
    /// 处理消息回复
    private func handleMessage_Epoch(message_epoch: MessageModel_Epoch, id_epoch: Int, chatType_epoch: ChatType_Epoch) {
        Task {
            let response_epoch = await chatService_Epoch(
                userId_epoch: 0, // 这里应该从UserViewModel获取
                message_epoch: message_epoch.content_Epoch ?? ""
            )
            
            let replyMessage_epoch = MessageModel_Epoch(
                messageId_epoch: Int(Date().timeIntervalSince1970 * 1000),
                content_epoch: response_epoch ?? "Server error",
                userHead_epoch: "",
                isMine_epoch: false,
                time_epoch: getCurrentTime_Epoch()
            )
            
            switch chatType_epoch {
            case .ai_epoch:
                aiChats_Epoch.append(replyMessage_epoch)
                
            case .personal_epoch:
                if userMesMap_Epoch[id_epoch] == nil {
                    userMesMap_Epoch[id_epoch] = []
                }
                userMesMap_Epoch[id_epoch]?.append(replyMessage_epoch)
                
            case .group_epoch:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Epoch()
        }
    }

    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Epoch(groupId_epoch: Int) {
        if var groupInfo_epoch = groupChats_Epoch[groupId_epoch] {
            groupInfo_epoch.messages_epoch = []
            groupChats_Epoch[groupId_epoch] = groupInfo_epoch
            notifyStateChange_Epoch()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Epoch(groupId_epoch: Int) {
        groupChats_Epoch.removeValue(forKey: groupId_epoch)
        notifyStateChange_Epoch()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Epoch() {
        aiChats_Epoch = []
        notifyStateChange_Epoch()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Epoch(userId_epoch: Int) {
        userMesMap_Epoch.removeValue(forKey: userId_epoch)
        notifyStateChange_Epoch()
    }

    /// 判断是否存在聊天记录
    /// - Parameter userId_epoch: 用户ID
    /// - Returns: 是否有聊天记录
    func hasMessages_Epoch(userId_epoch: Int) -> Bool {
        return !(userMesMap_Epoch[userId_epoch] ?? []).isEmpty
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Epoch() {
        userMesMap_Epoch = [:]
        groupChats_Epoch = [:]
        aiChats_Epoch = []
        notifyStateChange_Epoch()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Epoch() -> String {
        let formatter_epoch = DateFormatter()
        formatter_epoch.dateFormat = "HH:mm"
        return formatter_epoch.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Epoch() {
        NotificationCenter.default.post(
            name: MessageViewModel_Epoch.messageStateDidChangeNotification_Epoch,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Epoch(userId_epoch: Int, message_epoch: String) async -> String? {
        do {
            let bundleId_epoch = "com.epoch.app"
            let timestamp_epoch = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_epoch = generateRandomString_Epoch(length_epoch: 16)
            let sessionId_epoch = "\(timestamp_epoch)_\(randomString_epoch)"
            
            // 解密URL
            let urlString_epoch = decryptUrl_Epoch(encryptedCodes_epoch: MessageViewModel_Epoch.chatService_Epoch)
            guard let url_epoch = URL(string: urlString_epoch) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_epoch = URLRequest(url: url_epoch)
            request_epoch.httpMethod = "POST"
            request_epoch.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_epoch: [String: Any] = [
                "bundle_id": bundleId_epoch,
                "session_id": sessionId_epoch,
                "content_type": "text",
                "content": message_epoch
            ]
            
            request_epoch.httpBody = try JSONSerialization.data(withJSONObject: body_epoch)
            
            let (data_epoch, response_epoch) = try await URLSession.shared.data(for: request_epoch)
            
            if let httpResponse_epoch = response_epoch as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_epoch.statusCode)")
                
                if httpResponse_epoch.statusCode == 200 {
                    if let json_epoch = try JSONSerialization.jsonObject(with: data_epoch) as? [String: Any],
                       let code_epoch = json_epoch["code"] as? Int,
                       code_epoch == 1003,
                       let data_epoch = json_epoch["data"] as? [String: Any],
                       let answer_epoch = data_epoch["answer"] as? String,
                       !answer_epoch.isEmpty {
                        return answer_epoch
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL加密方法（双重加密：字符偏移加密 + 异或加密）
    static func encryptUrl_Epoch(plainUrl_Epoch: String) -> [Int] {
        let xorKey_Epoch = 3557 // 异或密钥
        let offset_Epoch = 3558 // 字符偏移量
        
        var result_Epoch: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Epoch in plainUrl_Epoch.unicodeScalars {
            let charCode_Epoch = Int(char_Epoch.value) + offset_Epoch
            result_Epoch.append(charCode_Epoch)
        }
        
        // 第二层：异或加密
        var finalResult_Epoch: [Int] = []
        for code_Epoch in result_Epoch {
            finalResult_Epoch.append(code_Epoch ^ xorKey_Epoch)
        }
        
        print("✅ URL加密结果: \(finalResult_Epoch)")
        return finalResult_Epoch
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Epoch(encryptedCodes_epoch: [Int]) -> String {
        let xorKey_epoch = 3557 // 异或密钥
        let offset_epoch = 3558 // 字符偏移量
        
        var result_epoch = ""
        
        // 第一层：异或解密
        for code_epoch in encryptedCodes_epoch {
            let charCode_epoch = code_epoch ^ xorKey_epoch
            if let scalar_epoch = UnicodeScalar(charCode_epoch) {
                result_epoch.append(Character(scalar_epoch))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_epoch = ""
        for char_epoch in result_epoch.unicodeScalars {
            let charCode_epoch = Int(char_epoch.value) - offset_epoch
            if let scalar_epoch = UnicodeScalar(charCode_epoch) {
                finalResult_epoch.append(Character(scalar_epoch))
            }
        }
        
        return finalResult_epoch
    }
    
    /// 生成随机字符串
    private func generateRandomString_Epoch(length_epoch: Int) -> String {
        let letters_epoch = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_epoch).map { _ in letters_epoch.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Epoch {
    /// 群组ID
    var gid_epoch: Int
    /// 群组简介
    var intro_epoch: String
    /// 群组封面
    var cover_epoch: String
    /// 加入信息
    var join_epoch: String
    /// 消息列表
    var messages_epoch: [MessageModel_Epoch]
}
