import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Lumia {
    /// 个人聊天
    case personal_lumia
    /// 群聊
    case group_lumia
    /// AI聊天
    case ai_lumia
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Lumia {
    
    /// 单例
    static let shared_Lumia = MessageViewModel_Lumia()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Lumia = Notification.Name("MessageStateDidChange_Lumia")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Lumia: [Int: [MessageModel_Lumia]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Lumia: [Int: GroupChatInfo_Lumia] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Lumia: [MessageModel_Lumia] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Lumia: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Lumia() {
        userMesMap_Lumia = [:]
        aiChats_Lumia = []
        notifyStateChange_Lumia()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Lumia() -> [Int: GroupChatInfo_Lumia] {
        return groupChats_Lumia
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Lumia(userId_lumia: Int) -> [MessageModel_Lumia] {
        return userMesMap_Lumia[userId_lumia] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Lumia() -> [PrewUserModel_Lumia] {
        let userIds_lumia = userMesMap_Lumia.keys
        return LocalData_Lumia.shared_Lumia.userList_Lumia.filter { user in
            guard let userId = user.userId_Lumia else { return false }
            return userIds_lumia.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Lumia() -> [MessageModel_Lumia] {
        return aiChats_Lumia
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Lumia(groupId_lumia: Int) -> [MessageModel_Lumia] {
        return groupChats_Lumia[groupId_lumia]?.messages_lumia ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Lumia(userId_lumia: Int) -> MessageModel_Lumia? {
        return userMesMap_Lumia[userId_lumia]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Lumia(message_lumia: String, chatType_lumia: ChatType_Lumia, id_lumia: Int) {
        let currentTime_lumia = getCurrentTime_Lumia()
        
        let chatMessage_lumia = MessageModel_Lumia(
            messageId_lumia: Int(Date().timeIntervalSince1970 * 1000),
            content_lumia: message_lumia,
            userHead_lumia: "current_user_head", // 这里应该从UserViewModel获取
            isMine_lumia: true,
            time_lumia: currentTime_lumia
        )
        
        switch chatType_lumia {
        case .personal_lumia:
            // 个人聊天
            if userMesMap_Lumia[id_lumia] == nil {
                userMesMap_Lumia[id_lumia] = []
            }
            userMesMap_Lumia[id_lumia]?.append(chatMessage_lumia)
            handleMessage_Lumia(message_lumia: chatMessage_lumia, id_lumia: id_lumia, chatType_lumia: chatType_lumia)
            
        case .group_lumia:
            // 群聊
            if var groupInfo_lumia = groupChats_Lumia[id_lumia] {
                groupInfo_lumia.messages_lumia.append(chatMessage_lumia)
                groupChats_Lumia[id_lumia] = groupInfo_lumia
            } else {
                groupChats_Lumia[id_lumia] = GroupChatInfo_Lumia(
                    gid_lumia: id_lumia,
                    intro_lumia: "",
                    cover_lumia: "",
                    join_lumia: "",
                    messages_lumia: [chatMessage_lumia]
                )
            }
            
        case .ai_lumia:
            // AI聊天
            aiChats_Lumia.append(chatMessage_lumia)
            handleMessage_Lumia(message_lumia: chatMessage_lumia, id_lumia: id_lumia, chatType_lumia: chatType_lumia)
        }
        
        notifyStateChange_Lumia()
    }
    
    /// 处理消息回复
    private func handleMessage_Lumia(message_lumia: MessageModel_Lumia, id_lumia: Int, chatType_lumia: ChatType_Lumia) {
        Task {
            let response_lumia = await chatService_Lumia(
                userId_lumia: 0, // 这里应该从UserViewModel获取
                message_lumia: message_lumia.content_Lumia ?? ""
            )
            
            let replyMessage_lumia = MessageModel_Lumia(
                messageId_lumia: Int(Date().timeIntervalSince1970 * 1000),
                content_lumia: response_lumia ?? "Server error",
                userHead_lumia: "",
                isMine_lumia: false,
                time_lumia: getCurrentTime_Lumia()
            )
            
            switch chatType_lumia {
            case .ai_lumia:
                aiChats_Lumia.append(replyMessage_lumia)
                
            case .personal_lumia:
                if userMesMap_Lumia[id_lumia] == nil {
                    userMesMap_Lumia[id_lumia] = []
                }
                userMesMap_Lumia[id_lumia]?.append(replyMessage_lumia)
                
            case .group_lumia:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Lumia()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Lumia(groupId_lumia: Int) {
        if var groupInfo_lumia = groupChats_Lumia[groupId_lumia] {
            groupInfo_lumia.messages_lumia = []
            groupChats_Lumia[groupId_lumia] = groupInfo_lumia
            notifyStateChange_Lumia()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Lumia(groupId_lumia: Int) {
        groupChats_Lumia.removeValue(forKey: groupId_lumia)
        notifyStateChange_Lumia()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Lumia() {
        aiChats_Lumia = []
        notifyStateChange_Lumia()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Lumia(userId_lumia: Int) {
        userMesMap_Lumia.removeValue(forKey: userId_lumia)
        notifyStateChange_Lumia()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Lumia() {
        userMesMap_Lumia = [:]
        groupChats_Lumia = [:]
        aiChats_Lumia = []
        notifyStateChange_Lumia()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Lumia() -> String {
        let formatter_lumia = DateFormatter()
        formatter_lumia.dateFormat = "HH:mm"
        return formatter_lumia.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Lumia() {
        NotificationCenter.default.post(
            name: MessageViewModel_Lumia.messageStateDidChangeNotification_Lumia,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Lumia(userId_lumia: Int, message_lumia: String) async -> String? {
        do {
            let bundleId_lumia = "com.lumia.app"
            let timestamp_lumia = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_lumia = generateRandomString_Lumia(length_lumia: 16)
            let sessionId_lumia = "\(timestamp_lumia)_\(randomString_lumia)"
            
            // 解密URL
            let urlString_lumia = decryptUrl_Lumia(encryptedCodes_lumia: MessageViewModel_Lumia.chatService_Lumia)
            guard let url_lumia = URL(string: urlString_lumia) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_lumia = URLRequest(url: url_lumia)
            request_lumia.httpMethod = "POST"
            request_lumia.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_lumia: [String: Any] = [
                "bundle_id": bundleId_lumia,
                "session_id": sessionId_lumia,
                "content_type": "text",
                "content": message_lumia
            ]
            
            request_lumia.httpBody = try JSONSerialization.data(withJSONObject: body_lumia)
            
            let (data_lumia, response_lumia) = try await URLSession.shared.data(for: request_lumia)
            
            if let httpResponse_lumia = response_lumia as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_lumia.statusCode)")
                
                if httpResponse_lumia.statusCode == 200 {
                    if let json_lumia = try JSONSerialization.jsonObject(with: data_lumia) as? [String: Any],
                       let code_lumia = json_lumia["code"] as? Int,
                       code_lumia == 1003,
                       let data_lumia = json_lumia["data"] as? [String: Any],
                       let answer_lumia = data_lumia["answer"] as? String,
                       !answer_lumia.isEmpty {
                        return answer_lumia
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
    static func encryptUrl_Lumia(plainUrl_Lumia: String) -> [Int] {
        let xorKey_Lumia = 20 // 异或密钥
        let offset_Lumia = 23 // 字符偏移量
        
        var result_Lumia: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Lumia in plainUrl_Lumia.unicodeScalars {
            let charCode_Lumia = Int(char_Lumia.value) + offset_Lumia
            result_Lumia.append(charCode_Lumia)
        }
        
        // 第二层：异或加密
        var finalResult_Lumia: [Int] = []
        for code_Lumia in result_Lumia {
            finalResult_Lumia.append(code_Lumia ^ xorKey_Lumia)
        }
        
        print("✅ URL加密结果: \(finalResult_Lumia)")
        return finalResult_Lumia
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Lumia(encryptedCodes_lumia: [Int]) -> String {
        let xorKey_lumia = 20 // 异或密钥
        let offset_lumia = 23 // 字符偏移量
        
        var result_lumia = ""
        
        // 第一层：异或解密
        for code_lumia in encryptedCodes_lumia {
            let charCode_lumia = code_lumia ^ xorKey_lumia
            if let scalar_lumia = UnicodeScalar(charCode_lumia) {
                result_lumia.append(Character(scalar_lumia))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_lumia = ""
        for char_lumia in result_lumia.unicodeScalars {
            let charCode_lumia = Int(char_lumia.value) - offset_lumia
            if let scalar_lumia = UnicodeScalar(charCode_lumia) {
                finalResult_lumia.append(Character(scalar_lumia))
            }
        }
        
        return finalResult_lumia
    }
    
    /// 生成随机字符串
    private func generateRandomString_Lumia(length_lumia: Int) -> String {
        let letters_lumia = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_lumia).map { _ in letters_lumia.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Lumia {
    /// 群组ID
    var gid_lumia: Int
    /// 群组简介
    var intro_lumia: String
    /// 群组封面
    var cover_lumia: String
    /// 加入信息
    var join_lumia: String
    /// 消息列表
    var messages_lumia: [MessageModel_Lumia]
}
