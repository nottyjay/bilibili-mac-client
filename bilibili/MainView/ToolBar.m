//
//  ToolBar.m
//  bilibili
//
//  Created by TYPCN on 2015/9/4.
//  Copyright (c) 2015 TYPCN. All rights reserved.
//

#import "ToolBar.h"
#import "Common.hpp"
#import "WebTabView.h"

@interface BLToolBar ()


@end

@implementation BLToolBar

- (void)viewDidLoad {
    [super viewDidLoad];
}


@end


@interface BLToolBarEvents ()

@property (weak) IBOutlet NSTextField *URLInputField;

@end

@implementation BLToolBarEvents

- (id)init{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToolbarURL:) name:@"BLChangeURL" object:nil];
    return self;
}


- (void)finalize {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateToolbarURL:(NSNotification*) aNotification{
    if(aNotification.object){
        NSString *url = aNotification.object;
        if(url && [url length] > 5){
            [self.URLInputField setStringValue:url];
        }
    }else{
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(delayUpdateURL)
                                       userInfo:nil
                                        repeats:NO];
        
    }
}

- (void)delayUpdateURL{
    WebTabView *tc = (WebTabView *)[browser activeTabContents];
    NSString *url = [[tc GetTWebView] getURL];
    if(url && [url length] > 5) {
        [self.URLInputField setStringValue:url];
    }else{
        [self.URLInputField setStringValue:@"invalid"];
    }
}

- (IBAction)OpenURL:(id)sender {
    [sender resignFirstResponder];
    CTTabContents *ct = [browser activeTabContents];
    if(ct) {
        [[browser window] makeFirstResponder:ct.view];
    }
    WebTabView *tc = (WebTabView *)[browser activeTabContents];
    id wv = [tc GetTWebView];
    NSString *url = [self.URLInputField stringValue];
    if([url length] < 3){
        return;
    }else if([url isEqualToString:[wv getURL]]){
        return;
    }else if([url containsString:@"http://"] || [url containsString:@"https://"]){
        [wv setURL:url];
    }else{
        [wv setURL:[NSString stringWithFormat:@"http://%@",url]];
    }
}


- (IBAction)goHome:(id)sender {
    WebTabView *tc = (WebTabView *)[browser activeTabContents];
    [[tc GetTWebView] setURL:@"http://www.bilibili.com"];
}
- (IBAction)Refresh:(id)sender {
    WebTabView *tc = (WebTabView *)[browser activeTabContents];
    NSString *u = [[tc GetTWebView] getURL];
    [[tc GetTWebView] setURL:u];
}
- (IBAction)forward:(id)sender {
    WebTabView *tc = (WebTabView *)[browser activeTabContents];
    [[tc GetTWebView] wgoForward];
}
- (IBAction)backward:(id)sender {
    WebTabView *tc = (WebTabView *)[browser activeTabContents];
    [[tc GetTWebView] wgoBack];
}
- (IBAction)menu:(id)sender {
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    [theMenu setAutoenablesItems:YES];
    [[theMenu addItemWithTitle:NSLocalizedString(@"复制链接",nil) action:@selector(copyLink) keyEquivalent:@""] setTarget:self];
    [[theMenu addItemWithTitle:NSLocalizedString(@"下载管理",nil) action:@selector(dlMan) keyEquivalent:@""] setTarget:self];
    [[theMenu addItemWithTitle:NSLocalizedString(@"发送邮件",nil) action:@selector(contact) keyEquivalent:@""] setTarget:self];
    [[theMenu addItemWithTitle:NSLocalizedString(@"退出",nil) action:@selector(exit) keyEquivalent:@""] setTarget:self];
    [theMenu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

- (void)copyLink{
    WebTabView *tv = (WebTabView *)[browser activeTabContents];
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:[[tv GetTWebView] getURL]  forType:NSStringPboardType];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[tv GetWebView] subviews][0] animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = NSLocalizedString(@"当前页面地址已经复制到剪贴板", nil);
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:3];
}

- (void)dlMan{
    WebTabView *ct = (WebTabView *)[browser createTabBasedOn:nil withUrl:@"http://static.tycdn.net/downloadManager/"];
    [browser addTabContents:ct inForeground:YES];
}

- (void)contact{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:typcncom@gmail.com"]];
}

- (void)exit{
    exit(0);
}

@end