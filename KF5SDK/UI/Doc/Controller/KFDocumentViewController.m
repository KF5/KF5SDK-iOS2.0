//
//  KFDocumentViewController.m
//  Pods
//
//  Created by admin on 16/10/12.
//
//

#import "KFDocumentViewController.h"
#import "KFCategory.h"
#import "KFDocument.h"
#import "KFUserManager.h"

@interface KFDocumentViewController ()<UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;

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
    
    UIWebView *webView = [[UIWebView alloc]init];
    webView.delegate = self;
    webView.backgroundColor = [UIColor clearColor];
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
    webView.dataDetectorTypes = UIDataDetectorTypeNone;
    webView.opaque = NO;
    for (UIView* subview in [webView.scrollView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            ((UIImageView*)subview).image = nil;
            subview.backgroundColor = [UIColor clearColor];
        }
    }
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
    
    NSString *html = [NSString stringWithFormat:[NSString stringWithContentsOfFile:KF5SrcName(@"kf5_document.html") encoding:NSUTF8StringEncoding error:nil],KF5SrcName(@"KFUserDocument.css"),document.title,document.content,attachmentStr?:@"",[[NSDate dateWithTimeIntervalSince1970:document.created_at] kf5_string]];
    [self.webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]  bundlePath]]];
}

- (void)endLoading{
    [KFProgressHUD hideHUDForView:self.view];
}

#pragma mark  UIWebViewDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self endLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self endLoading];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *requestURL =request.URL;
    if (([[requestURL scheme] isEqualToString: @"http"] || [[ requestURL scheme] isEqualToString: @"https"])
        && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) {
        [[UIApplication sharedApplication] openURL: requestURL];
        return NO;
    }
    return YES;
}

@end
