//
//  KFDocumentViewController.m
//  Pods
//
//  Created by admin on 16/10/12.
//
//

#import "KFDocumentViewController.h"

#import  <KF5SDK/KFHttpTool.h>
#import "UITableView+KFRefresh.h"
#import "KFHelper.h"
#import "KFDocument.h"
#import "KFProgressHUD.h"
#import "KFUserManager.h"

@interface KFDocumentViewController ()<UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;

@end

@implementation KFDocumentViewController

- (void)loadView{
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, KF5SCREEN_WIDTH, KF5SCREEN_HEIGHT)];
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
    webView.delegate = self;

    self.webView = webView;
    self.view = webView;
}

- (instancetype)initWithPost:(KFDocItem *)post{
    self = [super init];
    if (self) {
        _post = post;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title.length) {
        if (self.post)self.title = self.post.title;
    }
        
    [KFProgressHUD showDefaultLoadingTo:self.view];
    
    [self reloadData];
}



- (void)reloadData{
    
    NSDictionary *params =
    @{
      KF5UserToken:[KFUserManager shareUserManager].user.userToken?:@"",
      KF5PostId:@(self.post.Id)
      };
    
    __weak typeof(self)weakSelf = self;
    [KFHttpTool getDocumentWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        if (!error) {
            KFDocument *document = [KFDocument documentWithDict:[result kf5_dictionaryForKeyPath:@"data.post"]];
            //progress在webView的代理中隐藏
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf refreshWithDocument:document];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf endLoading];
                [[[UIAlertView alloc]initWithTitle:KF5Localized(@"kf5_reminder") message:error.localizedDescription delegate:nil cancelButtonTitle:KF5Localized(@"kf5_confirm") otherButtonTitles:nil, nil]show];
            });
        }
    }];
}

- (void)refreshWithDocument:(KFDocument *)document{
    
    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html>\n"
                      "<html>\n"
                      "<head>\n"
                      "<meta content=\"user-scalable=no,width=device-width, initial-scale=1\" name=\"viewport\">\n"
                      "<title></title>\n"
                      "<meta charset=\"utf-8\" />\n"
                      "<link rel=\"stylesheet\" href = \"%@\" type=\"text/css\"/>"
                      "<link rel=\"stylesheet\" href = \"%@\" type=\"text/css\"/>"
                      "</head>\n"
                      "<body>\n"
                      "<body><article>\n"
                      "<div class=\"title\">%@</div>\n"
                      "<div class=\"content\">%@</div>\n"
                      "<div class=\"datetime\">%@</div>\n"
                      "</article>\n"
                      "</body>\n"
                      "</html>",KF5SrcName(@"KFBaseDocument.css"),KF5SrcName(@"KFUserDocument.css"),document.title,document.content,[[NSDate dateWithTimeIntervalSince1970:document.created_at] kf5_string]];
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
