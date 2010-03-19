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
	var i     = 3,
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
	var i     = 3,
    var array = [[CPArray alloc] init]
    var argument
 
    for(; i < arguments.length && (argument = arguments[i]) != nil; ++i)
         array.push(argument)
    
     returnObject = array
  }

  [self storeUrl:url method:"POST" returns:returnObject];
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
    return [anObject toJSON]		
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
    var fixtures = [CRFixtureFactory sharedCRFixtureFactory];
    var url      = [aRequest URL];
    var method   = [aRequest HTTPMethod];
    var response = [fixtures findByUrl:url method:method]

    // CPLog(method + " " + url)
    // CPLog("response " + response)
    
    if(response){
      return [CPArray arrayWithObjects:200,response];      
    }else{
      return [CPArray arrayWithObjects:500,nil];      
    }
}

@end

@implementation CPArray (JSON)

-(CPString)toJSON {
  var stringArray = [CPArray array];
  for (var i = 0; i < [self count]; i++) {
    [stringArray addObject:[[self objectAtIndex:i] toJSON]];
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

