include Java

require 'pp'
require "buby.jar"

include_class 'BurpExtender'

# Buby is a mash-up of the commercial security testing web proxy PortSwigger 
# Burp Suite(tm) allowing you to add scripting to Burp. Burp is driven from 
# and tied to JRuby with a Java extension using the BurpExtender API.
#
# The Buby class is an abstract implementation of a BurpExtender ruby handler. 
# Included are several abstract event handlers used from the BurpExtender
# java implementation:
# * evt_extender_init
# * evt_proxy_message
# * evt_command_line_args
# * evt_register_callbacks
# * evt_application_closing
#
# Buby also supports the newer event handlers available in Burp 1.2.09 and up:
# * evt_http_message
# * evt_scan_issue
#
#
# This class also exposes several methods to access Burp functionality 
# and user interfaces through the IBurpExtenderCallbacks interface 
# (note, several abbreviated aliases also exist for each):
# * doActiveScan
# * doPassiveScan
# * excludeFromScope
# * includeInScope
# * isInScope
# * issueAlert
# * makeHttpRequest
# * sendToIntruder
# * sendToRepeater
# * sendToSpider
#
# Buby also provides front-end ruby methods for the new callback methods added
# since Burp 1.2.09:
# * getProxyHistory
# * getSiteMap
# * restoreState
# * saveState
# * getParameters
# * getHeaders
#
# If you wish to access any of the IBurpExtenderCallbacks methods directly. 
# You can use 'burp_callbacks' to obtain a reference.
#
# Credit:
# * Burp and Burp Suite are trade-marks of PortSwigger Ltd.
#     Copyright 2008 PortSwigger Ltd. All rights reserved.
#     See http://portswigger.net for license terms.
#
# * This ruby library and the accompanying BurpExtender.java implementation 
#   were written by Eric Monti @ Matasano Security. 
#
#   Matasano claims no professional or legal affiliation with PortSwigger LTD. 
#   nor do we sell or officially endorse any of their products.
#
#   However, this author would like to express his personal and professional 
#   respect and appreciation for their making available the BurpExtender 
#   extension API. The availability of this interface in an already great tool
#   goes a long way to make Burp Suite a truly first-class application.
#
# * Forgive the name. It won out over "Burb" and "BurpRub". It's just easier 
#   to type and say out-loud. Mike Tracy gets full credit as official 
#   Buby-namer.
#
class Buby

  # :stopdoc:
  VERSION = '1.1.2'
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  def initialize(other=nil)
    if other
      raise "arg 0 must be another kind of Buby" unless other.is_a? Buby
      @burp_extender = other.burp_extender
      @burp_callbacks = other.burp_callbacks
    end
  end

  # Makes this handler the active Ruby handler object for the BurpExtender
  # Java runtime. (there can be only one!)
  def activate!
    BurpExtender.set_handler(self)
  end

  # Returns the internal reference to the BurpExtender instance. This
  # reference gets set from Java through the evt_extender_init method.
  def burp_extender; @burp_extender; end

  # Returns the internal reference to the IBupExtenderCallbacks instance.
  # This reference gets set from Java through the evt_register_callbacks
  # method. It is exposed to allow you to access the IBurpExtenderCallbacks 
  # instance directly if you so choose.
  def burp_callbacks; @burp_callbacks; end

  # Internal method to check for the existence of the burp_callbacks reference
  # before doing anything with it.
  def _check_cb
    @burp_callbacks or raise "Burp callbacks have not been set"
  end

  # Send an HTTP request to the Burp Scanner tool to perform an active 
  # vulnerability scan.
  #  * host = The hostname of the remote HTTP server.
  #  * port = The port of the remote HTTP server.
  #  * https = Flags whether the protocol is HTTPS or HTTP.
  #  * req  = The full HTTP request.
  def doActiveScan(host, port, https, req)
    _check_cb.doActiveScan(host, port, https, req.to_java_bytes)
  end
  alias do_active_scan doActiveScan
  alias active_scan doActiveScan

  # Send an HTTP request and response to the Burp Scanner tool to perform a 
  # passive vulnerability scan.
  #  * host = The hostname of the remote HTTP server.
  #  * port = The port of the remote HTTP server.
  #  * https = Flags whether the protocol is HTTPS or HTTP.
  #  * req  = The full HTTP request.
  #  * rsp  = The full HTTP response.
  def doPassiveScan(host, port, https, req, rsp)
    _check_cb.doPassiveScan(host, port, https, req.to_java_bytes, rsp.to_java_bytes)
  end
  alias do_passive_scan doPassiveScan
  alias passive_scan doPassiveScan

  # Exclude the specified URL from the Suite-wide scope.
  #  * url = The URL to exclude from the Suite-wide scope.
  def excludeFromScope(url)
    _check_cb.excludeFromScope(java.net.URL.new(url.to_s))
  end
  alias exclude_from_scope excludeFromScope
  alias exclude_scope excludeFromScope

  # Include the specified URL in the Suite-wide scope.
  #  * url = The URL to exclude in the Suite-wide scope.
  def includeInScope(url)
    _check_cb.includeInScope(java.net.URL.new(url.to_s))
  end
  alias include_in_scope includeInScope 
  alias include_scope includeInScope 

  # Query whether a specified URL is within the current Suite-wide scope.
  #  * url = The URL to query
  #
  # Returns: true / false
  def isInScope(url)
    _check_cb.isInScope(java.net.URL.new(url.to_s))
  end
  alias is_in_scope isInScope
  alias in_scope? isInScope

  # Display a message in the Burp Suite alerts tab.
  #  * msg =  The alert message to display.
  def issueAlert(msg)
    _check_cb.issueAlert(msg.to_s)
  end
  alias issue_alert issueAlert
  alias alert issueAlert

  # Issue an arbitrary HTTP request and retrieve its response
  #  * host  = The hostname of the remote HTTP server.
  #  * port  = The port of the remote HTTP server.
  #  * https = Flags whether the protocol is HTTPS or HTTP.
  #  * req   = The full HTTP request.
  #
  # Returns: The full response retrieved from the remote server.
  def makeHttpRequest(host, port, https, req)
    String.from_java_bytes(
      _check_cb.makeHttpRequest(host, port, https, req.to_java_bytes)
    )
  end
  alias make_http_request makeHttpRequest
  alias make_request makeHttpRequest

  # Send an HTTP request to the Burp Intruder tool
  #  * host  = The hostname of the remote HTTP server.
  #  * port  = The port of the remote HTTP server.
  #  * https = Flags whether the protocol is HTTPS or HTTP.
  #  * req   = The full HTTP request.
  def sendToIntruder(host, port, https, req)
    _check_cb.sendToIntruder(host, port, https, req.to_java_bytes)
  end
  alias send_to_intruder sendToIntruder
  alias intruder sendToIntruder

  # Send an HTTP request to the Burp Repeater tool.
  #  * host  = The hostname of the remote HTTP server.
  #  * port  = The port of the remote HTTP server.
  #  * https = Flags whether the protocol is HTTPS or HTTP.
  #  * req   = The full HTTP request.
  #  * tab   = The tab caption displayed in Repeater. (default: auto-generated)
  def sendToRepeater(host, port, https, req, tab=nil)
    _check_cb.sendToRepeater(host, port, https, req.to_java_bytes, tab)
  end
  alias send_to_repeater sendToRepeater
  alias repeater sendToRepeater

  # Send a seed URL to the Burp Spider tool.
  #  * url = The new seed URL to begin spidering from.
  def sendToSpider(url)
    _check_cb.includeInScope(java.net.URL.new(url.to_s))
  end
  alias send_to_spider sendToSpider
  alias spider sendToSpider

  # This method is a __send__ call back gate for the IBurpExtenderCallbacks
  # reference. It first checks to see if a method is available before calling
  # with the specified arguments, and raises an exception if it is unavailable.
  #
  # This method was added for provisional calling of new callbacks added since
  # Burp 1.2.09
  #
  # * meth = string or symbol name of method
  # * args = variable length array of arguments to pass to meth
  def _check_and_callback(meth, *args)
    cb = _check_cb
    unless cb.respond_to?(meth)
      raise "#{meth} is not available in your version of Burp"
    end
    cb.__send__ meth, *args
  end

  # Returns a Java array of IHttpRequestResponse objects pulled directly from 
  # the Burp proxy history.
  def getProxyHistory
    _check_and_callback(:getProxyHistory)
  end
  alias proxy_history getProxyHistory
  alias get_proxy_history getProxyHistory

  # Returns a Java array of IHttpRequestResponse objects pulled directly from 
  # the Burp site map.
  def getSiteMap(urlprefix)
    _check_and_callback(:getSiteMap, urlprefix)
  end
  alias site_map getSiteMap
  alias get_site_map getSiteMap

  # This method returns all of the current scan issues for URLs matching the 
  # specified literal prefix. The prefix can be null to match all issues.
  def getScanIssues(urlprefix)
    _check_and_callback(:getScanIssues, urlprefix)
  end
  alias scan_issues getScanIssues
  alias get_scan_issues getScanIssues

  # Restores Burp session state from a previously saved state file.
  # See also: saveState
  #
  # IMPORTANT: This method is only available with Burp 1.2.09 and higher.
  #
  # * filename = path and filename of the file to restore from
  def restoreState(filename)
    _check_and_callback(:restoreState, java.io.File.new(filename))
  end
  alias restore_state restoreState

  # Saves the current Burp session to a state file. See also restoreState.
  #
  # IMPORTANT: This method is only available with Burp 1.2.09 and higher.
  #
  # * filename = path and filename of the file to save to
  def saveState(filename)
    _check_and_callback(:saveState, java.io.File.new(filename))
  end
  alias save_state saveState

  # Parses a raw HTTP request message and returns an associative array 
  # containing parameters as they are structured in the 'Parameters' tab in the 
  # Burp request UI.
  #
  # IMPORTANT: This method is only available with Burp 1.2.09 and higher.
  #
  # req = raw request string (converted to Java bytes[] in passing)
  def getParameters(req)
    _check_and_callback(:getParameters, req.to_s.to_java_bytes)
  end
  alias parameters getParameters
  alias get_parameters getParameters

  # Parses a raw HTTP message (request or response ) and returns an associative
  # array containing the headers as they are structured in the 'Headers' tab 
  # in the Burp request/response viewer UI.
  #
  # IMPORTANT: This method is only available with Burp 1.2.09 and higher.
  #
  # msg = raw request/response string (converted to Java bytes[] in passing)
  def getHeaders(msg)
    _check_and_callback(:getHeaders, msg.to_s.to_java_bytes)
  end
  alias headers getHeaders
  alias get_Headers getHeaders


  ### Event Handlers ###

  # This method is called by the BurpExtender java implementation upon 
  # initialization of the BurpExtender instance for Burp. The args parameter
  # is passed with a instance of the newly initialized BurpExtender instance 
  # so that implementations can access and extend its public interfaces.
  #
  # The return value is ignored.
  def evt_extender_init ext
    @burp_extender = ext
    pp([:got_extender, ext]) if $DEBUG
  end

  # This method is called by the BurpExtender implementation Burp startup.
  # The args parameter contains main()'s argv command-line arguments array. 
  #
  # Note: This maps to the 'setCommandLineArgs' method in the java 
  # implementation of BurpExtender.
  #
  # The return value is ignored.
  def evt_command_line_args args
    pp([:got_args, args]) if $DEBUG
  end

  # This method is called by BurpExtender on startup to register Burp's 
  # IBurpExtenderCallbacks interface object.
  #
  # This maps to the 'registerExtenderCallbacks' method in the Java 
  # implementation of BurpExtender.
  #
  # The return value is ignored.
  def evt_register_callbacks cb
    @burp_callbacks = cb
    cb.issueAlert("[JRuby::#{self.class}] registered callback")
    pp([:got_callbacks, cb]) if $DEBUG
  end

  ACTION_FOLLOW_RULES   = BurpExtender::ACTION_FOLLOW_RULES
  ACTION_DO_INTERCEPT   = BurpExtender::ACTION_DO_INTERCEPT
  ACTION_DONT_INTERCEPT = BurpExtender::ACTION_DONT_INTERCEPT
  ACTION_DROP           = BurpExtender::ACTION_DROP

  # This method is called by BurpExtender while proxying HTTP messages and
  # before passing them through the Burp proxy. Implementations can use this
  # method to implement arbitrary processing upon HTTP requests and responses 
  # such as interception, logging, modification, and so on.
  #
  # The 'is_req' parameter indicates whether it is a response or request.
  #
  # Note: This method maps to the 'processProxyMessage' method in the java 
  # implementation of BurpExtender.
  #
  # Below are the parameters descriptions based on the IBurpExtender 
  # javadoc. Where applicable, decriptions have been modified for 
  # local parameter naming and other ruby-specific details added.
  #
  # * msg_ref:
  #   An identifier which is unique to a single request/response pair. This 
  #   can be used to correlate details of requests and responses and perform 
  #   processing on the response message accordingly. This number also 
  #   corresponds to the Burp UI's proxy "history" # column.
  #
  # * is_req: (true/false)
  #   Flags whether the message is a client request or a server response.
  #
  # * rhost:
  #   The hostname of the remote HTTP server.
  #
  # * rport:
  #   The port of the remote HTTP server.
  #
  # * is_https:
  #   Flags whether the protocol is HTTPS or HTTP.
  #
  # * http_meth:
  #   The method verb used in the client request.
  #
  # * url:
  #   The requested URL. Set in both the request and response.
  #
  # * resourceType:
  #   The filetype of the requested resource, or nil if the resource has no 
  #   filetype.
  #
  # * status:
  #   The HTTP status code returned by the server. This value is nil for 
  #   request messages.
  #
  # * req_content_type:
  #   The content-type string returned by the server. This value is nil for 
  #   request messages.
  #
  # * message:
  #   The full HTTP message.  
  #   **Ruby note: 
  #     For convenience, the message is received and returned as a ruby 
  #     String object. Internally within Burp it is handled as a java byte[] 
  #     array. See also the notes about the return object below.
  #
  # * action:
  #   An array containing a single integer, allowing the implementation to 
  #   communicate back to Burp Proxy a non-default interception action for 
  #   the message. The default value is ACTION_FOLLOW_RULES (or 0). 
  #   Possible values include:
  #     ACTION_FOLLOW_RULES = 0
  #     ACTION_DO_INTERCEPT = 1
  #     ACTION_DONT_INTERCEPT = 2
  #     ACTION_DROP = 3
  #
  #   Refer to the BurpExtender.java source comments for more details.
  #
  #
  # Return Value:
  #   Implementations should return either (a) the same object received
  #   in the message paramater, or (b) a different object containing a 
  #   modified message. 
  #
  # **IMPORTANT RUBY NOTE:
  # Always be sure to return a new object if making modifications to messages.
  #
  # Explanation: 
  # The (a) and (b) convention above is followed rather literally during type 
  # conversion on the return value back into the java BurpExtender.
  #
  # When determining whether a change has been made in the message or not, 
  # the decision is made based on whether the object returned is the same
  # as the object submitted in the call to evt_proxy_message. 
  #
  #
  # So, for example, using in-place modification of the message using range 
  # substring assignments or destructive method variations like String.sub!() 
  # and String.gsub! alone won't work because the same object gets returned 
  # to BurpExtender. 
  #
  # In short, this means that if you want modifications to be made, be sure
  # to return a different String than the one you got in your handler.
  #
  # So for example this code won't do anything at all:
  #
  #   ...
  #   message.sub!(/^GET /, "HEAD ")
  #   return message
  #
  # Nor this:
  #
  #   message[0..4] = "HEAD "
  #   return message
  #
  # But this will
  #
  #   ...
  #   return message.sub(/^GET /, "HEAD ")
  #
  # And so will this
  #
  #   ...
  #   message[0..4] = "HEAD "
  #   return message.dup
  #
  def evt_proxy_message msg_ref, is_req, rhost, rport, is_https, http_meth, url, resourceType, status, req_content_type, message, action
    pp([ (is_req)? :got_proxy_request : :got_proxy_response,
         [:msg_ref, msg_ref], 
         [:is_req, is_req], 
         [:rhost, rhost], 
         [:rport, rport], 
         [:is_https, is_https], 
         [:http_meth, http_meth], 
         [:url, url], 
         [:resourceType, resourceType], 
         [:status, status], 
         [:req_content_type, req_content_type], 
         [:message, message], 
         [:action, action[0]] ]) if $DEBUG
    
    return message
  end


  # This method is invoked whenever any of Burp's tools makes an HTTP request 
  # or receives a response. This is effectively a generalised version of the 
  # pre-existing evt_proxy_message method, and can be used to intercept and 
  # modify the HTTP traffic of all Burp tools.
  #
  # IMPORTANT: This event handler is only used in Burp version 1.2.09 and 
  # higher.
  # 
  # Note: this method maps to the processHttpMessage BurpExtender Java method.
  #
  # This method should be overridden if you wish to implement functionality
  # relating to generalized requests and responses from any BurpSuite tool.
  # You may want to use evt_proxy_message if you only intend to work with only 
  # proxied messages. Note, however, the IHttpRequestResponse Java object is 
  # not used in evt_proxy_http_message and gives evt_http_message a somewhat 
  # nicer interface to work with.
  #
  # Parameters:
  # * tool_name = a string name of the tool that generated the message
  #
  # * is_request = boolean true = request / false = response
  #
  # * message_info = an instance of the IHttpRequestResponse Java class with
  #   methods for accessing and manipulating various attributes of the message.
  #
  def evt_http_message tool_name, is_request, message_info
    pp([:got_http_message, tool_name, is_request, message_info]) if $DEBUG
  end

  # This method is invoked whenever Burp Scanner discovers a new, unique 
  # issue, and can be used to perform customised reporting or logging of 
  # detected issues.
  #
  # IMPORTANT: This event handler is only used in Burp version 1.2.09 and 
  # higher.
  #
  # Note: this method maps to the newScanIssue BurpExtender Java method.
  #
  # Parameters:
  # * issue = an instance of the IScanIssue Java class with methods for viewing
  #   information on the scan issue that was generated.
  def evt_scan_issue(issue)
    pp([:got_scan_issue, issue]) if $DEBUG
  end

  # This method is called by BurpExtender right before closing the
  # application. Implementations can use this method to perform cleanup
  # tasks such as closing files or databases before exit.
  def evt_application_closing 
    pp([:got_app_close]) if $DEBUG
  end

  # Prepares the java BurpExtender implementation with a reference
  # to self as the module handler and launches burp suite.
  def start_burp(args=[])
    activate!()
    Java::Burp::StartBurp.main(args.to_java(:string))
    return self
  end

  # Starts burp using a supplied handler class, 
  #  h_class = Buby or a derived class. instance of which will become handler.
  #  args = arguments to Burp
  #  init_args = arguments to the handler constructor
  #
  #  Returns the handler instance
  def self.start_burp(h_class=nil, init_args=nil, args=nil)
    h_class ||= self
    init_args ||= []
    args ||= []
    h_class.new(*init_args).start_burp(args)
  end

  # Attempts to load burp with require and confirm it provides the required 
  # class in the Java namespace.
  #
  # Returns: true/false depending on whether the required jar provides us
  # the required class
  #
  # Raises: may raise the usual require exceptions if jar_path is bad.
  def self.load_burp(jar_path)
    require jar_path
    return burp_loaded?
  end

  # Checks the Java namespace to see if Burp has been loaded.
  def self.burp_loaded?
    begin 
      include_class 'burp.StartBurp'
      return true
    rescue
      return false
    end
  end

  ### Extra cruft added by Mr Bones:

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end

  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
        ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

    Dir.glob(search_me).sort.each {|rb| require rb}
  end

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end
end

# Try requiring 'burp.jar' from the Ruby lib-path
unless Buby.burp_loaded?
  begin require "burp.jar" 
  rescue LoadError 
  end
end

