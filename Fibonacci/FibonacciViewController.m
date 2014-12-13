//
//  FibonacciViewController.m
//  Fibonacci
//
//  Created by Andrey on 12/10/14.
//  Copyright (c) 2014 Andrey. All rights reserved.
//

#import "FibonacciViewController.h"

@interface FibonacciViewController (){
    dispatch_queue_t myQueue;
}


@property NSMutableArray* calculatedFibs;

@end

@implementation FibonacciViewController
//Limit of how many fivonacci results to calculate
int fibonacciToCountAfterIntLimit = 500;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.calculatedFibs = [[NSMutableArray alloc] init];
    
    unsigned long long int prevNum1 = 0, prevNum2 = 1, result;
    NSString *tempString;
    
    BOOL flag = YES;
    tempString = [NSString stringWithFormat: @"%llu", prevNum1];
    [self.calculatedFibs addObject:tempString];
    tempString = [NSString stringWithFormat: @"%llu", prevNum2];
    [self.calculatedFibs addObject:tempString];
    
    //Fibnonacci calculation
    //While in the range of unsigned integer the number of operation that requires to compute
    //Fibonacci number is minimum
    while(flag){
        //check if in the range of Unsigned Long Integer
        if(ULLONG_MAX-prevNum1 < prevNum2){
            flag = false;
        } else {
            result = prevNum1 + prevNum2;
            tempString = [NSString stringWithFormat: @"%llu", result];
            [self.calculatedFibs addObject:tempString];
            prevNum1 = prevNum2;
            prevNum2 = result;
        }
    }
    
    //After exceeding an unsigned ineger range move the computation to the background
    //to make calculaion on the background move the hard computation process on a separate queue
    if (!myQueue) {
        myQueue = dispatch_queue_create("com.svetliy.fibcalc", NULL);
    }
    
    dispatch_async(myQueue, ^{
        NSMutableString *str1 = [NSMutableString stringWithFormat: @"%llu", prevNum1];
        NSMutableString *str2 = [NSMutableString stringWithFormat: @"%llu", prevNum2];
        
        for (int i = 0; i<fibonacciToCountAfterIntLimit; i++) {
            NSString *numString1, *numString2, *numStringResult;
            numString1 = str1;
            numString2 = str2;
            numStringResult = [self sumFirstString:numString1 withSecond:numString2];
            [self.calculatedFibs addObject:numStringResult];
            if (self.tableView.dragging == NO && i>fibonacciToCountAfterIntLimit / 2){
                [self.tableView reloadData];
            }
            [str1 setString:numString2];
            [str2 setString:numStringResult];
        }
    });
    
}

//Put the numer in a string split it by characters and sum up character by character
- (NSString*) sumFirstString:(NSString*) firstString withSecond:(NSString*) secondString {
    
    int firstStringLength = (int)firstString.length;
    int secondStringLength = (int)secondString.length;
    int temp = 0;
    
    
    NSMutableString *finalString = [[NSMutableString alloc] init];
    int sumRemainder = 0;
    NSString *sumResult;
    
    //Second number is always bigger, so we loop till the length of it
    for (int i = 0; i<secondStringLength; i++) {
        NSString *charToInsert;
        temp = sumRemainder + ([secondString characterAtIndex:secondStringLength-1-i] - '0');
        //check if the length of first number is smaller than the second, so we don't go out of bounds
        if (firstStringLength-1-i >= 0){
            temp+= [firstString characterAtIndex:firstStringLength-1-i]-'0';
        }
        sumResult = [NSString stringWithFormat:@"%i", temp];
        
        //check if we have a reminder in the summation
        if (temp >9){
            sumRemainder = (int)([sumResult characterAtIndex:0] - '0');
            charToInsert = [NSString stringWithFormat:@"%c", [sumResult characterAtIndex:1]];
        } else {
            sumRemainder = 0;
            charToInsert = [NSString stringWithFormat:@"%c", [sumResult characterAtIndex:0]];
        }
        //Insert character in the result
        [finalString appendString:charToInsert];
        //check for last character if there is a reminder add it to the number
        if (secondStringLength-1-i == 0 && temp > 9){
            [finalString appendString:[NSString stringWithFormat:@"%i",sumRemainder]];
        }
    }
    NSLog(@"Calculating on the background %@",[self reverseString:finalString]);
    
    return [self reverseString:finalString];
}

//Reverse the string
- (NSString*) reverseString:(NSString*)string{
    int stringLength = (int)string.length;
    NSMutableString *reverseStr = [[NSMutableString alloc] init];
    for (int i=stringLength-1; i>=0; i--) {
        [reverseStr appendString:[NSString stringWithFormat:@"%c",[string characterAtIndex:i]]];
    }
    return reverseStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.calculatedFibs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    //Number in Fibonacci sequence
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
     //Fibonacci Result
    cell.textLabel.text = [self.calculatedFibs objectAtIndex:indexPath.row];
    
    return cell;
}



@end
