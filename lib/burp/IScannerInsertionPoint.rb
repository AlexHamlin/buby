# @!parse
#   module Burp
#     # This interface is used to define an insertion point for use by active
#     # Scanner checks.
#     #
#     # Extensions can obtain instances of this interface by registering an
#     # {IScannerCheck}, or can create instances for use by Burp's own scan
#     # checks by registering an {IScannerInsertionPointProvider}.
#     #
#     module IScannerInsertionPoint
#
#       # Used to indicate where the payload is inserted into the value of a
#       # URL parameter.
#       #
#       # # INS_PARAM_URL = 0x00;
#
#       # Used to indicate where the payload is inserted into the value of a
#       # body parameter.
#       #
#       # # INS_PARAM_BODY = 0x01;
#
#       # Used to indicate where the payload is inserted into the value of an
#       # HTTP cookie.
#       #
#       # # INS_PARAM_COOKIE = 0x02;
#
#       # Used to indicate where the payload is inserted into the value of an
#       # item of data within an XML data structure.
#       #
#       # # INS_PARAM_XML = 0x03;
#
#       # Used to indicate where the payload is inserted into the value of a
#       # tag attribute within an XML structure.
#       #
#       # # INS_PARAM_XML_ATTR = 0x04;
#
#       # Used to indicate where the payload is inserted into the value of a
#       # parameter attribute within a multi-part message body (such as the
#       # name of an uploaded file).
#       #
#       # # INS_PARAM_MULTIPART_ATTR = 0x05;
#
#       # Used to indicate where the payload is inserted into the value of an
#       # item of data within a JSON structure.
#       #
#       # # INS_PARAM_JSON = 0x06;
#
#       # Used to indicate where the payload is inserted into the value of an
#       # AMF parameter.
#       #
#       # # INS_PARAM_AMF = 0x07;
#
#       # Used to indicate where the payload is inserted into the value of an
#       # HTTP request header.
#       #
#       # # INS_HEADER = 0x20;
#
#       # Used to indicate where the payload is inserted into a REST parameter
#       # within the URL file path.
#       #
#       # # INS_URL_REST = 0x21;
#
#       # Used to indicate where the payload is inserted into the name of an
#       # added URL parameter.
#       #
#       # # INS_PARAM_NAME_URL = 0x22;
#
#       # Used to indicate where the payload is inserted into the name of an
#       # added body parameter.
#       #
#       # # INS_PARAM_NAME_BODY = 0x23;
#
#       # Used to indicate where the payload is inserted at a location manually
#       # configured by the user.
#       #
#       # # INS_USER_PROVIDED = 0x40;
#
#       # Used to indicate where the insertion point is provided by an
#       # extension-registered {IScannerInsertionPointProvider}.
#       #
#       # # INS_EXTENSION_PROVIDED = 0x41;
#
#       # Used to indicate where the payload is inserted at an unknown location
#       # within the request.
#       #
#       # # INS_UNKNOWN = 0x7f;
#
#       # This method returns the name of the insertion point.
#       #
#       # @return [String] The name of the insertion point (for example, a
#       #   description of a particular request parameter).
#       #
#       def getInsertionPointName; end
#       alias get_insertion_point_name getInsertionPointName
#       alias insertion_point_name getInsertionPointName
#
#       # This method returns the base value for this insertion point.
#       #
#       # @return [String] the base value that appears in this insertion point
#       #   in the base request being scanned, or +nil+ if there is no value in
#       #   the base request that corresponds to this insertion point.
#       #
#       def getBaseValue; end
#       alias get_base_value getBaseValue
#       alias base_value getBaseValue
#
#       # This method is used to build a request with the specified payload
#       # placed into the insertion point. There is no requirement for
#       # extension-provided insertion points to adjust the Content-Length
#       # header in requests if the body length has changed, although
#       # Burp-provided insertion points will always do this and will return a
#       # request with a valid Content-Length header.
#       #
#       # @note Scan checks should submit raw non-encoded payloads to insertion
#       #   points, and the insertion point has responsibility for performing
#       #   any data encoding that is necessary given the nature and location
#       #   of the insertion point.
#       # @param [byte[]] payload The payload that should be placed into the
#       #   insertion point.
#       #
#       # @return [byte[]] The resulting request.
#       #
#       def buildRequest(payload); end
#       alias build_request buildRequest
#
#       # This method is used to determine the offsets of the payload value
#       # within the request, when it is placed into the insertion point. Scan
#       # checks may invoke this method when reporting issues, so as to
#       # highlight the relevant part of the request within the UI.
#       #
#       # @param [byte[]] payload The payload that should be placed into the
#       #   insertion point.
#       #
#       # @return [Array<Array<int>>, nil] An +int[2]+ array containing the
#       #   start and end offsets of the payload within the request, or +nil+
#       #   if this is not applicable (for example, where the insertion point
#       #   places a payload into a serialized data structure, the raw payload
#       #   may not literally appear anywhere within the resulting request).
#       #
#       def getPayloadOffsets(payload); end
#       alias get_payload_offsets getPayloadOffsets
#       alias payload_offsets getPayloadOffsets
#
#       # This method returns the type of the insertion point.
#       #
#       # @return [byte] The type of the insertion point. Available types are
#       #   defined in this interface.
#       #
#       def getInsertionPointType; end
#       alias get_insertion_point_type getInsertionPointType
#       alias insertion_point_type getInsertionPointType
#     end
#   end