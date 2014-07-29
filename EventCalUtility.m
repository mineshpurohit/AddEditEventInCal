
#pragma mark Add Event In Calender


-(void)addEventInCalender:(id)infoObject {
    
	Task * tempObject = (Task *)infoObject;
	
	EKEventStore *eventDB = [[EKEventStore alloc] init];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [eventDB requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                [self addEventWIthEKTaskStore:eventDB withTask:tempObject];
            }
        }];
    } else {
        [self addEventWIthEKTaskStore:eventDB withTask:tempObject];
    }
	
}

- (void) addEventWIthEKTaskStore:(EKEventStore *) eventDB withTask:(Task *) tempObject
{
    EKEvent *myEvent  = [EKEvent eventWithEventStore:eventDB];
    
    myEvent.title     = tempObject.strSubject;
    myEvent.startDate = [appDelegate getDateFromString:[NSString stringWithFormat:@"%@ 00:01",tempObject.strStartDate]];
    myEvent.endDate   = [appDelegate getDateFromString:[NSString stringWithFormat:@"%@ 23:59",tempObject.strEndDate]];
    myEvent.allDay = NO;
//    myEvent.location = @"";
    myEvent.notes = @"Remember Me!";
    
    EKAlarm * alarm = [EKAlarm alarmWithAbsoluteDate:[appDelegate getDateFromString:[NSString stringWithFormat:@"%@ 00:01",tempObject.strStartDate]]];
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
    //NSLog(@"%@",myEvent.eventIdentifier);
    
    if (err == noErr) {
        // NSLog(@"Add Success");
         NSUserDefaults * perfs = [NSUserDefaults standardUserDefaults];
        NSString * taskKey = [NSString stringWithFormat:@"task%@",[self.objTask strCreatedTimeStamp]];
        [perfs setObject:myEvent.eventIdentifier forKey:taskKey];
        [perfs synchronize];
    }else {
        // NSLog(@"Add Failed");
    }
}


#pragma mark Update Event In Calender

-(void)updateEventInCalender:(id)infoObject {
	
	Task * tempObject = (Task *) infoObject;
	
	EKEventStore *eventDB = [[EKEventStore alloc] init];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [eventDB requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                [self updateEventWithEKTaskStore:eventDB withTask:tempObject];
            }
        }];
    } else {
        [self updateEventWithEKTaskStore:eventDB withTask:tempObject];
    }
}

- (void) updateEventWithEKTaskStore:(EKEventStore *) eventDB withTask:(Task *) tempObject {
    
    BOOL isUpdate = NO;
    
    NSUserDefaults * perfs = [NSUserDefaults standardUserDefaults];
    
    NSString * taskKey = [NSString stringWithFormat:@"task%@",[self.objTask strCreatedTimeStamp]];
    EKEvent * event = [eventDB eventWithIdentifier:[perfs valueForKey:taskKey]];
    event.title     = tempObject.strSubject;
    event.startDate = [appDelegate getDateFromString:[NSString stringWithFormat:@"%@ 00:01",tempObject.strStartDate]];
    event.endDate   = [appDelegate getDateFromString:[NSString stringWithFormat:@"%@ 23:59",tempObject.strEndDate]];
    event.allDay = NO;
    event.notes = @"Remember Me!";
    
    for (EKAlarm * alarm in event.alarms) {
        [event removeAlarm:alarm];
    }
    
    EKAlarm * alarm = [EKAlarm alarmWithAbsoluteDate:[appDelegate getDateFromString:[NSString stringWithFormat:@"%@ 00:01",tempObject.strStartDate]]];
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
		
		myEvent.title     = tempObject.strSubject;
		myEvent.startDate = [appDelegate getDateFromString:[NSString stringWithFormat:@"%@ 00:01",tempObject.strStartDate]];
		myEvent.endDate   = [appDelegate getDateFromString:[NSString stringWithFormat:@"%@ 23:59",tempObject.strEndDate]];
		myEvent.allDay = NO;
//		myEvent.location = @"";
		myEvent.notes = @"Remember Me!";
		
		[myEvent setCalendar:[eventDB defaultCalendarForNewEvents]];
		
		NSError *err;
		[eventDB saveEvent:myEvent span:EKSpanThisEvent error:&err];
		
		if (err == noErr) {
			//NSLog(@"Add Success");
            NSUserDefaults * perfs = [NSUserDefaults standardUserDefaults];
            NSString * taskKey = [NSString stringWithFormat:@"task%@",[self.objTask strCreatedTimeStamp]];
            [perfs setObject:myEvent.eventIdentifier forKey:taskKey];
            [perfs synchronize];
		} else {
			//NSLog(@"Add Failed");
		}
		
	}
}

#pragma mark -
