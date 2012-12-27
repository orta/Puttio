//
//  ORTorrentBrowserViewController.m
//  Puttio
//
//  Created by orta therox on 02/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORTorrentBrowserViewController.h"
#import "ModalZoomView.h"
#import "ORAddTorrentFromBrowseViewController.h"
#import "WEPopoverController.h"
#import "ORBookmarksViewController.h"

@interface ORTorrentBrowserViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *addressTextfield;
@property (strong) WEPopoverController *bookmarksPopover;
@end

@implementation ORTorrentBrowserViewController

- (IBAction)showBookmarksPopover:(UIButton *)sender {
    ORBookmarksViewController *controller = [[ORBookmarksViewController alloc] initWithStyle:UITableViewStylePlain];
    
    _bookmarksPopover = [[WEPopoverController alloc] initWithContentViewController:controller];
    controller.container = _bookmarksPopover;
    controller.delegate = self;
    
    UINavigationController *rootController = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    CGRect position = [rootController.view convertRect:sender.frame fromView:self.view];
    [_bookmarksPopover presentPopoverFromRect:position inView:rootController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    _titleLabel.text = @"";
    _webView.delegate = self;

    NSString *lastAddress = [[NSUserDefaults standardUserDefaults] objectForKey:ORLastSiteVisitedDefault];
    if (!lastAddress || [lastAddress isEqualToString:@""]) {
        lastAddress = @"http://www.duckduckgo.com";
    }

    _addressTextfield.text = lastAddress;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:lastAddress]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *address = request.URL.absoluteString;
    
    if ([address rangeOfString:@"rotator"].location != NSNotFound) {
        return NO;
    }

    if ([address rangeOfString:@".torrent"].location != NSNotFound || [address rangeOfString:@"magnet:"].location != NSNotFound) {
        ORAddTorrentFromBrowseViewController *controller = (ORAddTorrentFromBrowseViewController *)[ModalZoomView showWithViewControllerIdentifier:@"AddTorrentFromBrowseView"];
        controller.address = address;
        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
 	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSString *address = webView.request.URL.absoluteString;
    _addressTextfield.text = address;

    [[NSUserDefaults standardUserDefaults] setObject:address forKey:ORLastSiteVisitedDefault];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
 	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    _titleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (IBAction)exitTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonPressed:(id)sender {
    [_webView goBack];
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setWebView:nil];
    [self setAddressTextfield:nil];
    [self setBookmarksPopover:nil];
    [super viewDidUnload];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = @"";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *address = textField.text;

    if ([address isEqualToString:@"about:blank"]) {
        address = @"http://duckduckgo.com";
    }
    
    if ([address rangeOfString:@"."].location == NSNotFound) {
        address = [NSString stringWithFormat:@"https://duckduckgo.com/?q=%@", address];
    }

    if (![address hasPrefix:@"http://"] && ![address hasPrefix:@"https://"] ) {
        address = [NSString stringWithFormat:@"http://%@", address];
    }

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:address]]];
    [textField resignFirstResponder];
    return YES;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [UIDevice isPad];
}

#pragma mark -
#pragma mark Bookmarks Delegate

- (NSString *)name {
    return [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (NSString *)url {
    return _addressTextfield.text;
}

- (void)setURL:(NSString *)url {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [_bookmarksPopover dismissPopoverAnimated:YES];
}

@end
