@import "TestHelper.j"

@implementation CRFixtureFactoryTest : OJTestCase
- (void)setUp
{
   [super setUp]

   user1    = [User new:{'id':1}]
   user2    = [User new:{'id':2}]

   fixtures = [[CRFixtureFactory alloc] init]
}

- (void)tearDown
{
  [fixtures reset]
}

- (void)test_get_with_resource {
  [fixtures get:"/foo" returns:user1]

  var result =   [fixtures findByUrl:"/foo"  method:"GET"]
  [self assert:[user1 toJSON] equals:result];
  
}

- (void)test_post_with_resource {
  [fixtures post:"/foo" returns:user1]

  var result =   [fixtures findByUrl:"/foo"  method:"POST"]
  [self assert:[user1 toJSON] equals:result];
}

- (void)test_post_with_array {
  [fixtures post:"/foo" returns:user1,user2]

  var result =   [fixtures findByUrl:"/foo"  method:"POST"]
  alert(result)
  var expected = "[" + [user1 toJSON] + "," + [user2 toJSON] + ']' 
  [self assert:expected equals:result];
}

- (void)test_get_with_array {
  [fixtures get:"/foo" returns:user1,user2]

  var result =   [fixtures findByUrl:"/foo"  method:"GET"]
  alert(result)
  var expected = "[" + [user1 toJSON] + "," + [user2 toJSON] + ']' 
  [self assert:expected equals:result];
}

- (void)test_reset {
}

@end