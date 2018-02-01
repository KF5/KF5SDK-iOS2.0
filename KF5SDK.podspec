Pod::Spec.new do |s|
    s.name        = 'KF5SDK'
    s.version     = '2.6.1'
    s.summary     = '逸创云客服SDK嵌入到您原生iOS APP中，集成了工单反馈、反馈列表、文档知识库和即时交谈IM。'
    s.description = '逸创云客服官方SDK，帮助开发者快速完成开发，提供给开发者创建工单、查看工单列表、回复工单、查看和搜索知识库文档、消息通知推送、即时IM等功能。目前支持iOS8.0及以上系统。详细信息请见官网www.kf5.com(为您留住每一个客户,企业信赖的全渠道云客服平台)。'
    s.license     = 'MIT'
    s.authors     = {"KF5"=>"saintye@kf5.com"}
    s.homepage    = 'http://developer.kf5.com/ios'

    s.source      = { :git => "https://github.com/KF5/KF5SDK-iOS2.0.git", :tag => s.version.to_s }

    s.platform    = :ios, '8.0'
    s.requires_arc = true

    s.vendored_frameworks = 'KF5SDK/KF5SDK.framework'
    s.frameworks = 'Foundation', 'UIKit', 'JavaScriptCore'
    s.libraries   = 'sqlite3'

    s.subspec 'Base' do |ss|
        ss.source_files = 'KF5SDK/UI/Base/**/*','KF5SDK/UI/Category/**/*','KF5SDK/UI/Lib/**/*'
        ss.public_header_files = 'KF5SDK/UI/Base/**/*.h','KF5SDK/UI/Category/**/*.h','KF5SDK/UI/Lib/**/*.h'
        ss.resources    = "KF5SDK/UI/KF5SDK.bundle"
        ss.dependency 'MBProgressHUD', '~> 1.1.0'
        ss.dependency 'AFNetworking/Reachability', '~> 3.1.0'
    end

    s.subspec 'Doc' do |ss|
        ss.source_files = 'KF5SDK/UI/Doc/**/*'
        ss.public_header_files = 'KF5SDK/UI/Doc/**/*.h'
        ss.dependency 'KF5SDK/Base'
        ss.dependency 'MJRefresh', '~> 3.1.15'
    end

    s.subspec 'Ticket' do |ss|
        ss.source_files = 'KF5SDK/UI/Ticket/**/*'
        ss.public_header_files = 'KF5SDK/UI/Ticket/**/*.h'
        ss.dependency 'KF5SDK/Base'
        ss.dependency 'MJRefresh', '~> 3.1.15'
        ss.dependency 'SDWebImage/Core', '~> 4.2.2'
        ss.dependency 'TZImagePickerController', '~> 1.9.6'
    end

    s.subspec 'Chat' do |ss|
        ss.source_files = 'KF5SDK/UI/Vendors/ML{AudioPlayer,Recorder}/**/*','KF5SDK/UI/Chat/**/*'
        ss.public_header_files = 'KF5SDK/UI/Chat/**/*.h','KF5SDK/UI/Vendors/MLAudioPlayer/**/*.h','KF5SDK/UI/Vendors/MLRecorder/**/*.h'
        ss.vendored_library    = 'KF5SDK/UI/**/libopencore-amrnb.a'
        ss.dependency 'KF5SDK/Doc'
        ss.dependency 'KF5SDK/Ticket'
        ss.dependency 'SDWebImage/Core', '~> 4.2.2'
        ss.dependency 'TZImagePickerController', '~> 1.9.6'
    end

end
