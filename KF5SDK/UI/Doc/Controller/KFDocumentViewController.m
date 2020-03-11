//
//  KFDocumentViewController.m
//  Pods
//
//  Created by admin on 16/10/12.
//
//

#import "KFDocumentViewController.h"
#import <WebKit/WebKit.h>
#import "KFCategory.h"
#import "KFDocument.h"
#import "KFUserManager.h"
#import "KFCategory.h"

@interface KFDocumentViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, weak) WKWebView *webView;

@end

@implementation KFDocumentViewController

- (instancetype)initWithPost:(KFDocItem *)post{
    self = [super init];
    if (self) {
        _post = post;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title.length && self.post) self.title = self.post.title;
    
    WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
     configuration.preferences = [[WKPreferences alloc] init];
     configuration.userContentController = [[WKUserContentController alloc] init];
     
     WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
     webView.backgroundColor = [UIColor clearColor];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
    [webView kf5_makeConstraints:^(KFAutoLayout * _Nonnull make) {
        make.top.kf_equalTo(self.view);
        make.left.kf_equalTo(self.view);
        make.bottom.kf_equalTo(self.view);
        make.right.kf_equalTo(self.view);
    }];
    
    [self reloadData];
}

- (void)reloadData{
    if (![KFHelper isNetworkEnable]) {
        [KFProgressHUD showErrorTitleToView:self.view title:KF5Localized(@"kf5_no_internet") hideAfter:3];
        return ;
    }
    [KFProgressHUD showDefaultLoadingTo:self.view];
    NSDictionary *params =
    @{
      KF5UserToken:[KFUserManager shareUserManager].user.userToken?:@"",
      KF5PostId:@(self.post.Id)
      };
    
    __weak typeof(self)weakSelf = self;
    [KFHttpTool getDocumentWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                //progress在webView的代理中隐藏
                [weakSelf refreshWithDocument:[KFDocument documentWithDict:[result kf5_dictionaryForKeyPath:@"data.post"]]];
            }else{
                [weakSelf endLoading];
                [[[UIAlertView alloc]initWithTitle:KF5Localized(@"kf5_reminder") message:error.localizedDescription delegate:nil cancelButtonTitle:KF5Localized(@"kf5_confirm") otherButtonTitles:nil, nil]show];
            }
        });
        
    }];
}

- (void)refreshWithDocument:(KFDocument *)document{

    NSMutableString *attachmentStr = nil;
    if (document.attachments.count > 0) {
        attachmentStr = [[NSMutableString alloc] initWithString:@"<ul class=\"attachment-list\">"];
        for (NSDictionary *attachment in document.attachments) {
            NSString *url = [attachment kf5_stringForKeyPath:@"content_url"];
            NSString *name = [attachment kf5_stringForKeyPath:@"name"];
            NSString *size = [NSByteCountFormatter stringFromByteCount:[attachment kf5_numberForKeyPath:@"size"].longLongValue countStyle:NSByteCountFormatterCountStyleBinary];
            [attachmentStr appendFormat:@"<li><a href=\"%@\">%@</a><span> • %@</span></li>",url,name,size];
        }
        [attachmentStr appendString:@"</ul>"];
    }

    NSString *html = [NSString stringWithFormat:[NSString stringWithContentsOfFile:KF5SrcName(@"kf5_document.html") encoding:NSUTF8StringEncoding error:nil],document.title,document.content,attachmentStr?:@"",[[NSDate dateWithTimeIntervalSince1970:document.created_at] kf5_string]];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:[KFConfig shareConfig].hostName ?: @""]];
}

- (void)endLoading{
    [KFProgressHUD hideHUDForView:self.view];
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if (url && navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        NSString *urlStr = url.absoluteString.lowercaseString;
        if ([urlStr hasPrefix:@"http"] || [urlStr hasPrefix:@"sms:"] || [urlStr hasPrefix:@"tel:"] || [urlStr hasPrefix:@"mailto:"]) {
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication]openURL:url];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
    }
    if(navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self endLoading];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self endLoading];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self endLoading];
}
/// 设置支持Https
-(void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
}

#pragma mark- WKUIDelegate

-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertVC addAction:actionCancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    UIAlertAction *actionDone = [UIAlertAction actionWithTitle:@"Done" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [alertVC addAction:actionDone];
    [alertVC addAction:actionCancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
