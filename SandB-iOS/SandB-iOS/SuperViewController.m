//
//  SuperViewController.m
//  SandB-iOS
//
//  Created by Colin Tremblay on 2/8/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import "SuperViewController.h"
#import "ArticleViewController.h"
#import "Reachability.h"
#import "Article.h"
#import "MBProgressHUD.h"
#import "NSString_stripHtml.h"

@interface SuperViewController ()

@end

@implementation SuperViewController{
    NSString *alert;
}

@synthesize cellIdentifier, theTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // custom??
    }
    return self;
}


- (void)loadArticles:(NSString *)url{
    if ([self networkCheck]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            //WE NEED A TRY CATCH BLOCK AROUND ALL OF THIS (I THINK)
            
            //Get the XML data
            NSData *xmlData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
            NSError *err;
            tbxml = [[TBXML alloc] initWithXMLData:xmlData error:&err];
            
            articleArray = [[NSMutableArray alloc] init];
            // Obtain root element
            TBXMLElement * root = tbxml.rootXMLElement;
            if (root)
            {
                TBXMLElement * elem_NEWroot = [TBXML childElementNamed:@"channel" parentElement:root];
                TBXMLElement * elem_ARTICLE = [TBXML childElementNamed:@"item" parentElement:elem_NEWroot];
                while (elem_ARTICLE !=nil)
                {
                    TBXMLElement * elem_TITLE = [TBXML childElementNamed:@"title" parentElement:elem_ARTICLE];
                    TBXMLElement * elem_TEXT = [TBXML childElementNamed:@"content:encoded" parentElement:elem_ARTICLE];
                    Article * art = [[Article alloc] init];
                    NSString *articleTitle = [TBXML textForElement:elem_TITLE];
                    NSString *articleBody = [TBXML textForElement:elem_TEXT];
                    
                    
                    /*
                    // TODO - Refactor this!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"<em>" withString:@""];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"&#8230" withString:@"... "];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"&#8220" withString:@"\""];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"&#8221" withString:@"\""];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"&#8217;" withString:@"'"];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"&#8211;" withString:@"-"];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"&#038;" withString:@"&"];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"&#215;" withString:@"x"];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"&#60;" withString:@"<"];
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                    articleTitle = [articleTitle stringByReplacingOccurrencesOfString:@"&#8230" withString:@"... "];
                    articleTitle = [articleTitle stringByReplacingOccurrencesOfString:@"&#8217;" withString:@"'"];
                    articleTitle = [articleTitle stringByReplacingOccurrencesOfString:@"&#038;" withString:@"&"];
                    articleTitle = [articleTitle stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
                    articleTitle = [articleTitle stringByReplacingOccurrencesOfString:@"&#8211;" withString:@"-"];
                    articleTitle = [articleTitle stringByReplacingOccurrencesOfString:@"&#215;" withString:@"x"];
                    articleTitle = [articleTitle stringByReplacingOccurrencesOfString:@"&#8220" withString:@"\""];
                    articleTitle = [articleTitle stringByReplacingOccurrencesOfString:@"&#8221" withString:@"\""];
                    */
                    articleBody = [articleBody stringByReplacingOccurrencesOfString:@"<p>&nbsp;</p>\n" withString:@""];
                    
                    art.title = [articleTitle stripHtml];
                    art.article = [articleBody stripHtml];
                   // art.article = [art.article stringByReplacingOccurrencesOfString:@"\n\n" withString:@""];
                    //art.article = [art.article stringByReplacingOccurrencesOfString:@".edu" withString:@".edu\n"];

                    art.article = [art.article stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\n"];

                    [articleArray addObject:art];
                    elem_ARTICLE = [TBXML nextSiblingNamed:@"item" searchFromElement:elem_ARTICLE];
                    
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [theTableView reloadData];
            });
        });
    }
    else {
        //Network Check Failed - Show Alert ( We could use the MBProgessHUD for this as well - Like in the Google Plus iPhone app)
        [self performSelectorOnMainThread:@selector(showNoNetworkAlert) withObject:nil waitUntilDone:YES];
        return;
    }
}
- (void)showNoNetworkAlert {
    UIAlertView *network = [[UIAlertView alloc]
                            initWithTitle:@"No Network Connection"
                            message:@"Turn on cellular data or use Wi-Fi to access new data from the server"                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil
                            ];
    
    [network show];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Rename the back button on the child views
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    self.cellIdentifier = @"NewsCell";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    // self.title = @"Scarlet and Black";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Method to determine the availability of network Connections using the Reachability Class
- (BOOL)networkCheck {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return (!(networkStatus == NotReachable));
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
    return articleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Register the NIB cell object
    [tableView registerNib:[UINib nibWithNibName:@"NewsCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
	}
    UILabel *newsTitle = (UILabel *)[cell viewWithTag:1001];
    UIImageView *newsImage = (UIImageView *)[cell viewWithTag:1002];
    UILabel *newsArticle = (UILabel *)[cell viewWithTag:1003];
    Article *currentArticle = [[Article alloc] init];
    currentArticle = [articleArray objectAtIndex:indexPath.row];
    
    newsTitle.text = currentArticle.title;
    NSString *newBody = [[NSString alloc] initWithString:currentArticle.article];

    newBody = ReplaceFirstNewLine(currentArticle.article);
    NSRange foundRange = [newBody rangeOfString:@"\n"];
    if (foundRange.location == 0)
        newBody = [newBody stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    
    newsArticle.text = newBody;

    
    [newsImage setImage:[UIImage imageNamed:@"newspaper"]];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 122;
    //    return [indexPath row] * 20;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // TODO - Set this based on URL
    return @"Newest Stories";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ArticleViewController *articlePage = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:nil];
    articlePage.article = [[Article alloc] init];
    articlePage.article = [articleArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:articlePage animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


NSString * ReplaceFirstNewLine(NSString * original) {
    NSMutableString * newString = [NSMutableString stringWithString:original];
    NSRange foundRange = [original rangeOfString:@"\n"];
    NSRange newRange = foundRange;
    newRange.length = foundRange.location + 2;
    newRange.location = 0;
    
    if (foundRange.location != NSNotFound) {
        [newString replaceCharactersInRange:newRange
                                 withString:@""];
    }
    return newString;
}

#pragma mark UIAlertViewDelegate Methods
// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    return;
}

@end


