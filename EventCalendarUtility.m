//
//  EventCalendarUtility.m
//  test
//
//  Created by Minesh Purohit on 29/07/14.
//  Copyright (c) 2014 Triforce Inc. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "EventCalendarUtility.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@implementation EventCalendarUtility

#pragma mark Add Event In Calender


-(void)addEventInCalender:(id)infoObject {
    
	EKEventStore *eventDB = [[EKEventStore alloc] init];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [eventDB requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                [self addEventWIthEKTaskStore:eventDB withTask:infoObject];
            }
        }];
    } else {
        [self addEventWIthEKTaskStore:eventDB withTask:infoObject];
    }
    
}

- (void) addEventWIthEKTaskStore:(EKEventStore *) eventDB withTask:(id) tempObject
{
    EKEvent *myEvent  = [EKEvent eventWithEventStore:eventDB];
    
    myEvent.title     = [tempObject valueForKey:@"strSubject"];
    myEvent.startDate = [self getDateFromString:[NSString stringWithFormat:@"%@ 00:01",[tempObject valueForKey:@"strStartDate"]]];
    myEvent.endDate   = [self getDateFromString:[NSString stringWithFormat:@"%@ 23:59",[tempObject valueForKey:@"strEndDate"]]];
    myEvent.allDay = NO;
    //    myEvent.location = @"";
    myEvent.notes = @"Remember Me!";
    
    EKAlarm * alarm = [EKAlarm alarmWithAbsoluteDate:[self getDateFromString:[NSString stringWithFormat:@"%@ 00:01",[tempObject valueForKey:@"strStartDate"]]]];
    NSArray *alarmTime = [@"00:01" componentsSeparatedByString:@":"];
    if ([alarmTime count] > 1) {
        alarm.relativeOffset = -(([[alarmTime objectAtIndex:0] intValue]*60*60)+([[alarmTime objectAtIndex:1] intValue]*60));
    } else {
        alarm.relativeOffset = -(5*60);
    }
    [myEvent addAlarm:alarm];
    
    [myEvent setCalendar:[eventDB defaultCalendarForNewEvents]];
    
    NSError *err;
    [eventDB saveEvent:myEvent span:EKSpanThisEvent error:&err];
    
    if (err == noErr) {
        NSLog(@"Add Success");
        NSUserDefaults * perfs = [NSUserDefaults standardUserDefaults];
        NSString * taskKey = [NSString stringWithFormat:@"task%@",[tempObject valueForKey:@"strCreatedTimeStamp"]];
        [perfs setObject:myEvent.eventIdentifier forKey:taskKey];
        [perfs synchronize];
    }else {
        NSLog(@"Add Failed");
    }
}


#pragma mark Update Event In Calender

-(void)updateEventInCalender:(id)infoObject {
    
	EKEventStore *eventDB = [[EKEventStore alloc] init];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [eventDB requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                [self updateEventWithEKTaskStore:eventDB withTask:infoObject];
            }
        }];
    } else {
        [self updateEventWithEKTaskStore:eventDB withTask:infoObject];
    }
}

- (void) updateEventWithEKTaskStore:(EKEventStore *) eventDB withTask:(id) tempObject {
    
    BOOL isUpdate = NO;
    
    NSUserDefaults * perfs = [NSUserDefaults standardUserDefaults];
    
    NSString * taskKey = [NSString stringWithFormat:@"task%@",[tempObject valueForKey:@"strCreatedTimeStamp"]];
    EKEvent * event = [eventDB eventWithIdentifier:[perfs valueForKey:taskKey]];
    event.title     = [tempObject valueForKey:@"strSubject"];
    event.startDate = [self getDateFromString:[NSString stringWithFormat:@"%@ 00:01",[tempObject valueForKey:@"strStartDate"]]];
    event.endDate   = [self getDateFromString:[NSString stringWithFormat:@"%@ 23:59",[tempObject valueForKey:@"strEndDate"]]];
    event.allDay = NO;
    event.notes = @"Remember Me!";
    
    for (EKAlarm * alarm in event.alarms) {
        [event removeAlarm:alarm];
    }
    
    EKAlarm * alarm = [EKAlarm alarmWithAbsoluteDate:[self getDateFromString:[NSString stringWithFormat:@"%@ 00:01",[tempObject valueForKey:@"strStartDate"]]]];
    NSArray *alarmTime = [@"00:01" componentsSeparatedByString:@":"];
    if ([alarmTime count] > 1) {
        alarm.relativeOffset = -(([[alarmTime objectAtIndex:0] intValue]*60*60)+([[alarmTime objectAtIndex:1] intValue]*60));
    } else {
        alarm.relativeOffset = -(5*60);
    }
    [event addAlarm:alarm];
    
    [event setCalendar:[eventDB defaultCalendarForNewEvents]];
    
    NSError *err;
    [eventDB saveEvent:event span:EKSpanThisEvent error:&err];
    
    if (err == noErr) {
        NSLog(@"Update Success");
        isUpdate = TRUE;
    }else {
        NSLog(@"Update Failed");
    }
    
	if (!isUpdate)
    {
		EKEvent *myEvent  = [EKEvent eventWithEventStore:eventDB];
        
		myEvent.title     = [tempObject valueForKey:@"strSubject"];
		myEvent.startDate = [self getDateFromString:[NSString stringWithFormat:@"%@ 00:01",[tempObject valueForKey:@"strStartDate"]]];
		myEvent.endDate   = [self getDateFromString:[NSString stringWithFormat:@"%@ 23:59",[tempObject valueForKey:@"strEndDate"]]];
		myEvent.allDay = NO;
//		myEvent.location = @"";
		myEvent.notes = @"Remember Me!";
        
		[myEvent setCalendar:[eventDB defaultCalendarForNewEvents]];
        
		NSError *err;
		[eventDB saveEvent:myEvent span:EKSpanThisEvent error:&err];
        
		if (err == noErr) {
			NSLog(@"Add Success");
            NSUserDefaults * perfs = [NSUserDefaults standardUserDefaults];
            NSString * taskKey = [NSString stringWithFormat:@"task%@",[tempObject valueForKey:@"strCreatedTimeStamp"]];
            [perfs setObject:myEvent.eventIdentifier forKey:taskKey];
            [perfs synchronize];
		} else {
			NSLog(@"Add Failed");
		}
        
	}
}

#pragma mark - Date Methods

- (NSDate *) getDateFromString:(NSString *) datestring
{

	// Convert string to date object
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
	NSDate *date = [dateFormatter dateFromString:datestring];
	[dateFormatter release];
	
	return date;
	
}

- (NSString *) getStringFromDate:(NSDate *) date withFormate:(NSString *) format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString * dateString = [formatter stringFromDate:date];
    [formatter release];
    return dateString;
}

- (NSDate *) getDateFromString:(NSString *) string withFormate:(NSString *) format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate * date = [formatter dateFromString:string];
    [formatter release];
    return date;
}


- (NSDate *) getEndDateFromStartDate:(NSString *) startDate withStartTime:(NSString *) startTime AndEndTime:(NSString *) endTime {
	
	NSString * startingDateTime = [NSString stringWithFormat:@"%@ %@",startDate,startTime];
	NSString * endingDateTime = [NSString stringWithFormat:@"%@ %@",startDate,endTime];
	
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"MM/dd/yyyy HH:mm"];
	NSDate *startingDate = [df dateFromString:startingDateTime];
    NSDate *endingDate = [df dateFromString:endingDateTime];
	[df release];
	
    NSComparisonResult result;
    result = [startingDate compare:endingDate];
	
    if(result == NSOrderedDescending)
    {
        endingDate = [endingDate dateByAddingTimeInterval:60*60*24];
    }
	
	return endingDate;
	
}

#pragma mark -


@end
