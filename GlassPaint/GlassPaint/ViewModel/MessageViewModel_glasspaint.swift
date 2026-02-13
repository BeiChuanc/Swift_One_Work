import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Glasspaint {
    /// 个人聊天
    case personal_glasspaint
    /// 群聊
    case group_glasspaint
    /// AI聊天
    case ai_glasspaint
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Glasspaint {
    
    /// 单例
    static let shared_Glasspaint = MessageViewModel_Glasspaint()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Glasspaint = Notification.Name("MessageStateDidChange_Glasspaint")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Glasspaint: [Int: [MessageModel_Glasspaint]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Glasspaint: [Int: GroupChatInfo_Glasspaint] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Glasspaint: [MessageModel_Glasspaint] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Glasspaint: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Glasspaint() {
        userMesMap_Glasspaint = [:]
        aiChats_Glasspaint = []
        setGroup_Glasspaint()
        notifyStateChange_Glasspaint()
    }
    
    /// 设置群聊基础信息
    /// 功能：初始化5个预设群聊
    private func setGroup_Glasspaint() {
        groupChats_Glasspaint = [
            10: GroupChatInfo_Glasspaint(
                gid_glasspaint: 10,
                intro_glasspaint: "Bonfire Stories Hub",
                cover_glasspaint: "",
                join_glasspaint: "",
                messages_glasspaint: []
            ),
            11: GroupChatInfo_Glasspaint(
                gid_glasspaint: 11,
                intro_glasspaint: "Night Gathering Friends",
                cover_glasspaint: "",
                join_glasspaint: "",
                messages_glasspaint: []
            ),
            12: GroupChatInfo_Glasspaint(
                gid_glasspaint: 12,
                intro_glasspaint: "Campfire Adventure Team",
                cover_glasspaint: "",
                join_glasspaint: "",
                messages_glasspaint: []
            ),
            13: GroupChatInfo_Glasspaint(
                gid_glasspaint: 13,
                intro_glasspaint: "Outdoor Bonfire Lovers",
                cover_glasspaint: "",
                join_glasspaint: "",
                messages_glasspaint: []
            ),
            14: GroupChatInfo_Glasspaint(
                gid_glasspaint: 14,
                intro_glasspaint: "Warm Fire Community",
                cover_glasspaint: "",
                join_glasspaint: "",
                messages_glasspaint: []
            )
        ]
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Glasspaint() -> [Int: GroupChatInfo_Glasspaint] {
        return groupChats_Glasspaint
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Glasspaint(userId_glasspaint: Int) -> [MessageModel_Glasspaint] {
        return userMesMap_Glasspaint[userId_glasspaint] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Glasspaint() -> [PrewUserModel_Glasspaint] {
        let userIds_glasspaint = userMesMap_Glasspaint.keys
        return LocalData_Glasspaint.shared_Glasspaint.userList_Glasspaint.filter { user in
            guard let userId = user.userId_Glasspaint else { return false }
            return userIds_glasspaint.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Glasspaint() -> [MessageModel_Glasspaint] {
        return aiChats_Glasspaint
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Glasspaint(groupId_glasspaint: Int) -> [MessageModel_Glasspaint] {
        return groupChats_Glasspaint[groupId_glasspaint]?.messages_glasspaint ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Glasspaint(userId_glasspaint: Int) -> MessageModel_Glasspaint? {
        return userMesMap_Glasspaint[userId_glasspaint]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Glasspaint(message_glasspaint: String, chatType_glasspaint: ChatType_Glasspaint, id_glasspaint: Int) {
        let currentTime_glasspaint = getCurrentTime_Glasspaint()
        
        let chatMessage_glasspaint = MessageModel_Glasspaint(
            messageId_glasspaint: Int(Date().timeIntervalSince1970 * 1000),
            content_glasspaint: message_glasspaint,
            userHead_glasspaint: "current_user_head", // 这里应该从UserViewModel获取
            isMine_glasspaint: true,
            time_glasspaint: currentTime_glasspaint
        )
        
        switch chatType_glasspaint {
        case .personal_glasspaint:
            // 个人聊天
            if userMesMap_Glasspaint[id_glasspaint] == nil {
                userMesMap_Glasspaint[id_glasspaint] = []
            }
            userMesMap_Glasspaint[id_glasspaint]?.append(chatMessage_glasspaint)
            handleMessage_Glasspaint(message_glasspaint: chatMessage_glasspaint, id_glasspaint: id_glasspaint, chatType_glasspaint: chatType_glasspaint)
            
        case .group_glasspaint:
            // 群聊
            if var groupInfo_glasspaint = groupChats_Glasspaint[id_glasspaint] {
                groupInfo_glasspaint.messages_glasspaint.append(chatMessage_glasspaint)
                groupChats_Glasspaint[id_glasspaint] = groupInfo_glasspaint
            } else {
                groupChats_Glasspaint[id_glasspaint] = GroupChatInfo_Glasspaint(
                    gid_glasspaint: id_glasspaint,
                    intro_glasspaint: "",
                    cover_glasspaint: "",
                    join_glasspaint: "",
                    messages_glasspaint: [chatMessage_glasspaint]
                )
            }
            
        case .ai_glasspaint:
            // AI聊天
            aiChats_Glasspaint.append(chatMessage_glasspaint)
            handleMessage_Glasspaint(message_glasspaint: chatMessage_glasspaint, id_glasspaint: id_glasspaint, chatType_glasspaint: chatType_glasspaint)
        }
        
        notifyStateChange_Glasspaint()
    }
    
    /// 处理消息回复
    private func handleMessage_Glasspaint(message_glasspaint: MessageModel_Glasspaint, id_glasspaint: Int, chatType_glasspaint: ChatType_Glasspaint) {
        Task {
            let response_glasspaint = await chatService_Glasspaint(
                userId_glasspaint: 0, // 这里应该从UserViewModel获取
                message_glasspaint: message_glasspaint.content_Glasspaint ?? ""
            )
            
            let replyMessage_glasspaint = MessageModel_Glasspaint(
                messageId_glasspaint: Int(Date().timeIntervalSince1970 * 1000),
                content_glasspaint: response_glasspaint ?? "Server error",
                userHead_glasspaint: "",
                isMine_glasspaint: false,
                time_glasspaint: getCurrentTime_Glasspaint()
            )
            
            switch chatType_glasspaint {
            case .ai_glasspaint:
                aiChats_Glasspaint.append(replyMessage_glasspaint)
                
            case .personal_glasspaint:
                if userMesMap_Glasspaint[id_glasspaint] == nil {
                    userMesMap_Glasspaint[id_glasspaint] = []
                }
                userMesMap_Glasspaint[id_glasspaint]?.append(replyMessage_glasspaint)
                
            case .group_glasspaint:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Glasspaint()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Glasspaint(groupId_glasspaint: Int) {
        if var groupInfo_glasspaint = groupChats_Glasspaint[groupId_glasspaint] {
            groupInfo_glasspaint.messages_glasspaint = []
            groupChats_Glasspaint[groupId_glasspaint] = groupInfo_glasspaint
            notifyStateChange_Glasspaint()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Glasspaint(groupId_glasspaint: Int) {
        groupChats_Glasspaint.removeValue(forKey: groupId_glasspaint)
        notifyStateChange_Glasspaint()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Glasspaint() {
        aiChats_Glasspaint = []
        notifyStateChange_Glasspaint()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Glasspaint(userId_glasspaint: Int) {
        userMesMap_Glasspaint.removeValue(forKey: userId_glasspaint)
        notifyStateChange_Glasspaint()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Glasspaint() {
        userMesMap_Glasspaint = [:]
        groupChats_Glasspaint = [:]
        aiChats_Glasspaint = []
        notifyStateChange_Glasspaint()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Glasspaint() -> String {
        let formatter_glasspaint = DateFormatter()
        formatter_glasspaint.dateFormat = "HH:mm"
        return formatter_glasspaint.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Glasspaint() {
        NotificationCenter.default.post(
            name: MessageViewModel_Glasspaint.messageStateDidChangeNotification_Glasspaint,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Glasspaint(userId_glasspaint: Int, message_glasspaint: String) async -> String? {
        do {
            let bundleId_glasspaint = "com.glasspaint.app"
            let timestamp_glasspaint = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_glasspaint = generateRandomString_Glasspaint(length_glasspaint: 16)
            let sessionId_glasspaint = "\(timestamp_glasspaint)_\(randomString_glasspaint)"
            
            // 解密URL
            let urlString_glasspaint = decryptUrl_Glasspaint(encryptedCodes_glasspaint: MessageViewModel_Glasspaint.chatService_Glasspaint)
            guard let url_glasspaint = URL(string: urlString_glasspaint) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_glasspaint = URLRequest(url: url_glasspaint)
            request_glasspaint.httpMethod = "POST"
            request_glasspaint.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_glasspaint: [String: Any] = [
                "bundle_id": bundleId_glasspaint,
                "session_id": sessionId_glasspaint,
                "content_type": "text",
                "content": message_glasspaint
            ]
            
            request_glasspaint.httpBody = try JSONSerialization.data(withJSONObject: body_glasspaint)
            
            let (data_glasspaint, response_glasspaint) = try await URLSession.shared.data(for: request_glasspaint)
            
            if let httpResponse_glasspaint = response_glasspaint as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_glasspaint.statusCode)")
                
                if httpResponse_glasspaint.statusCode == 200 {
                    if let json_glasspaint = try JSONSerialization.jsonObject(with: data_glasspaint) as? [String: Any],
                       let code_glasspaint = json_glasspaint["code"] as? Int,
                       code_glasspaint == 1003,
                       let data_glasspaint = json_glasspaint["data"] as? [String: Any],
                       let answer_glasspaint = data_glasspaint["answer"] as? String,
                       !answer_glasspaint.isEmpty {
                        return answer_glasspaint
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Glasspaint(encryptedCodes_glasspaint: [Int]) -> String {
        let xorKey_glasspaint = 20 // 异或密钥
        let offset_glasspaint = 23 // 字符偏移量
        
        var result_glasspaint = ""
        
        // 第一层：异或解密
        for code_glasspaint in encryptedCodes_glasspaint {
            let charCode_glasspaint = code_glasspaint ^ xorKey_glasspaint
            if let scalar_glasspaint = UnicodeScalar(charCode_glasspaint) {
                result_glasspaint.append(Character(scalar_glasspaint))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_glasspaint = ""
        for char_glasspaint in result_glasspaint.unicodeScalars {
            let charCode_glasspaint = Int(char_glasspaint.value) - offset_glasspaint
            if let scalar_glasspaint = UnicodeScalar(charCode_glasspaint) {
                finalResult_glasspaint.append(Character(scalar_glasspaint))
            }
        }
        
        return finalResult_glasspaint
    }
    
    /// 生成随机字符串
    private func generateRandomString_Glasspaint(length_glasspaint: Int) -> String {
        let letters_glasspaint = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_glasspaint).map { _ in letters_glasspaint.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Glasspaint {
    /// 群组ID
    var gid_glasspaint: Int
    /// 群组简介
    var intro_glasspaint: String
    /// 群组封面
    var cover_glasspaint: String
    /// 加入信息
    var join_glasspaint: String
    /// 消息列表
    var messages_glasspaint: [MessageModel_Glasspaint]
}
