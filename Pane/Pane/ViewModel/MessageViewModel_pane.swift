import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Pane {
    /// 个人聊天
    case personal_pane
    /// 群聊
    case group_pane
    /// AI聊天
    case ai_pane
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Pane {
    
    /// 单例
    static let shared_Pane = MessageViewModel_Pane()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Pane = Notification.Name("MessageStateDidChange_Pane")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Pane: [Int: [MessageModel_Pane]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Pane: [Int: GroupChatInfo_Pane] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Pane: [MessageModel_Pane] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Pane: [Int] = [
        153, 149, 149, 145, 148, 75, 80, 80, 162, 145, 154, 95, 136, 154, 148, 166, 162, 154, 154, 95, 164, 144, 158, 80, 136, 154, 148, 166, 162, 154, 80, 151, 82, 80, 164, 153, 162, 149
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Pane() {
        userMesMap_Pane = [:]
        aiChats_Pane = []
        notifyStateChange_Pane()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Pane() -> [Int: GroupChatInfo_Pane] {
        return groupChats_Pane
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Pane(userId_pane: Int) -> [MessageModel_Pane] {
        return userMesMap_Pane[userId_pane] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Pane() -> [PrewUserModel_Pane] {
        let userIds_pane = userMesMap_Pane.keys
        return LocalData_Pane.shared_Pane.userList_Pane.filter { user in
            guard let userId = user.userId_Pane else { return false }
            return userIds_pane.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Pane() -> [MessageModel_Pane] {
        return aiChats_Pane
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Pane(groupId_pane: Int) -> [MessageModel_Pane] {
        return groupChats_Pane[groupId_pane]?.messages_pane ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Pane(userId_pane: Int) -> MessageModel_Pane? {
        return userMesMap_Pane[userId_pane]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Pane(message_pane: String, chatType_pane: ChatType_Pane, id_pane: Int) {
        let currentTime_pane = getCurrentTime_Pane()
        
        let chatMessage_pane = MessageModel_Pane(
            messageId_pane: Int(Date().timeIntervalSince1970 * 1000),
            content_pane: message_pane,
            userHead_pane: "current_user_head", // 这里应该从UserViewModel获取
            isMine_pane: true,
            time_pane: currentTime_pane
        )
        
        switch chatType_pane {
        case .personal_pane:
            // 个人聊天
            if userMesMap_Pane[id_pane] == nil {
                userMesMap_Pane[id_pane] = []
            }
            userMesMap_Pane[id_pane]?.append(chatMessage_pane)
            handleMessage_Pane(message_pane: chatMessage_pane, id_pane: id_pane, chatType_pane: chatType_pane)
            
        case .group_pane:
            // 群聊
            if var groupInfo_pane = groupChats_Pane[id_pane] {
                groupInfo_pane.messages_pane.append(chatMessage_pane)
                groupChats_Pane[id_pane] = groupInfo_pane
            } else {
                groupChats_Pane[id_pane] = GroupChatInfo_Pane(
                    gid_pane: id_pane,
                    intro_pane: "",
                    cover_pane: "",
                    join_pane: "",
                    messages_pane: [chatMessage_pane]
                )
            }
            
        case .ai_pane:
            // AI聊天
            aiChats_Pane.append(chatMessage_pane)
            handleMessage_Pane(message_pane: chatMessage_pane, id_pane: id_pane, chatType_pane: chatType_pane)
        }
        
        notifyStateChange_Pane()
    }
    
    /// 处理消息回复
    private func handleMessage_Pane(message_pane: MessageModel_Pane, id_pane: Int, chatType_pane: ChatType_Pane) {
        Task {
            let response_pane = await chatService_Pane(
                userId_pane: 0, // 这里应该从UserViewModel获取
                message_pane: message_pane.content_Pane ?? ""
            )
            
            let replyMessage_pane = MessageModel_Pane(
                messageId_pane: Int(Date().timeIntervalSince1970 * 1000),
                content_pane: response_pane ?? "Server error",
                userHead_pane: "",
                isMine_pane: false,
                time_pane: getCurrentTime_Pane()
            )
            
            switch chatType_pane {
            case .ai_pane:
                aiChats_Pane.append(replyMessage_pane)
                
            case .personal_pane:
                if userMesMap_Pane[id_pane] == nil {
                    userMesMap_Pane[id_pane] = []
                }
                userMesMap_Pane[id_pane]?.append(replyMessage_pane)
                
            case .group_pane:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Pane()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Pane(groupId_pane: Int) {
        if var groupInfo_pane = groupChats_Pane[groupId_pane] {
            groupInfo_pane.messages_pane = []
            groupChats_Pane[groupId_pane] = groupInfo_pane
            notifyStateChange_Pane()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Pane(groupId_pane: Int) {
        groupChats_Pane.removeValue(forKey: groupId_pane)
        notifyStateChange_Pane()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Pane() {
        aiChats_Pane = []
        notifyStateChange_Pane()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Pane(userId_pane: Int) {
        userMesMap_Pane.removeValue(forKey: userId_pane)
        notifyStateChange_Pane()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Pane() {
        userMesMap_Pane = [:]
        groupChats_Pane = [:]
        aiChats_Pane = []
        notifyStateChange_Pane()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Pane() -> String {
        let formatter_pane = DateFormatter()
        formatter_pane.dateFormat = "HH:mm"
        return formatter_pane.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Pane() {
        NotificationCenter.default.post(
            name: MessageViewModel_Pane.messageStateDidChangeNotification_Pane,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Pane(userId_pane: Int, message_pane: String) async -> String? {
        do {
            let bundleId_pane = "com.pane.app"
            let timestamp_pane = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_pane = generateRandomString_Pane(length_pane: 16)
            let sessionId_pane = "\(timestamp_pane)_\(randomString_pane)"
            
            // 解密URL
            let urlString_pane = decryptUrl_Pane(encryptedCodes_pane: MessageViewModel_Pane.chatService_Pane)
            guard let url_pane = URL(string: urlString_pane) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_pane = URLRequest(url: url_pane)
            request_pane.httpMethod = "POST"
            request_pane.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_pane: [String: Any] = [
                "bundle_id": bundleId_pane,
                "session_id": sessionId_pane,
                "content_type": "text",
                "content": message_pane
            ]
            
            request_pane.httpBody = try JSONSerialization.data(withJSONObject: body_pane)
            
            let (data_pane, response_pane) = try await URLSession.shared.data(for: request_pane)
            
            if let httpResponse_pane = response_pane as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_pane.statusCode)")
                
                if httpResponse_pane.statusCode == 200 {
                    if let json_pane = try JSONSerialization.jsonObject(with: data_pane) as? [String: Any],
                       let code_pane = json_pane["code"] as? Int,
                       code_pane == 1003,
                       let data_pane = json_pane["data"] as? [String: Any],
                       let answer_pane = data_pane["answer"] as? String,
                       !answer_pane.isEmpty {
                        return answer_pane
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// 加密方法
    
    /// URL加密方法（双重加密：字符偏移加密 + 异或加密）
    /// - Parameter plainUrl_Pane: 需要加密的URL明文字符串
    /// - Returns: 加密后的整数数组
    static func encryptUrl_Pane(plainUrl_Pane: String) -> [Int] {
        let xorKey_Pane = 824 // 异或密钥
        let offset_Pane = 825 // 字符偏移量
        
        var result_Pane: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Pane in plainUrl_Pane.unicodeScalars {
            let charCode_Pane = Int(char_Pane.value) + offset_Pane
            result_Pane.append(charCode_Pane)
        }
        
        // 第二层：异或加密
        var finalResult_Pane: [Int] = []
        for code_Pane in result_Pane {
            finalResult_Pane.append(code_Pane ^ xorKey_Pane)
        }
        
        print("✅ URL加密结果: \(finalResult_Pane)")
        return finalResult_Pane
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Pane(encryptedCodes_pane: [Int]) -> String {
        let xorKey_pane = 824 // 异或密钥
        let offset_pane = 825 // 字符偏移量
        
        var result_pane = ""
        
        // 第一层：异或解密
        for code_pane in encryptedCodes_pane {
            let charCode_pane = code_pane ^ xorKey_pane
            if let scalar_pane = UnicodeScalar(charCode_pane) {
                result_pane.append(Character(scalar_pane))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_pane = ""
        for char_pane in result_pane.unicodeScalars {
            let charCode_pane = Int(char_pane.value) - offset_pane
            if let scalar_pane = UnicodeScalar(charCode_pane) {
                finalResult_pane.append(Character(scalar_pane))
            }
        }
        
        return finalResult_pane
    }
    
    /// 生成随机字符串
    private func generateRandomString_Pane(length_pane: Int) -> String {
        let letters_pane = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_pane).map { _ in letters_pane.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Pane {
    /// 群组ID
    var gid_pane: Int
    /// 群组简介
    var intro_pane: String
    /// 群组封面
    var cover_pane: String
    /// 加入信息
    var join_pane: String
    /// 消息列表
    var messages_pane: [MessageModel_Pane]
}
