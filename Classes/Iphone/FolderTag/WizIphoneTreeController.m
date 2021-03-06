//
//  WizIphoneTreeController.m
//  Wiz
//
//  Created by wiz on 12-8-28.
//
//

#import "WizIphoneTreeController.h"

#define WizIphoneAddTreeNodeTag    9098
#define WizIphoneDeleteTreeNodeTag  9090

@interface WizIphoneTreeController () <UITextFieldDelegate, UIAlertViewDelegate>
{
    WizTreeRemindView* tableFootRemindView;
}
@property (nonatomic, retain) UIAlertView* inputAlertView;
@end

@implementation WizIphoneTreeController 
@synthesize deleteLastPath;
@synthesize inputAlertView;
- (void) changedAlertRemindText:(NSString*)text
{
    if (nil != self.inputAlertView) {
        if (nil == text) {
            self.inputAlertView.message = [NSString stringWithFormat:@"\n\n\n%@",NSLocalizedString(@"Don't input \\,/,:,<,>,*,?,\",&", nil)];
        }
        else
        {
            self.inputAlertView.message = [NSString stringWithFormat:@"\n\n\n%@",text];
        }
    }
}

- (void) dealloc
{
    [inputAlertView release];
    [deleteLastPath  release];
    [rootTreeNode release];
    [needDisplayTreeNodes release];
    [tableFootRemindView release];
    [super dealloc];
}
- (id) initWithRootTreeNode:(NSString *)nodeKey
{
    self = [super init];
    if (self) {
        TreeNode* folderRootNode = [[TreeNode alloc] init];
        folderRootNode.title   = nodeKey;
        folderRootNode.keyString = nodeKey;
        folderRootNode.isExpanded = YES;
        rootTreeNode = folderRootNode;
        needDisplayTreeNodes = [[NSMutableArray array] retain];
        tableFootRemindView = [[WizTreeRemindView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 100)];
    }
    return self;
}

- (void) reloadAllTreeNodes
{
    
}



- (UIImage*) tableFootRemindImage
{
    return nil;
}
- (NSString*) tableFootRemindString
{
    return nil;
}

- (void) resizeTableFooterRemindView
{
    tableFootRemindView.frame = CGRectMake(0.0, 0.0, 320, [WizGlobals heightForWizTableFooter:[needDisplayTreeNodes count]]);
    
    self.tableView.tableFooterView = tableFootRemindView;
}
- (void) reloadAllData
{
    [self reloadAllTreeNodes];
    [needDisplayTreeNodes removeAllObjects];
    [needDisplayTreeNodes addObjectsFromArray:[rootTreeNode allExpandedChildrenNodes]];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self resizeTableFooterRemindView];
  
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [needDisplayTreeNodes count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WizPadTreeTableCell";
    WizPadTreeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[[WizPadTreeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    TreeNode* node = [needDisplayTreeNodes objectAtIndex:indexPath.row];
    cell.strTreeNodeKey = node.keyString;
    [cell showExpandedIndicatory];
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setNeedsDisplay];
}

- (TreeNode*) findTreeNodeByKey:(NSString*)strKey
{
    return [rootTreeNode childNodeFromKeyString:strKey];
}

- (void) onexpandedRootNode
{
    NSLog(@"%d",rootTreeNode.isExpanded);
    if (rootTreeNode.isExpanded) {
        rootTreeNode.isExpanded = !rootTreeNode.isExpanded;
        [needDisplayTreeNodes removeAllObjects];
        [self.tableView reloadData];
    }
    else
    {
        rootTreeNode.isExpanded = !rootTreeNode.isExpanded;
        [needDisplayTreeNodes removeAllObjects];
        [needDisplayTreeNodes addObjectsFromArray:[rootTreeNode allExpandedChildrenNodes]];
        [self.tableView reloadData];
    }
    ;
}

- (void) onExpandedNode:(TreeNode *)node
{
    NSInteger row = NSNotFound;
    for (int i = 0 ; i < [needDisplayTreeNodes count]; i++) {

        TreeNode* eachNode = [needDisplayTreeNodes objectAtIndex:i];
        if ([eachNode.keyString isEqualToString:node.keyString]) {
            row = i;
            break;
        }
    }
    if(row != NSNotFound)
    {
        [self onExpandNode:node refrenceIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    }
}

- (void) onExpandNode:(TreeNode*)node refrenceIndexPath:(NSIndexPath*)indexPath
{
    
    if (!node.isExpanded) {
        node.isExpanded = YES;
        NSArray* array = [node allExpandedChildrenNodes];
        
        NSInteger startPostion = [needDisplayTreeNodes count] == 0? 0: indexPath.row+1;
        
        NSMutableArray* rows = [NSMutableArray array];
        for (int i = 0; i < [array count]; i++) {
            NSInteger  positionRow = startPostion+ i;
            
            TreeNode* node = [array objectAtIndex:i];
            [needDisplayTreeNodes insertObject:node atIndex:positionRow];
            
            [rows addObject:[NSIndexPath indexPathForRow:positionRow inSection:indexPath.section]];
        }
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else
    {
        node.isExpanded = NO;
        NSMutableArray* deletedIndexPaths = [NSMutableArray array];
        NSMutableArray* deletedNodes = [NSMutableArray array];
        for (int i = indexPath.row; i < [needDisplayTreeNodes count]; i++) {
            TreeNode* displayedNode = [needDisplayTreeNodes objectAtIndex:i];
            if ([node childNodeFromKeyString:displayedNode.keyString]) {
                [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                [deletedNodes addObject:displayedNode];
            }
        }
        
        for (TreeNode* each in deletedNodes) {
            [needDisplayTreeNodes removeObject:each];
        }
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (UIImage*) placeHolderImage
{
    return nil;
}
- (void) showExpandedIndicatory:(WizPadTreeTableCell*)cell
{
    TreeNode* node = [self findTreeNodeByKey:cell.strTreeNodeKey];
    if ([node.childrenNodes count]) {
        if (!node.isExpanded) {
            [cell.expandedButton setImage:[UIImage imageNamed:@"treePhoneItemClosed"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.expandedButton setImage:[UIImage imageNamed:@"treePhoneItemOpened"] forState:UIControlStateNormal];
        }
    }
    else
    {
        [cell.expandedButton setImage:[self placeHolderImage] forState:UIControlStateNormal];
    }
}
- (void) onExpandedNodeByKey:(NSString*)strKey
{
    TreeNode* node = [self findTreeNodeByKey:strKey];
    if (node) {
        [self onExpandedNode:node];
    }
}
- (NSInteger) treeNodeDeep:(NSString*)strKey
{
    TreeNode* node = [self findTreeNodeByKey:strKey];
    return node.deep;
}
- (void) decorateTreeCell:(WizPadTreeTableCell*)cell
{
    
}
- (NSString*) addNodeAlertTitle
{
    return nil;
}

- (NSString*) alertTextfiledPlaceHolder
{
    return nil;
}

- (TreeNode*) createNewTreeNode:(NSString*)title fromeRootNode:(TreeNode*)node
{
    return nil;
}


- (void) doAddTreeNode:(TreeNode*)node title:(NSString*)title
{
    [self onexpandedRootNode];
    TreeNode* newlyNode = [self createNewTreeNode:title fromeRootNode:rootTreeNode];
    if (!newlyNode) {
        return;
    }
    [self onexpandedRootNode];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL hasInvalidCharacter = [string checkHasInvaildCharacters];
    if (hasInvalidCharacter) {
        [self changedAlertRemindText:[WizGlobalError folderInvalidCharacterErrorString:string]];
        return NO;
    }
    else
    {
        [self changedAlertRemindText:nil];
        return YES;
    }
}

- (void) willAddTreeNode
{
    
    NSString* strAlertTitle = [self addNodeAlertTitle];
    NSString* strAlertPlaceHolder = [self alertTextfiledPlaceHolder];
    
    NSInteger nAlertViewTag = WizIphoneAddTreeNodeTag;
    
    
    UIAlertView* prompt = [[UIAlertView alloc] initWithTitle:strAlertTitle
                                                     message:@"\n\n\n\n\n"
                                                    delegate:nil
                                           cancelButtonTitle:WizStrCancel
                                           otherButtonTitles:WizStrOK, nil];
    prompt.tag = nAlertViewTag;
    //
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(27.0, 60.0, 230.0, 30)];
    textField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setPlaceholder:strAlertPlaceHolder];
    [prompt addSubview:textField];
    textField.delegate = self;
    [textField release];
    //
    //
    [prompt setTransform:CGAffineTransformMakeTranslation(0.0, -100.0)];
    prompt.delegate = self;
    [prompt show];
    self.inputAlertView = prompt;
    [self changedAlertRemindText:nil];
    [prompt release];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    tableFootRemindView.imageView.image = [self tableFootRemindImage];
    tableFootRemindView.textLabel.text = [self tableFootRemindString];
    [self reloadAllData];
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(willAddTreeNode)];
    self.navigationItem.rightBarButtonItem = barButton;
    [barButton release];
}
- (void) deleteTreeNodeContentData:(NSString*)key
{
    
}
- (NSString*) deletedAlertTitle
{
    return nil;
}

- (NSString*) deletedAlertMessage:(TreeNode*)node
{
    return nil;
}

- (BOOL) isDeletedVaild:(TreeNode*)node
{
    return NO;
}

- (BOOL) isAddTreeNodeVaild:(NSString*)title
{
    return YES;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        if (WizIphoneDeleteTreeNodeTag == alertView.tag) {
            if (self.deleteLastPath != nil) {
                [self deleteTreeNode:self.deleteLastPath];
                self.deleteLastPath = nil;
            }
        }
        else if (WizIphoneAddTreeNodeTag == alertView.tag )
        {
            NSString* title = WizStrNoTitle;
            for (UIView* each in [alertView subviews]) {
                if ([each isKindOfClass:[UITextField class]]) {
                    UITextField* textField = (UITextField*)each;
                    title = textField.text;
                }
            }
            if (title != nil && ![title isEqualToString:@""] && [self isAddTreeNodeVaild:title]) {
                [self doAddTreeNode:rootTreeNode title:title];
            }
        }
    }
    self.inputAlertView = nil;
}
- (void) willDeleteTreeNode:(NSIndexPath*)indexPath
{
    TreeNode* node = [needDisplayTreeNodes objectAtIndex:indexPath.row];
    
    if (![self isDeletedVaild:node]) {
        [WizGlobals reportWarningWithString:[NSString stringWithFormat:NSLocalizedString(@"Deleting %@ is not allowed!", nil),NSLocalizedString(node.title, nil)]];
        return;
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[self deletedAlertTitle]
                                                    message:[self deletedAlertMessage:node]
                                                   delegate:self cancelButtonTitle:WizStrCancel otherButtonTitles:WizStrDelete, nil];
    alert.tag = WizIphoneDeleteTreeNodeTag;
    [alert show];
    [alert release];
    self.deleteLastPath = indexPath;
}

- (void) deleteTreeNode:(NSIndexPath*)indexPath
{
    TreeNode* node = [needDisplayTreeNodes objectAtIndex:indexPath.row];
    [node.parentTreeNode removeChildTreeNode:node];
    if (node.isExpanded) {
        [self onExpandedNode:node];
    }
    NSArray* tags = [node allChildren];
    for (TreeNode* eachNode in tags) {
        [self deleteTreeNodeContentData:eachNode.keyString];
    }
    [self deleteTreeNodeContentData:node.keyString];
    [needDisplayTreeNodes removeObjectAtIndex:indexPath.row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (indexPath.row > 0) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row -1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
    
    [self resizeTableFooterRemindView];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self willDeleteTreeNode:indexPath];
    }
}

@end
