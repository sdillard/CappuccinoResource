@import <Foundation/CPDate.j>
@import <Foundation/CPString.j>
@import <Foundation/CPURLConnection.j>
@import <Foundation/CPURLRequest.j>

@implementation CPDate (CRSupport)

+ (CPDate)dateWithDateString:(CPString)aDate
{
    return [[self alloc] initWithString:aDate + " 12:00:00 +0000"];
}

+ (CPDate)dateWithDateTimeString:(CPString)aDateTime
{
    var format = /^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})Z$/,
        d      = aDateTime.match(new RegExp(format)),
        string = d[1] + " " + d[2] + " +0000";

    return [[self alloc] initWithString:string];
}

- (int)year
{
    return self.getFullYear();
}

- (int)month
{
    return self.getMonth() + 1;
}

- (int)day
{
    return self.getDate();
}

- (CPString)toDateString
{
    return [CPString stringWithFormat:@"%04d-%02d-%02d", [self year], [self month], [self day]];
}


@end

@implementation CPString (CRSupport)

+ (CPString)paramaterStringFromJSON:(JSObject)params
{
    paramsArray = [CPArray array];

    for (var param in params) {
        [paramsArray addObject:(escape(param) + "=" + escape(params[param]))];
    }

    return paramsArray.join("&");
}

+ (CPString)paramaterStringFromCPDictionary:(CPDictionary)params
{
    var paramsArray = [CPArray array],
        keys        = [params allKeys];

    for (var i = 0; i < [params count]; ++i) {
        [paramsArray addObject:(escape(keys[i]) + "=" + escape([params valueForKey:keys[i]]))];
    }

    return paramsArray.join("&");
}

/* Rails expects strings to be lowercase and underscored.
 * eg - user_session, movie_title, created_at, etc.
 * Always use this format when sending data to Rails
*/
- (CPString)railsifiedString
{
    var str=self;
    var str_path=str.split('::');
    var upCase=new RegExp('([ABCDEFGHIJKLMNOPQRSTUVWXYZ])','g');
    var fb=new RegExp('^_');
    for(var i=0;i<str_path.length;i++)
      str_path[i]=str_path[i].replace(upCase,'_$1').replace(fb,'');
    str=str_path.join('/').toLowerCase();

    return str;
}

- (CPString)camelcaseUnderscores
{
    var array  = self.split('_');
    for (var x = 1; x < array.length; x++) // skip first word
        array[x] = array[x].charAt(0).toUpperCase() +array[x].substring(1);
    var string = array.join('');

    return string;
}

- (CPString)classifiedString
{
    var string = [self camelcaseUnderscores]
    var stripS  = new RegExp('s$');
   
    var newStr = string.replace(stripS,'');
    return newStr.charAt(0).toUpperCase() + newStr.substring(1);
}

/*
 * Cappuccino expects strings to be camelized with a lowercased first letter.
 * eg - userSession, movieTitle, createdAt, etc.
 * Always use this format when declaring ivars.
*/
- (CPString)cappifiedString
{
    var string = [self camelcaseUnderscores]
    return string.charAt(0).toLowerCase() + string.substring(1);
}

- (JSObject)toJSON
{
    var str=self;
    try {
        var obj = JSON.parse(str);
    }
    catch (anException) {
        CPLog.warn(@"Could not convert to JSON: " + str);
    }

    if (obj) {
        return obj;
    }
}

@end

@implementation CPURLConnection (CRSupport)

//TODO replace, this method should not be used per boucher
+ (CPArray)sendSynchronousRequest:(CPURLRequest)aRequest
{
	  CPLog("sending request " + [aRequest HTTPMethod] + " " + [aRequest URL])
    var response = [CPURLConnection sendSynchronousRequest: aRequest returningResponse: nil]
    CPLog("got " + [response rawString] )
    return [CPArray arrayWithObjects:200, [response rawString]]
}

@end

@implementation CPURLRequest (CRSupport)

+ (id)requestJSONWithURL:(CPURL)aURL
{
    var request = [self requestWithURL:aURL];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    return request;
}

@end
