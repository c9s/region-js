###
    jQuery Region
    Copyright (C) 2010 Yo-An Lin <cornelius.howl@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

Region =
  # global options
  opts:
    method: 'post'
    gateway: null
    statusbar: true
    effect: "slide"  # current only for closing.
  config: (opts) ->
    @opts = $.extend( @opts, opts)

class RegionHistory

class RegionNode
  constructor: (arg1,arg2,arg3,arg4) ->
    defaultOpts =
      debug: true
      historyBtn: false
      history: false
      # el,meta,path,args,opts

    isRegionNode = (e) ->
      typeof e is "object" and e instanceof RegionNode

    isElement = (e) ->
      typeof e is "object" and e.nodeType is 1

    isjQuery = (e) ->
      typeof e is "object" and e.get and e.attr

    if typeof arg1 is "object"
      # if specifeid, force it
      if arg2
        path = arg2
      if arg3
        args = arg3
      if arg4
        opts = arg4
      opts = $.extend( defaultOpts , opts )

      if isjQuery(arg1)      # has jQuery.get method
        el = this.initFromjQuery( arg1 )
      else if isElement( pathOrEl )
        el = this.initFromElement( arg1 )
      else if isRegionNode( arg1 )
        return arg1

      meta = this.deparseMeta( el )

      # save attributes
      @path = if meta.path then meta.path else path
      @args = if meta.args then meta.args else args
      @el   = el
      @opts = opts

      # sync attributes
      @save()
    else if typeof arg1 is "string"  # region path,
      path = arg1
      args = arg2 or { }

      if arg3
          opts = arg3
      opts = $.extend( defaultOpts , opts )

      # construct new node
      n = this.createRegionDiv()

      @path = path
      @args = args
      @el   = n
      @opts = opts

      # sync attributes
      @save()
    else
      alert("Unknown Argument Type")
      return

  initFromjQuery: (el) ->
    if el.get(0) == null
      alert( 'Region Element not found.' )
      return
    return this.init(el)

  asRegion: () -> this

  initFromElement: (e) ->
      el = $(e)
      return this.init(el)

  init: (el) ->
    el.addClass( '__region' )
      .data('region',this)
    return el

  createRegionDiv: () ->
    el = $('<div/>')
    return this.initFromElement( el )

  # write path, args into DOM element attributes
  save: () ->
    this.writeMeta( this.path , this.args )
    return this

  writeMeta: (path,args) ->
    this.el.attr({
      region_path: path,
      region_args: JSON.stringify(args)
    })

  # deparse meta from an element or from self._el
  deparseMeta: (el) ->
    if( ! el )
      el = this.el
    path = el.attr('region_path')
    args = el.attr('region_args')
    args = if args then JSON.parse( args ) else { }
    return {
      path: path,
      args: args
    }

  history: (flag) -> return this._history

  hasHistory: () -> return this.history()._history.length > 0

  saveHistory: (path,args) ->
    if (( this.opts.history || Region.opts.history ) and this.path )
      this.history().push( this.path , this.args )
      this.debug( "Save history: " + path )

  back: (callback) ->
    a = this.history().pop()
    if( a )
      this._request( a.path , a.args )

  initHistoryObject: () ->
    if( this.opts.history )
      this._history = new RegionHistory()

  createStatusbar: () ->
    return $('<div/>')
      .addClass('region-statusbar')
      .attr('id','region-statusbar')

  getStatusbarEl: () ->
    return RegionNode.statusbar if RegionNode.statusbar

    bar = $('#region-statusbar')
    return bar if bar.get(0)

    bar = this.createStatusbar()
    $(document.body).append( bar )
    RegionNode.statusbar = bar
    return bar

  # waiting content
  setWaitingContent: () ->
    if( Region.opts.statusbar )
      bar = this.getStatusbarEl()
      bar.addClass('loading')
        .html( "Loading content ..." )
        .show()
    waitingImg = $('<div/>').addClass('region-loading')
    this.el.html( waitingImg )

  debug: ( str ) ->
    if( window.console )
      console.log( str )
    if( this.conpre )
      this.conpre.prepend( str + "\n" )

  _request: (path, args, callback ) ->
    that = this
    this.setWaitingContent()

    if this.opts.debug
      arg_strs = [ ]
      for k in args
        arg_strs.push( k + ":" + args[k] )

      this.debug( "Requesting: " +  path + " <= { " + arg_strs.join("\n\t") + " }" )
      if( window.console )
        console.log( "Request region, Path:" , path , "Args:" , args )

    onError = (e) ->
      if Region.opts.statusbar
        d = $('<div/>').addClass('region-message region-error')
        d.html( "Path: " + path + " " + ( e.statusText || e.responseText ) )
        that.getStatusbarEl().show().html( d )
      that.el.html( e.statusText )
      if( window.console )
        console.error( path , args ,  e.statusText || e.responseText )
      else
        alert( e.message )

    onSuccess = (html) ->
      if Region.opts.statusbar
        that.getStatusbarEl().hide()

      that.el.fadeOut 'fast', () ->
        $(this).html(html)
        $(this).fadeIn('fast')

        if that.opts.historyBtn or Region.opts.historyBtn
          if that.hasHistory()
            backbtn = $('<div/>')
              .addClass('region-backbtn')
              .click(() -> that.back() )
            that.el.append( backbtn )
      if callback
        callback(html)

    if Region.opts.gateway
      $.ajax
        url: Region.opts.gateway
        type: Region.opts.method
        dataType: 'html'
        data: { path: path , args: args }
        error: onError
        cache: false
        success: onSuccess
    else
      $.ajax
        url: path
        data: args
        dataType: 'html'
        type: Region.opts.method
        cache: false
        error: onError
        success: onSuccess

  getEl: () -> this.el

  refresh: (callback) -> this._request( this.path , this.args , callback )

  refreshWith: (args, callback) ->
    newArgs = $.extend( {} , this.args,args)
    this.args = newArgs
    this.saveHistory()
    this._request( this.path , newArgs , callback )
    this.save()

  load: (path,args,callback) ->
    if path == null
      path = this.path
      args = args ? args : this.args
    this.replace(path,args, callback )

  replace: (path,args,callback) ->
    this.saveHistory()
    this.path = path
    this.args = args
    this.save()
    this.refresh( callback )

  # XXX: seems no use.
  of: () -> this.el

  parent: () -> return new RegionNode($( this.el.parents('.__region').get(0) ))

  subregions: () ->
    # /* find subregion elements and convert them into RegionNode */
    return this.regionElements().map( (e) ->
        return new RegionNode(e)
    )

  regionElements: () -> this.el.find('.__region')

  # setup region content == empty
  empty: () -> this.el.empty()

  # setup region content (html)
  html: (html) -> return this.el.html( html )

  # remove region
  remove: () -> this.el.remove()

  # type: 1 for hide, 0 for show
  getEffectFunc: (type) ->
    ef = Region.opts.effect
    if( ef is "fade" )
      m = if type then jQuery.fn.fadeOut else jQuery.fn.fadeIn
    else if ( ef is "slide" )
      m = if type then jQuery.fn.slideUp else jQuery.fn.slideDown
    else
      m = if type then jQuery.fn.slideUp else jQuery.fn.slideDown
    return m

  effectRemove: () ->
    that = this
    m = this.getEffectFunc(1)
    m.call( this.getEl() , 'slow' , () ->
        that.getEl().remove()
    )

  fadeRemove: () ->
    that = this
    this.effectRemove()

  fadeEmpty: () ->
    that = this
    m = this.getEffectFunc(1)
    m.call( this.getEl() , 'slow' , () ->
        that.getEl().empty().show()
    )

  removeSubregions: () ->
      this.regionElements().map( (e) -> $(e).remove() )

  refreshSubregions: () ->
      this.regionElements().map( (e) ->
          r = new RegionNode(e)
          r.refresh()
      )

  submit: (formEl) ->
    ###
      // TODO:
      // Submit Action to current region.
      //    get current region path or from form 'action' attribute.
      //    get field values 
      //    send ajax post to the region path
      ###

  # find sub regions by id or ...
  find: () ->
    ## XXX:
    this.el.find

Region.get = (el) ->
  if typeof el is "array"
    return $(el).map (e,i) -> return Region.getOne(e)
  else
    return Region.getOne(el)

Region.getOne = (el) ->
  if el instanceof RegionNode
    return el
  else if( el.nodeType is 1 or el instanceof Element )
    return Region.of(el)
  else if( typeof el is "string" )
    return new RegionNode( $(el) )
  return new RegionNode(el)


###
 * Find the region from child element.
 *
 * @param el Child Element 
###
Region.of = (el) ->
  regEl = $(el).parents('.__region').get(0)
  return if not regEl
  return $(regEl).asRegion()

Region.append = (el,path,args) ->
  rn = new RegionNode(path,args)
  rn.refresh()
  $(el).append( rn.getEl() )
  return if rn.getEl() then true else false

###
* Insert a region after an element
*
###
Region.after = (el,path,args) ->
    rn = new RegionNode(path,args)
    rn.refresh()

    ## var p = $(el).parents('.__region')
    # rn.btn = $(el)
    # rn.callerRegion = p.asRegion()

    if typeof el is 'RegionNode'
        rn.callerRegion = el
    rn.btn = el

    # insert new region after the region.
    $(el).after rn.getEl()
    return rn ? rn : false



###
 Insert a new region before the element.
###
Region.before = (el,path,args) ->
  # create new region node and load it with args
    rn = new RegionNode(path,args)
    rn.refresh()

    $(el).before( rn.getEl() )
    return rn ? rn : false

###
  Region.load( $('content'), 'path', { id: 123 } , function() {  } );
  Region.load( $('content'), 'path' , function() {  } );
  Region.load( $('content'), 'path' );

  Region.load doesn't sync path ,args to attirbute.
###

Region.load = (el,path,arg1,arg2) ->
  callback
  args = {  }
  if typeof arg1 is "object"
    args = arg1
    if typeof arg2 is "function"
      callback = arg2
  else if typeof arg1 is "function"
    callback = arg1

  rn = new RegionNode(el)
  rn.replace( path, args )
  return rn

Region.replace = (el,path,arg1,arg2) ->
    rn = this.load(el,path,arg1,arg2)
    rn.save()
    return rn


jQuery.fn.asRegion = (opts) ->
  r = $(this).data('region')
  return r if r

  r = new RegionNode( $(this), null, opts)
  $(this).data('region',r)
  return r


window.RegionHistory = RegionHistory
window.RegionNode = RegionNode
window.Region = Region
jQuery.region = Region
