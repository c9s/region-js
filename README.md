
# jQuery-Region

When you are doing ajax request, you don't know what path, args were loaded
before for containers.

jQuery region remembers what path,args it loaded before in elements. 
by using jQuery region, you can load a region from an element, and refresh it or
replace the content, you can also find subregions, or find parent region to reload.

Region is an alias of $.region

Cascading statements:

    <div ....>
        <a onclick="return Region.of(this).refresh(); ">Refresh</a>
        <a onclick="return Region.load($('#panel'),'path/to/tab1.php');">Tab1</a>

        <div id="panel">
        </div>
    </div>

jQuery fn:

    $('#panel-1').asRegion().load( 'path/to/content.html' , { id: 123 } );

jQuery fn with history:

    $('#panel-1').asRegion({ history: true }).load({ id: 123 });

### Config

#### Gateway

    RegionNode.opts.gateway = '/path/to/region_gateway.php';

in your region\_gateway.php:
    
    <?php
    $path = $_POST['path'];
    $args = $_POST['args'];

    # evaling your region content...

    echo $content;
    ?>

#### Method

    RegionNode.opts.method = 'post';
    RegionNode.opts.method = 'get';

### jQuery methods

jQuery.fn.asRegion( opts )

### Region class methods

constructor ( [path or element object] , [ args ] , [ opts ] )

> create a region object from an existing element.
> Or create a region object with (path,args,opts).

save()

> write attributes (region path and region args) 

history( [flag] )

> enable/disable history.

saveHistory()

> save current path,args into history object.

back()

> pop up an history from history object. 
> returns: 

        path:
        args:
        callback:

refresh()

> refresh region. get path, args from element, and reload it.

refreshWith( [args] , [callback] )

> get current path , and reload it with new arguments.

load( [path], [args], [callback] )

> load content from [path] with [args].

replace( [path], [args], [callback] )

> replace current content with path and args.

parent()

> get parent region.

subregions()

> get child regions.

regionElements()

> get child region elements.

empty()

> set current content to empty.

html(html)

> set/get current content.

remove()

> remove region element.

fadeRemove()

fadeEmpty()

removeSubregions()

refreshSubregions()

### Examples

to load content to #panel with arguments (id,name):

    Region.load( $('#panel') , 'path/to/content' , { id: 123, name: "foo" } );

to append content inside #panel:

    Region.append( $('#panel') , 'path/to/content' , { id: 123, name: "foo" } );

to add content before #panel:

    Region.before( $('#panel') , 'path/to/content' , { id: 123, name: "foo" } );

to add content after #panel:

    Region.after( $('#panel') , 'path/to/content' , { id: 123, name: "foo" } );

to get an element and load the region info (path and args):

    var region = Region.get( nodeObj );

and replace to another content:

    region.replace( 'path/to/replace' );

to replace an element content directly:

    Region.replace( $('#panel') , 'another/path' , { name: "Jack" } );

to get the region of an element and refresh it:

    var r = Region.of( $('#subpanel') );   // get $('#panel')
    r.refresh();

to get sub regions:

    var rs = r.subregions(); // get subregions

to remove the region:

    rs.remove();

to remove the region with fade out effect:

    rs.fadeRemove();

to clean up content of a region:

    rs.empty();
    
to refresh the sub regions:

    r.refreshSubRegions();


To use RegionNode object:

    var r = new RegionNode( $('#region') );
    r.load('path/to/region',{ ...args... });
    r.refresh();
    r.fadeRemove();

# Todo

* Region histories.
