import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Sprig {
    /// 个人聊天
    case personal_sprig
    /// 群聊
    case group_sprig
    /// AI聊天
    case ai_sprig
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Sprig {
    
    /// 单例
    static let shared_Sprig = MessageViewModel_Sprig()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Sprig = Notification.Name("MessageStateDidChange_Sprig")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Sprig: [Int: [MessageModel_Sprig]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Sprig: [Int: GroupChatInfo_Sprig] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Sprig: [MessageModel_Sprig] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Sprig: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Sprig() {
        userMesMap_Sprig = [:]
        aiChats_Sprig = []
        notifyStateChange_Sprig()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Sprig() -> [Int: GroupChatInfo_Sprig] {
        return groupChats_Sprig
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Sprig(userId_sprig: Int) -> [MessageModel_Sprig] {
        return userMesMap_Sprig[userId_sprig] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Sprig() -> [PrewUserModel_Sprig] {
        let userIds_sprig = userMesMap_Sprig.keys
        return LocalData_Sprig.shared_Sprig.userList_Sprig.filter { user in
            guard let userId = user.userId_Sprig else { return false }
            return userIds_sprig.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Sprig() -> [MessageModel_Sprig] {
        return aiChats_Sprig
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Sprig(groupId_sprig: Int) -> [MessageModel_Sprig] {
        return groupChats_Sprig[groupId_sprig]?.messages_sprig ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Sprig(userId_sprig: Int) -> MessageModel_Sprig? {
        return userMesMap_Sprig[userId_sprig]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Sprig(message_sprig: String, chatType_sprig: ChatType_Sprig, id_sprig: Int) {
        let currentTime_sprig = getCurrentTime_Sprig()
        
        let chatMessage_sprig = MessageModel_Sprig(
            messageId_sprig: Int(Date().timeIntervalSince1970 * 1000),
            content_sprig: message_sprig,
            userHead_sprig: "current_user_head", // 这里应该从UserViewModel获取
            isMine_sprig: true,
            time_sprig: currentTime_sprig
        )
        
        switch chatType_sprig {
        case .personal_sprig:
            // 个人聊天
            if userMesMap_Sprig[id_sprig] == nil {
                userMesMap_Sprig[id_sprig] = []
            }
            userMesMap_Sprig[id_sprig]?.append(chatMessage_sprig)
            handleMessage_Sprig(message_sprig: chatMessage_sprig, id_sprig: id_sprig, chatType_sprig: chatType_sprig)
            
        case .group_sprig:
            // 群聊
            if var groupInfo_sprig = groupChats_Sprig[id_sprig] {
                groupInfo_sprig.messages_sprig.append(chatMessage_sprig)
                groupChats_Sprig[id_sprig] = groupInfo_sprig
            } else {
                groupChats_Sprig[id_sprig] = GroupChatInfo_Sprig(
                    gid_sprig: id_sprig,
                    intro_sprig: "",
                    cover_sprig: "",
                    join_sprig: "",
                    messages_sprig: [chatMessage_sprig]
                )
            }
            
        case .ai_sprig:
            // AI聊天
            aiChats_Sprig.append(chatMessage_sprig)
            handleMessage_Sprig(message_sprig: chatMessage_sprig, id_sprig: id_sprig, chatType_sprig: chatType_sprig)
        }
        
        notifyStateChange_Sprig()
    }
    
    /// 处理消息回复
    private func handleMessage_Sprig(message_sprig: MessageModel_Sprig, id_sprig: Int, chatType_sprig: ChatType_Sprig) {
        Task {
            let response_sprig = await chatService_Sprig(
                userId_sprig: 0, // 这里应该从UserViewModel获取
                message_sprig: message_sprig.content_Sprig ?? ""
            )
            
            let replyMessage_sprig = MessageModel_Sprig(
                messageId_sprig: Int(Date().timeIntervalSince1970 * 1000),
                content_sprig: response_sprig ?? "Server error",
                userHead_sprig: "",
                isMine_sprig: false,
                time_sprig: getCurrentTime_Sprig()
            )
            
            switch chatType_sprig {
            case .ai_sprig:
                aiChats_Sprig.append(replyMessage_sprig)
                
            case .personal_sprig:
                if userMesMap_Sprig[id_sprig] == nil {
                    userMesMap_Sprig[id_sprig] = []
                }
                userMesMap_Sprig[id_sprig]?.append(replyMessage_sprig)
                
            case .group_sprig:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Sprig()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Sprig(groupId_sprig: Int) {
        if var groupInfo_sprig = groupChats_Sprig[groupId_sprig] {
            groupInfo_sprig.messages_sprig = []
            groupChats_Sprig[groupId_sprig] = groupInfo_sprig
            notifyStateChange_Sprig()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Sprig(groupId_sprig: Int) {
        groupChats_Sprig.removeValue(forKey: groupId_sprig)
        notifyStateChange_Sprig()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Sprig() {
        aiChats_Sprig = []
        notifyStateChange_Sprig()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Sprig(userId_sprig: Int) {
        userMesMap_Sprig.removeValue(forKey: userId_sprig)
        notifyStateChange_Sprig()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Sprig() {
        userMesMap_Sprig = [:]
        groupChats_Sprig = [:]
        aiChats_Sprig = []
        notifyStateChange_Sprig()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Sprig() -> String {
        let formatter_sprig = DateFormatter()
        formatter_sprig.dateFormat = "HH:mm"
        return formatter_sprig.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Sprig() {
        NotificationCenter.default.post(
            name: MessageViewModel_Sprig.messageStateDidChangeNotification_Sprig,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Sprig(userId_sprig: Int, message_sprig: String) async -> String? {
        do {
            let bundleId_sprig = "com.sprig.app"
            let timestamp_sprig = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_sprig = generateRandomString_Sprig(length_sprig: 16)
            let sessionId_sprig = "\(timestamp_sprig)_\(randomString_sprig)"
            
            // 解密URL
            let urlString_sprig = decryptUrl_Sprig(encryptedCodes_sprig: MessageViewModel_Sprig.chatService_Sprig)
            guard let url_sprig = URL(string: urlString_sprig) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_sprig = URLRequest(url: url_sprig)
            request_sprig.httpMethod = "POST"
            request_sprig.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_sprig: [String: Any] = [
                "bundle_id": bundleId_sprig,
                "session_id": sessionId_sprig,
                "content_type": "text",
                "content": message_sprig
            ]
            
            request_sprig.httpBody = try JSONSerialization.data(withJSONObject: body_sprig)
            
            let (data_sprig, response_sprig) = try await URLSession.shared.data(for: request_sprig)
            
            if let httpResponse_sprig = response_sprig as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_sprig.statusCode)")
                
                if httpResponse_sprig.statusCode == 200 {
                    if let json_sprig = try JSONSerialization.jsonObject(with: data_sprig) as? [String: Any],
                       let code_sprig = json_sprig["code"] as? Int,
                       code_sprig == 1003,
                       let data_sprig = json_sprig["data"] as? [String: Any],
                       let answer_sprig = data_sprig["answer"] as? String,
                       !answer_sprig.isEmpty {
                        return answer_sprig
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
    static func encryptUrl_Sprig(plainUrl_Sprig: String) -> [Int] {
        let xorKey_Sprig = 20 // 异或密钥
        let offset_Sprig = 23 // 字符偏移量
        
        var result_Sprig: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Sprig in plainUrl_Sprig.unicodeScalars {
            let charCode_Sprig = Int(char_Sprig.value) + offset_Sprig
            result_Sprig.append(charCode_Sprig)
        }
        
        // 第二层：异或加密
        var finalResult_Sprig: [Int] = []
        for code_Sprig in result_Sprig {
            finalResult_Sprig.append(code_Sprig ^ xorKey_Sprig)
        }
        
        print("✅ URL加密结果: \(finalResult_Sprig)")
        return finalResult_Sprig
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Sprig(encryptedCodes_sprig: [Int]) -> String {
        let xorKey_sprig = 20 // 异或密钥
        let offset_sprig = 23 // 字符偏移量
        
        var result_sprig = ""
        
        // 第一层：异或解密
        for code_sprig in encryptedCodes_sprig {
            let charCode_sprig = code_sprig ^ xorKey_sprig
            if let scalar_sprig = UnicodeScalar(charCode_sprig) {
                result_sprig.append(Character(scalar_sprig))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_sprig = ""
        for char_sprig in result_sprig.unicodeScalars {
            let charCode_sprig = Int(char_sprig.value) - offset_sprig
            if let scalar_sprig = UnicodeScalar(charCode_sprig) {
                finalResult_sprig.append(Character(scalar_sprig))
            }
        }
        
        return finalResult_sprig
    }
    
    /// 生成随机字符串
    private func generateRandomString_Sprig(length_sprig: Int) -> String {
        let letters_sprig = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_sprig).map { _ in letters_sprig.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Sprig {
    /// 群组ID
    var gid_sprig: Int
    /// 群组简介
    var intro_sprig: String
    /// 群组封面
    var cover_sprig: String
    /// 加入信息
    var join_sprig: String
    /// 消息列表
    var messages_sprig: [MessageModel_Sprig]
}
