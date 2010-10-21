fixtures = nil;
@implementation CRFixtureFactory : CPObject {
  CPDictionary fixtureData @accessors;
}

-(id)init {
  self = [super init];
  if (self) {
	[self reset]
  }
  return self
}

//override this
-(void)generateFixtures {
}

-(void)reset {
  fixtureData = [[CPDictionary alloc] init];  
  [self generateFixtures]    
}

-(CPString)findByUrl:(CPString)url method:(CPString)method {
  var key = method + url
  // CPLog("finding " + key)
  var returnValue = [fixtureData valueForKey:key]
  // CPLog("found " + returnValue)
  return returnValue
}

-(void)get:(CPString)url returns:(id)returnObject,... {
  if(arguments.length > 4){
	  var i     = 3
    var array = [[CPArray alloc] init]
    var argument

    for(; i < arguments.length && (argument = arguments[i]) != nil; ++i)
         array.push(argument)

     returnObject = array
  }

  [self storeUrl:url method:"GET" returns:returnObject];
}

-(void)post:(CPString)url returns:(id)returnObject,... {
  if(arguments.length > 4){
	  var i     = 3
    var array = [[CPArray alloc] init]
    var argument
 
    for(; i < arguments.length && (argument = arguments[i]) != nil; ++i)
         array.push(argument)
    
     returnObject = array
  }

  [self storeUrl:url method:"POST" returns:returnObject];
}

-(void)delete:(CPString)url returns:(id)returnObject,... {
  if(arguments.length > 4){
	  var i     = 3
    var array = [[CPArray alloc] init]
    var argument
 
    for(; i < arguments.length && (argument = arguments[i]) != nil; ++i)
         array.push(argument)
    
     returnObject = array
  }

  [self storeUrl:url method:"DELETE" returns:returnObject];
}

// "private"
-(void)storeUrl:(CPString)url method:method returns:(id)returnObject {	

  var key = method + url
  [fixtureData setValue:[self storableValueFor:returnObject] forKey:key];	
}

-(CPString)storableValueFor:(id)anObject {
  if([anObject className] == 'CPString'){
    return anObject
  }else{
    return [anObject toFlatJSON]		
  }
}

+ (CRFixtureFactory)sharedCRFixtureFactory {
  if (!fixtures){
    fixtures = [[CRFixtureFactory alloc] init]
  } 
  return fixtures;
} 

@end

@implementation CPURLConnection (CRFixtureFactory)

+ (CPArray)sendSynchronousRequest:(CPURLRequest)aRequest
{
    CPLog("sendSynchronousRequest")
    var fixtures = [CRFixtureFactory sharedCRFixtureFactory];
    var url      = [aRequest URL];
    var method   = [aRequest HTTPMethod];

    CPLog(method + " " + url)

    var response = [fixtures findByUrl:url method:method]

    CPLog("response " + response)
    
    if(response){
      return [CPArray arrayWithObjects:200,response];      
    }else{
      return [CPArray arrayWithObjects:500,nil];      
    }
}

@end

@implementation CPArray (JSON)

-(CPString)toFlatJSON {
  var stringArray = [CPArray array];
  for (var i = 0; i < [self count]; i++) {
    [stringArray addObject:[[self objectAtIndex:i] toFlatJSON]];
  }
  return "[" + [stringArray componentsJoinedByString:","] + "]"
}

@end

//todo remove
@implementation CPDictionary (JSON)

- (void)setValueAsJSON:(id)anObject forKey:(CPString)aKey {
  var asJson = [anObject toJSON]
  [self setValue:asJson forKey:aKey];
}

@end

