# CappuccinoResource #

Cappuccino on Rails. CappuccinoResource (CR) is like ActiveResource for your Cappuccino project!

## Installation ##

Install with ease using the [Narwhal](http://narwhaljs.org/) package manager

    tusk update && tusk install CappuccinoResource

Once that completes, you can simply `@import` it into your project

    @import <CappuccinoResource/CRBase.j>

Optionally, install manually by copying /Framework/CappuccinoResource/*.j into your project and `@import` CRBase.j where needed

        @import "CRBase.j"


## Usage ##

There is now an open-source demo application demonstrating basic usage. The demo is available [on Heroku](http://capp-resource-example.heroku.com), and the source is available [on GitHub](http://github.com/sant0sk1/CappResourceExample). For more detailed instructions, read on.

### In Rails ###

Make sure your RESTful controllers render json. You can take or leave the `respond_to` block depending on your needs.

Rails 2 Example:

    class PostsController < ApplicationController

      def index
        @posts = Post.all

        respond_to do |format|
          format.html
          format.json { render :json => @posts }
        end
      end

      # other actions ...
    end

Rails 3 Example:

    class PostsController < ApplicationController
      respond_to :html, :json

      def index
        @posts = Post.all
        respond_with(@posts)
      end

      # other actions ...
    end

### In Capp ###

Create a class which inherits from CR:

    @implementation Post : CappuccinoResource
    {
        CPString title        @accessors;
        CPString body         @accessors;
        CPDate   publishedOn;
        BOOL     isViewable;
    }

    - (JSObject)attributes
    {
        return {
          "post": {
            "title":title,
            "body":body,
            "published_on":[publishedOn toDateString],
            "is_viewable":isViewable
          }
        };
    }

The `attributes` instance method MUST be declared in your class for it to save properly.

CR performs naïve class pluralization (it just adds an "s"). If your class name has a more complex inflection, you can simply override the `resourcePath` class method. For instance, a `Person` class:

    @implementation Person : CappuccinoResource
    {
        CPString name;
    }

    + (CPURL)resourcePath
    {
        return [CPURL URLWithString:@"/people"];
    }

    - (JSObject)attributes
    {
        return {"person":{"name":name}};
    }

    @end

Using your new class should feel familiar to Rails devs.

### CRUD ###

Instantiate a blank Post object

    var post = [Post new];

Optionally declare attributes at the same time. JSON feels like Ruby hashes!

    var post = [Post new:{"title":"First Post!","body":"Lorem and stuff"}];

Just like in ActiveResource, create = new + save

    var post = [Post create:{"title":"First Post!","body":"Lorem and stuff"}];

Get all the posts from Rails

    var posts = [Post all];
    [posts class]; // CPArray
    [[posts objectAtIndex:0] class]; // Post

You can fetch a resource with its identifier...

    var post = [Post find:@"4"];

Change its title...

    [post setTitle:@"Shiny New Name"];

And save it in your Rails back-end.

    [post save];

Deleting is just as easy

    [post destroy];

### More Advanced Finds ###

You can also run find with JSON paramaters (or a CPDictionary)

    var myPost = [Post findWithParams:{"title":"Oh Noes!"}];
    [myPost class]; // Post

Or the same thing with a collection

    var posts = [Post allWithParams:{"body":"happy"}];
    [posts class]; // CPArray
    [[posts objectAtIndex:0] class]; // Post

The parameters will get serialized and be available to your Rails controller's `params` hash. It's up to Rails to return the appropriate records.

### Custom Identifiers ###

You don't need to use the default Rails `id` in your URLS. For example, if you'd rather use the `login` attribute as a unique identifier, overwrite your class's `identifierKey` class method like this:

    + (CPString)identifierKey
    {
        return @"login";
    }

CR will take care of the rest.

## Notifications ##

There are multiple events you can observe in the life cycle of a CR object. The notification names are comprised of the object's class name followed by the event name. So, for a `Movie` class which inherits from CR, the list of observable events are:

* MovieResourceWillLoad
* MovieResourceDidLoad
* MovieCollectionWillLoad
* MovieCollectionDidLoad
* MovieResourceWillSave
* MovieResourceWillCreate
* MovieResourceWillUpdate
* MovieResourceDidSave
* MovieResourceDidCreate
* MovieResourceDidUpdate
* MovieResourceDidNotSave
* MovieResourceDidNotCreate
* MovieResourceDidNotUpdate
* MovieResourceWillDestroy
* MovieResourceDidDestroy

One thing worth pointing out; whenever you try to save a resource, it will post 2 notifications per event. The first is the Will/Did/DidNot Save notification. The second is either Will/Did/DidNot Create or Will/Did/DidNot Update depending on what type of a save it is.

# Contributing #

Please do! Like so:

1. Fork CR
2. Pass all tests (see below)
3. Create a topic branch - `git checkout -b my_branch`
4. Push to your branch - `git push origin my_branch`
5. Pass all tests
6. Create an [Issue](http://github.com/sant0sk1/CappuccinoResource/issues) with a link to your branch

## Testing ##

Please include passing tests with any proposed additions/modifications. To run the test suite:

1. Install ojmoq: `sudo tusk install ojmoq`
2. Run tests with: `jake test` OR `ojtest Tests/*Test.j` OR `autotest`

# Credit #

Much of this library was inspired by other open-source projects, the most noteworthy of which are:

1. [CPActiveRecord](http://github.com/nciagra/Cappuccino-Extensions/tree/master/CPActiveRecord/)
2. [ObjectiveResource](http://github.com/yfactorial/objectiveresource)

I'd like to thank their authors for opening their source code to others.

# Todo List #

* Infer -attributes from ivars (maybe with @property?)
* Better error handling
* Validations
* Callbacks
* Nested Models

# Meta #

## Author ##

[Jerod Santo](http://jerodsanto.net)

## Contributors ##

Just me so far!

## License ##

[MIT](http://www.opensource.org/licenses/mit-license.php) Stylee
